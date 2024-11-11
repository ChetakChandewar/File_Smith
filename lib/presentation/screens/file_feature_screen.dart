import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../../core/services/permissions_service.dart';
import '../../core/utils/exception_handler.dart';


class FileFeatureScreen extends StatefulWidget {
  final String featureTitle;
  final IconData featureIcon;

  const FileFeatureScreen({super.key, required this.featureTitle, required this.featureIcon});

  @override
  _FileFeatureScreenState createState() => _FileFeatureScreenState();
}

class _FileFeatureScreenState extends State<FileFeatureScreen> {
  final PermissionsService _permissionsService = PermissionsService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.featureTitle),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _handleFileSelection,
          child: Text('Select File for ${widget.featureTitle}'),
        ),
      ),
    );
  }

  Future<void> _handleFileSelection() async {
    try {
      // Check storage permission
      bool permissionGranted = await _permissionsService.requestStoragePermission(context);
      if (!permissionGranted) return;

      // Open file picker
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null) {
        String? filePath = result.files.single.path;
        if (filePath != null) {
          // Perform the conversion logic here (e.g., PDF to Word conversion)
          // Save the file after conversion and handle exceptions
        } else {
          ExceptionHandler.handleGeneralException(Exception("File path is null"), context);
        }
      }
    } catch (e) {
      ExceptionHandler.handleFileException(e as Exception, context);
    }
  }
}
