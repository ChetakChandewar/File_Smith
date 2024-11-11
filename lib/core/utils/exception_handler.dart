import 'dart:io';
import 'package:flutter/material.dart';

class ExceptionHandler {
  // Handle network exceptions
  static void handleNetworkException(Object e, BuildContext context) {
    if (e is SocketException) {
      _showErrorDialog(context, "No internet connection. Please check your network.");
    } else {
      _showErrorDialog(context, "An unknown network error occurred.");
    }
  }

  // Handle permission-related exceptions
  static void handlePermissionException(Object e, BuildContext context) {
    if (e is FileSystemException) {
      _showErrorDialog(context, "Storage permission denied. Please allow storage access.");
    } else {
      _showErrorDialog(context, "An unknown permission error occurred.");
    }
  }

  // Handle file read/write exceptions
  static void handleFileException(Object e, BuildContext context) {
    if (e is FileSystemException) {
      _showErrorDialog(context, "File system error. Please check file path or permissions.");
    } else {
      _showErrorDialog(context, "An unknown file system error occurred.");
    }
  }

  // General exception handler
  static void handleGeneralException(Object e, BuildContext context) {
    _showErrorDialog(context, e.toString());
  }

  // Show error in a dialog
  static void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Show error in a snackbar
  static void showErrorSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
