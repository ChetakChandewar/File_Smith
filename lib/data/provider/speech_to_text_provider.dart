import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:pick_or_save/pick_or_save.dart';

class SpeechToTextProvider with ChangeNotifier {
  final SpeechToText _speech = SpeechToText();
  bool _isListening = false;
  bool _shouldListen = false; // flag to allow continuous listening

  // Hold final (committed) text and any ongoing partial text.
  String _finalText = "";
  String _partialText = "";

  /// Combine final text with any ongoing partial result.
  String get noteText =>
      _finalText + (_partialText.isNotEmpty ? " " + _partialText : "");

  bool get isListening => _isListening;

  // Instance of your file saving plugin.
  final PickOrSave _pickOrSavePlugin = PickOrSave(); // Adjust according to your initialization

  Future<void> initSpeech() async {
    // Check and request microphone permission.
    if (await Permission.microphone.request().isGranted) {
      try {
        await _speech.initialize(
          onStatus: (status) {
            if (status == "notListening") {
              _isListening = false;
              notifyListeners();
              // Only auto-restart if the user wants continuous listening.
              if (_shouldListen) {
                startListening();
              }
            }
          },
          onError: (error) {
            debugPrint("Speech recognition error: $error");
            _isListening = false;
            _shouldListen = false;
            notifyListeners();
          },
        );
      } catch (e) {
        debugPrint("Error initializing speech recognition: $e");
        // Optionally, you may set an error message variable here and notifyListeners.
      }
    } else {
      debugPrint("Microphone permission denied.");
      // Optionally, you may want to throw an exception here.
    }
  }

  /// Starts listening continuously.
  void startListening() async {
    if (!_isListening) {
      _shouldListen = true;
      _isListening = true;
      notifyListeners();

      try {
        await _speech.listen(
          onResult: (result) {
            // Process the speech recognition result.
            if (result.finalResult) {
              _finalText += " " + result.recognizedWords;
              _partialText = "";
            } else {
              _partialText = result.recognizedWords;
            }
            notifyListeners();
          },
          listenMode: ListenMode.dictation,
          cancelOnError: false,
          partialResults: true,
        );
      } catch (e) {
        debugPrint("Error starting listening: $e");
        _isListening = false;
        notifyListeners();
      }
    }
  }

  /// Stops listening (and prevents auto-restarting).
  void stopListening() {
    try {
      _shouldListen = false;
      _isListening = false;
      _speech.stop();
      notifyListeners();
    } catch (e) {
      debugPrint("Error stopping listening: $e");
      // You might want to update state or show a UI error.
    }
  }

  // Allow manual text editing; update the committed text.
  void setText(String text) {
    try {
      _finalText = text;
      _partialText = "";
      notifyListeners();
    } catch (e) {
      debugPrint("Error setting text: $e");
    }
  }

  // Clear all saved text.
  void clearNote() {
    try {
      _finalText = "";
      _partialText = "";
      notifyListeners();
    } catch (e) {
      debugPrint("Error clearing text: $e");
    }
  }

  /// Saves the recognized text as a PDF using custom logic.
  Future<void> saveTextAsPdf(BuildContext context, String text) async {
    try {
      final pdf = pw.Document();

      // Load custom font for better rendering.
      final fontData = await rootBundle.load("assets/fonts/calibri-regular.ttf");
      final ttf = pw.Font.ttf(fontData);

      // Split the text into multiple pages.
      const int maxCharsPerPage = 1000; // Adjust as needed.
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

      // Generate a temporary file.
      final directory = await Directory.systemTemp.createTemp();
      String tempPath = '${directory.path}/recognized_text.pdf';
      File tempFile = File(tempPath);
      await tempFile.writeAsBytes(await pdf.save());

      // Save file using your file saving plugin.
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
      debugPrint("Error saving PDF: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving PDF: $e")),
      );
    }
  }

  /// Helper method to split large text into chunks not exceeding [maxChars].
  List<String> _splitTextIntoPages(String text, int maxChars) {
    List<String> pages = [];
    try {
      for (int i = 0; i < text.length; i += maxChars) {
        int end = i + maxChars;
        if (end > text.length) end = text.length;
        pages.add(text.substring(i, end));
      }
    } catch (e) {
      debugPrint("Error splitting text into pages: $e");
    }
    return pages;
  }
}
