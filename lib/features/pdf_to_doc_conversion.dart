import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart'; // Import fixed
import 'package:http/http.dart' as http; // Import fixed
import 'dart:convert';

import '../core/utils/exception_handler.dart';

class PdfToDocConversion extends StatefulWidget {
  const PdfToDocConversion({super.key});

  @override
  _PdfToDocConversionState createState() => _PdfToDocConversionState();
}

class _PdfToDocConversionState extends State<PdfToDocConversion> {
  File? _selectedFile;
  bool _isLoading = false;
  String? _convertedFileName;

  final String _apiKey = 'your_cloudconvert_api_key';

  Future<void> _selectFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
        });
      } else {
        ExceptionHandler.showErrorSnackBar(context, "No file selected.");
      }
    } catch (e) {
      ExceptionHandler.handleGeneralException(e as Exception, context); // Fixed casting
    }
  }

  Future<void> _convertPdfToDoc() async {
    if (_selectedFile == null) {
      ExceptionHandler.showErrorSnackBar(context, "Please select a PDF file first.");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      var response = await http.post(
        Uri.parse('https://api.cloudconvert.com/v2/jobs'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'tasks': {
            'import-1': {
              'operation': 'import/upload',
            },
            'task-1': {
              'operation': 'convert',
              'input': 'import-1',
              'output_format': 'doc',
            },
            'export-1': {
              'operation': 'export/url',
              'input': 'task-1',
            }
          }
        }),
      );

      if (response.statusCode == 201) {
        var jobData = jsonDecode(response.body);
        String uploadUrl = jobData['data']['tasks'][0]['result']['form']['url'];

        var uploadResponse = await http.put(
          Uri.parse(uploadUrl),
          headers: {'Content-Type': 'multipart/form-data'},
          body: _selectedFile!.readAsBytesSync(),
        );

        if (uploadResponse.statusCode == 200) {
          var downloadUrl = jobData['data']['tasks'][2]['result']['files'][0]['url'];
          _saveFile(downloadUrl);
        }
      } else {
        throw Exception("Failed to create conversion job.");
      }
    } catch (e) {
      ExceptionHandler.handleGeneralException(e as Exception, context); // Fixed casting
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveFile(String downloadUrl) async {
    try {
      String? customFileName = await _promptFileName();
      if (customFileName == null || customFileName.isEmpty) return;

      Directory? directory = await getExternalStorageDirectory(); // Method fixed
      if (directory != null) {
        String filePath = '${directory.path}/$customFileName.doc';
        var response = await http.get(Uri.parse(downloadUrl));
        File file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        ExceptionHandler.showErrorSnackBar(context, "File saved as $customFileName.doc");
      } else {
        throw Exception("Could not access storage.");
      }
    } catch (e) {
      ExceptionHandler.handleGeneralException(e as Exception, context); // Fixed casting
    }
  }

  Future<String?> _promptFileName() async {
    String? fileName;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter File Name'),
          content: TextField(
            onChanged: (value) {
              fileName = value;
            },
            decoration: const InputDecoration(hintText: "Enter file name"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    return fileName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF to DOC Conversion'),
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _selectFile,
              child: const Text('Select PDF File'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _convertPdfToDoc,
              child: const Text('Convert to DOC'),
            ),
          ],
        ),
      ),
    );
  }
}
