import 'dart:io';

import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import '../utils/exception_handler.dart';

class PermissionsService {
  // Request storage permission
  Future<bool> requestStoragePermission(BuildContext context) async {
    try {
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        final result = await Permission.storage.request();
        if (result != PermissionStatus.granted) {
          ExceptionHandler.handlePermissionException(const FileSystemException("Storage permission denied"), context);
          return false;
        }
      }
      return true;
    } catch (e) {
      // Catching dynamic instead of Exception
      ExceptionHandler.handlePermissionException(e as dynamic, context);
      return false;
    }
  }

  // Request microphone permission
  Future<bool> requestMicrophonePermission(BuildContext context) async {
    try {
      var status = await Permission.microphone.status;
      if (!status.isGranted) {
        final result = await Permission.microphone.request();
        if (result != PermissionStatus.granted) {
          ExceptionHandler.handlePermissionException(const FileSystemException("Microphone permission denied"), context);
          return false;
        }
      }
      return true;
    } catch (e) {
      ExceptionHandler.handlePermissionException(e as dynamic, context);
      return false;
    }
  }

  // Check if the permission is granted
  Future<bool> checkPermissionStatus(Permission permission, BuildContext context) async {
    try {
      var status = await permission.status;
      if (!status.isGranted) {
        ExceptionHandler.handlePermissionException(const FileSystemException("Permission not granted"), context);
        return false;
      }
      return true;
    } catch (e) {
      ExceptionHandler.handlePermissionException(e as dynamic, context);
      return false;
    }
  }
}
