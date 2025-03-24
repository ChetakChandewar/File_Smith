import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';

import '../data/provider/pdf_to_doc_provider.dart';

class PdfDocConverterScreen extends StatefulWidget {
  const PdfDocConverterScreen({super.key});

  @override
  _PdfDocConverterScreenState createState() => _PdfDocConverterScreenState();
}

class _PdfDocConverterScreenState extends State<PdfDocConverterScreen> {
  File? _selectedFile;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PdfDocConverterProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text("PDF to DOC Converter")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _selectedFile != null
                ? Text(
              "Selected File: ${_selectedFile!.path.split('/').last}",
              style: TextStyle(fontWeight: FontWeight.bold),
            )
                : Text("No file selected", style: TextStyle(color: Colors.red)),
            SizedBox(height: 20),

            // Pick File Button
            ElevatedButton.icon(
              icon: Icon(Icons.upload_file),
              label: Text("Select PDF"),
              onPressed: _pickFile,
            ),

            SizedBox(height: 20),

            // Convert File Button with Loader
            ElevatedButton.icon(
              icon: provider.isConverting ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator()) : Icon(Icons.sync),
              label: provider.isConverting ? Text("Converting...") : Text("Convert to DOC"),
              onPressed: provider.isConverting || _selectedFile == null
                  ? null
                  : () => provider.convertPdfToDocx(_selectedFile!),
            ),

            SizedBox(height: 20),

            // Show Success Message & Open/Save Buttons
            if (provider.convertedFilePath != null) ...[
              Text(
                "Conversion Completed!",
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
              ),
              SizedBox(height: 10),
              ElevatedButton.icon(
                icon: Icon(Icons.open_in_new),
                label: Text("Open DOC"),
                onPressed: () => OpenFilex.open(provider.convertedFilePath!),
              ),
              SizedBox(height: 10),
              ElevatedButton.icon(
                icon: Icon(Icons.save),
                label: Text("Save DOC"),
                onPressed: provider.saveConvertedFile,
              ),
            ],

            // Show Error Message if Any
            if (provider.errorMessage != null)
              Padding(
                padding: EdgeInsets.only(top: 20),
                child: Text(
                  provider.errorMessage!,
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
