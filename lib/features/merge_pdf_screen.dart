import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf_manipulator/pdf_manipulator.dart';
import 'package:pick_or_save/pick_or_save.dart';

class MergePDFScreen extends StatefulWidget {
  const MergePDFScreen({super.key});

  @override
  State<MergePDFScreen> createState() => _MergePDFScreenState();
}

class _MergePDFScreenState extends State<MergePDFScreen> {
  final PdfManipulator _pdfManipulatorPlugin = PdfManipulator();
  final PickOrSave _pickOrSavePlugin = PickOrSave();

  bool _isBusy = false;
  List<String> _pickedFilesPaths = [];
  String? _mergedPDFsPath;

  Future<List<String>?> _filePicker() async {
    setState(() => _isBusy = true);
    try {
      return await _pickOrSavePlugin.filePicker(
        params: FilePickerParams(
          localOnly: true,
          enableMultipleSelection: true,
          mimeTypesFilter: ["application/pdf"],
        ),
      );
    } catch (e) {
      log("Error in file picking: $e");
      return null;
    } finally {
      setState(() => _isBusy = false);
    }
  }

  Future<String?> _mergePDFs() async {
    if (_pickedFilesPaths.isEmpty) return null;
    try {
      final mergedPath = await _pdfManipulatorPlugin.mergePDFs(
        params: PDFMergerParams(pdfsPaths: _pickedFilesPaths),
      );
      for (var path in _pickedFilesPaths) {
        try {
          File(path).delete(); // Delete temporary files after merging
        } catch (e) {
          log("Error deleting file: $e");
        }
      }
      return mergedPath;
    } catch (e) {
      log("Error merging PDFs: $e");
      return null;
    }
  }

  Future<void> _fileSaver() async {
    if (_mergedPDFsPath == null) return;
    setState(() => _isBusy = true);
    try {
      await _pickOrSavePlugin.fileSaver(
        params: FileSaverParams(
          saveFiles: [
            SaveFileInfo(filePath: _mergedPDFsPath!, fileName: "MergedPDF.pdf")
          ],
        ),
      );
    } catch (e) {
      log("Error saving file: $e");
    } finally {
      setState(() => _isBusy = false);
    }
  }

  Widget _buildFileItem(String filePath) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Chip(
        label: SizedBox(
          width: 180, // Limit the display width
          child: Text(
            filePath.split('/').last,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        deleteIcon: const Icon(Icons.cancel, color: Colors.red),
        onDeleted: () {
          setState(() {
            _pickedFilesPaths.remove(filePath);
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Merge PDFs', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.picture_as_pdf, color: Colors.blueGrey, size: 80),
                const SizedBox(height: 20),
                const Text(
                  "Merge PDF Files",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                ),
                const SizedBox(height: 20),
                if (_pickedFilesPaths.isNotEmpty)
                  SizedBox(
                    height: 200,
                    child: SingleChildScrollView(
                      child: Wrap(
                        children: _pickedFilesPaths.map(_buildFileItem).toList(),
                      ),
                    ),
                  ),
                const SizedBox(height: 15),
                ElevatedButton.icon(
                  icon: const Icon(Icons.file_open),
                  label: const Text("Pick PDF Files"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                    backgroundColor: Colors.blueGrey,
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  onPressed: _isBusy
                      ? null
                      : () async {
                    final result = await _filePicker();
                    setState(() {
                      _pickedFilesPaths.addAll(result ?? []);
                    });
                  },
                ),
                const SizedBox(height: 15),
                ElevatedButton.icon(
                  icon: const Icon(Icons.merge_type),
                  label: const Text("Merge PDFs"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                    backgroundColor: Colors.green,
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  onPressed: _pickedFilesPaths.length > 1
                      ? () async {
                    setState(() => _isBusy = true);
                    final mergedPath = await _mergePDFs();
                    setState(() {
                      _isBusy = false;
                      _mergedPDFsPath = mergedPath;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("PDFs merged successfully!")),
                    );
                  }
                      : null,
                ),
                const SizedBox(height: 15),
                ElevatedButton.icon(
                  icon: const Icon(Icons.save_alt),
                  label: const Text("Save Merged PDF"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                    backgroundColor: Colors.teal,
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  onPressed: _mergedPDFsPath != null
                      ? () async {
                    await _fileSaver();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("File saved successfully")),
                    );
                  }
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
