import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ImageToPdfProvider extends ChangeNotifier {
  List<File> _selectedImages = [];
  pw.Document _pdfDocument = pw.Document();
  bool _isGenerating = false;
  double _generationProgress = 0.0;

  List<File> get selectedImages => _selectedImages;
  pw.Document get pdfDocument => _pdfDocument;
  bool get isGenerating => _isGenerating;
  double get generationProgress => _generationProgress;

  void addImage(File image) {
    _selectedImages.add(image);
    notifyListeners();
  }

  void removeImage(int index) {
    _selectedImages.removeAt(index);
    notifyListeners();
  }

  void reorderImages(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final File item = _selectedImages.removeAt(oldIndex);
    _selectedImages.insert(newIndex, item);
    notifyListeners();
  }

  void clearAll() {
    _selectedImages.clear();
    _pdfDocument = pw.Document();
    notifyListeners();
  }

  Future<void> generatePdf() async {
    _isGenerating = true;
    _generationProgress = 0.0;
    notifyListeners();

    try {
      for (int i = 0; i < _selectedImages.length; i++) {
        final imageFile = _selectedImages[i];
        try {
          final image = pw.MemoryImage(imageFile.readAsBytesSync());
          _pdfDocument.addPage(
            pw.Page(
              build: (context) => pw.Center(child: pw.Image(image)),
            ),
          );
        } catch (e) {
          print('Error processing image ${imageFile.path}: $e');
        }
        _generationProgress = (i + 1) / _selectedImages.length;
        notifyListeners();
      }
    } catch (e) {
      print('Error generating PDF: $e');
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }

  Future<void> savePdf(Uint8List bytes, String fileName) async {
    try {
      final file = File(fileName);
      await file.writeAsBytes(bytes, flush: true);
      print('PDF saved at $fileName');
      clearAll();
    } catch (e) {
      print('Error saving PDF: $e');
    }
  }

  Future<void> clearCache() async {
    try {
      final tempDir = await getTemporaryDirectory();
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
        print('Cache cleared');
      }
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }

  @override
  void dispose() {
    clearCache(); // Clear cache when the provider is disposed
    super.dispose();
  }
}
