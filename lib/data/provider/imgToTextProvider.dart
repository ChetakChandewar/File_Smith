import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:clipboard/clipboard.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:pick_or_save/pick_or_save.dart';

class ImgToTextProvider with ChangeNotifier {
  String _recognizedText = '';
  bool _isSpeaking = false;

  final PickOrSave _pickOrSavePlugin = PickOrSave();

  final FlutterTts _flutterTts = FlutterTts();
  TextEditingController textController = TextEditingController();

  String get recognizedText => _recognizedText;
  bool get isSpeaking => _isSpeaking;

  ImgToTextProvider() {
    _flutterTts.setCompletionHandler(() {
      _isSpeaking = false;
      notifyListeners();
    });
  }



  Future<void> pickImagesFromGallery(BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile>? images = await picker.pickMultiImage();
      if (images != null && images.isNotEmpty) {
        for (var image in images) {
          await _processImage(image.path, context);
        }
      } else {
        _showSnackbar(context, 'No images selected.', isError: true);
      }
    } catch (e) {
      _showSnackbar(context, 'Error picking images: $e', isError: true);
    }
  }

  Future<void> pickImageFromCamera(BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        await _processImage(image.path, context);
      } else {
        _showSnackbar(context, 'No image captured.', isError: true);
      }
    } catch (e) {
      _showSnackbar(context, 'Error picking image: $e', isError: true);
    }
  }

  Future<void> _processImage(String filePath, BuildContext context) async {
    try {
      final inputImage = InputImage.fromFilePath(filePath);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

      final recognizedText = await textRecognizer.processImage(inputImage);
      await textRecognizer.close(); // Ensure resource cleanup

      if (recognizedText.text.isNotEmpty) {
        _recognizedText += _recognizedText.isNotEmpty ? '\n\n' + recognizedText.text : recognizedText.text;
        _updateTextController();
      } else {
        _showSnackbar(context, 'No text recognized.', isError: true);
      }
    } catch (e) {
      _showSnackbar(context, 'Error recognizing text: $e', isError: true);
    }
  }

  void _updateTextController() {
    textController.text = _recognizedText;
    notifyListeners();
  }


  Future<void> saveTextAsPdf(BuildContext context, String text) async {
    try {
      final pdf = pw.Document();

      // Load custom font for better text rendering
      final font = await rootBundle.load("assets/fonts/calibri-regular.ttf");
      final ttf = pw.Font.ttf(font);

      // Split text into multiple pages
      const int maxCharsPerPage = 1000; // Adjust as needed
      List<String> pages = _splitTextIntoPages(text, maxCharsPerPage);

      for (var pageText in pages) {
        pdf.addPage(
          pw.Page(
            build: (pw.Context context) => pw.Padding(
              padding: const pw.EdgeInsets.all(16),
              child: pw.Text(
                pageText,
                style: pw.TextStyle(font: ttf, fontSize: 14),
              ),
            ),
          ),
        );
      }

      // Generate temporary file
      final directory = await Directory.systemTemp.createTemp();
      String tempPath = '${directory.path}/recognized_text.pdf';
      File tempFile = File(tempPath);
      await tempFile.writeAsBytes(await pdf.save());

      // Save file using pick_or_save plugin
      await _pickOrSavePlugin.fileSaver(
        params: FileSaverParams(
          saveFiles: [
            SaveFileInfo(
              filePath: tempPath,
              fileName: "RecognizedText_${DateTime.now().millisecondsSinceEpoch}.pdf",
            )
          ],
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("PDF saved successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving PDF: $e")),
      );
    }
  }

  // Function to split text into pages
  List<String> _splitTextIntoPages(String text, int maxCharsPerPage) {
    List<String> pages = [];
    for (int i = 0; i < text.length; i += maxCharsPerPage) {
      pages.add(text.substring(i, i + maxCharsPerPage > text.length ? text.length : i + maxCharsPerPage));
    }
    return pages;
  }




  void updateRecognizedText(String text) {
    _recognizedText = text;
    notifyListeners();
  }

  void clearText() {
    _recognizedText = '';
    textController.clear();
    notifyListeners();
  }

  void copyToClipboard(BuildContext context) {
    if (_recognizedText.isNotEmpty) {
      try {
        FlutterClipboard.copy(_recognizedText).then((_) {
          _showSnackbar(context, 'Text copied to clipboard!', isError: false);
        }).catchError((error) {
          _showSnackbar(context, 'Failed to copy text to clipboard.', isError: true);
        });
      } catch (e) {
        _showSnackbar(context, 'Failed to copy text to clipboard.', isError: true);
      }
    }
  }

  Future<void> speakText() async {
    if (_isSpeaking) {
      await _flutterTts.stop();
      _isSpeaking = false;
    } else {
      if (_recognizedText.isNotEmpty) {
        _isSpeaking = true;
        await _flutterTts.speak(_recognizedText);
      } else {
        _showSnackbar(null, 'No text to speak.', isError: true);
      }
    }
    notifyListeners();
  }

  Future<bool> _requestStoragePermission(BuildContext context) async {
    var status = await Permission.storage.request();
    if (!status.isGranted) {
      _showSnackbar(context, 'Storage permission denied.', isError: true);
      return false;
    }
    return true;
  }

  void _showSnackbar(BuildContext? context, String message, {required bool isError}) {
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: TextStyle(color: Colors.white)),
          backgroundColor: isError ? Colors.red : Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  void dispose() {
    _flutterTts.stop();
    textController.dispose();
    super.dispose();
  }
}
