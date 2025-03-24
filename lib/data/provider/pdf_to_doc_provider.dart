import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:pick_or_save/pick_or_save.dart';

class PdfDocConverterProvider extends ChangeNotifier {
  bool _isConverting = false;
  String? _convertedFilePath;
  String? _errorMessage;

  bool get isConverting => _isConverting;
  String? get convertedFilePath => _convertedFilePath;
  String? get errorMessage => _errorMessage;

  final Dio _dio = Dio();
  final PickOrSave _pickOrSavePlugin = PickOrSave();

  Future<void> convertPdfToDocx(File pdfFile) async {
    _isConverting = true;
    _convertedFilePath = null;
    _errorMessage = null;
    notifyListeners();

    try {
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(pdfFile.path, filename: "upload.pdf"),
      });

      Response response = await _dio.post(
        "https://pdftodoc-server.onrender.com/convert",
        data: formData,
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.statusCode == 200) {
        String savePath = "${pdfFile.parent.path}/converted.docx";
        File docxFile = File(savePath);
        await docxFile.writeAsBytes(response.data);
        _convertedFilePath = savePath;
      } else {
        _errorMessage = "Conversion failed: ${response.statusMessage}";
      }
    } catch (e) {
      _errorMessage = "Error: $e";
    } finally {
      _isConverting = false;
      notifyListeners();
    }
  }

  Future<void> saveConvertedFile() async {
    if (_convertedFilePath == null) return;
    try {
      await _pickOrSavePlugin.fileSaver(
        params: FileSaverParams(
          saveFiles: [
            SaveFileInfo(filePath: _convertedFilePath!, fileName: "ConvertedFile.docx"),
          ],
        ),
      );
    } catch (e) {
      _errorMessage = "Error saving file: $e";
      notifyListeners();
    }
  }
}
