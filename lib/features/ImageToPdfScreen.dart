import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:path_provider/path_provider.dart';
import '../data/provider/img_to_pdf_provider.dart';

class ImageToPdfScreen extends StatefulWidget {
  const ImageToPdfScreen({Key? key}) : super(key: key);

  @override
  State<ImageToPdfScreen> createState() => _ImageToPdfScreenState();
}

class _ImageToPdfScreenState extends State<ImageToPdfScreen> {
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await Permission.storage.request();
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        Provider.of<ImageToPdfProvider>(context, listen: false).addImage(File(pickedFile.path));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error picking image: $e")),
      );
    }
  }

  Future<void> pickMultiImages() async {
    try {
      final pickedFiles = await _picker.pickMultiImage();
      if (pickedFiles != null) {
        for (var pickedFile in pickedFiles) {
          Provider.of<ImageToPdfProvider>(context, listen: false).addImage(File(pickedFile.path));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error picking images: $e")),
      );
    }
  }

  Future<void> _showConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Clear'),
          content: const Text('Are you sure you want to clear all images?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Clear'),
              onPressed: () {
                Provider.of<ImageToPdfProvider>(context, listen: false).clearAll();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("All images cleared!")),
                );
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> savePdf() async {
    final provider = Provider.of<ImageToPdfProvider>(context, listen: false);
    if (provider.isGenerating) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("PDF is generating. Please wait.")),
      );
      return;
    }

    try {
      final fileName = await _promptForFileName(context);
      if (fileName != null && fileName.trim().isNotEmpty) {
        await provider.generatePdf(); // Ensure PDF is generated before saving
        final bytes = await provider.pdfDocument.save();
        final Uint8List byteList = Uint8List.fromList(bytes);
        await _saveFile(byteList, fileName);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("File name cannot be empty!")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving PDF: $e")),
      );
    }
  }

  Future<void> _saveFile(Uint8List bytes, String fileName) async {
    try {
      final params = SaveFileDialogParams(
        data: bytes,
        fileName: "$fileName.pdf",
      );
      final path = await FlutterFileDialog.saveFile(params: params);
      if (path != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("PDF saved successfully at $path")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("File saving canceled!")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving PDF: $e")),
      );
    }
  }

  Future<String?> _promptForFileName(BuildContext context) async {
    final TextEditingController controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Enter File Name"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "e.g., MyPDF"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Future<void> clearCache() async {
    try {
      final tempDir = await getTemporaryDirectory();
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    } catch (e) {
    }
  }

  @override
  void dispose() {
    clearCache(); // Clear cache when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ImageToPdfProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Image to PDF"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever, color: Colors.red),
            onPressed: _showConfirmationDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          provider.isGenerating ? LinearProgressIndicator(value: provider.generationProgress) : const SizedBox.shrink(),
          Expanded(
            child: provider.selectedImages.isEmpty
                ? const Center(
              child: Text(
                "No images selected",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
                : ReorderableListView(
              onReorder: (oldIndex, newIndex) {
                provider.reorderImages(oldIndex, newIndex);
              },
              children: [
                for (int index = 0; index < provider.selectedImages.length; index++)
                  Dismissible(
                    key: ValueKey(provider.selectedImages[index]),
                    onDismissed: (direction) {
                      provider.removeImage(index);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Image removed!")),
                      );
                    },
                    background: Container(color: Colors.red),
                    child: Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      child: ListTile(
                        leading: Image.file(
                          provider.selectedImages[index],
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                        title: Text(provider.selectedImages[index].path.split('/').last),
                        trailing: const Icon(Icons.drag_handle),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  onPressed: () => pickMultiImages(),
                  icon: const Icon(Icons.photo_library),
                  label: const Text("Gallery"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text("Camera"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: () async {
                if (provider.selectedImages.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("No images selected!")),
                  );
                } else {
                  savePdf();
                }
              },
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text("Generate PDF"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
