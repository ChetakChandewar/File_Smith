import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/provider/summarization_provider.dart';

class SummarizationScreen extends StatelessWidget {
  final TextEditingController _urlController = TextEditingController();

  SummarizationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final summarizationProvider = Provider.of<SummarizationProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text("YouTube Video Summarization")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: "Enter YouTube Video URL",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                final videoUrl = _urlController.text.trim();
                if (videoUrl.isNotEmpty) {
                  summarizationProvider.fetchSummarization(videoUrl);
                }
              },
              child: Text("Get Transcript & Summary"),
            ),
            SizedBox(height: 20),
            summarizationProvider.isLoading
                ? Center(child: CircularProgressIndicator())
                : summarizationProvider.errorMessage.isNotEmpty
                ? Text(
              summarizationProvider.errorMessage,
              style: TextStyle(color: Colors.red),
            )
                : Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Summary:",
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(summarizationProvider.summary),
                    SizedBox(height: 20),
                    Text(
                      "Full Transcript:",
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(summarizationProvider.transcript),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
