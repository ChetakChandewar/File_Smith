import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SummarizationProvider extends ChangeNotifier {
  String _transcript = "";
  String _summary = "";
  bool _isLoading = false;
  String _errorMessage = "";

  String get transcript => _transcript;
  String get summary => _summary;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  final String _serverUrl = "https://yttranscriptserver-production.up.railway.app/transcribe"; // Replace with your Railway server URL

  Future<void> fetchSummarization(String videoUrl) async {
    if (videoUrl.isEmpty) {
      _errorMessage = "Please enter a valid YouTube URL.";
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = "";
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse(_serverUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"video_url": videoUrl}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _transcript = data["transcript"];
        _summary = data["summary"];
      } else {
        _errorMessage = "Error: ${response.body}";
      }
    } catch (e) {
      _errorMessage = "Failed to connect to server. Check your internet connection.";
    }

    _isLoading = false;
    notifyListeners();
  }
}
