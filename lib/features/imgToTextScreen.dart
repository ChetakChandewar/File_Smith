import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/provider/imgToTextProvider.dart';

class ImgToTextScreen extends StatelessWidget {
  const ImgToTextScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Provider.of<ImgToTextProvider>(context, listen: false).clearText();
        return true; // Allow back navigation
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Image to Text Recognition'),
          actions: [
            Consumer<ImgToTextProvider>(
              builder: (context, provider, _) => IconButton(
                icon: Icon(provider.isSpeaking ? Icons.stop : Icons.volume_up),
                onPressed: provider.recognizedText.isNotEmpty
                    ? provider.speakText
                    : null,
              ),
            ),
            Consumer<ImgToTextProvider>(
              builder: (context, provider, _) => IconButton(
                icon: const Icon(Icons.clear),
                onPressed: provider.recognizedText.isNotEmpty
                    ? provider.clearText
                    : null,
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Consumer<ImgToTextProvider>(
            builder: (context, provider, _) => Column(
              children: [
                Expanded(
                  child: provider.recognizedText.isNotEmpty
                      ? SingleChildScrollView(
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: TextField(
                          controller: provider.textController,
                          maxLines: null,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            labelText: 'Edit Recognized Text',
                            filled: true,
                            fillColor: Colors.grey[100],
                          ),
                          onChanged: provider.updateRecognizedText,
                        ),
                      ),
                    ),
                  )
                      : const Center(
                    child: Text(
                      'Tap the camera or gallery button to recognize text!',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: SafeArea( // Moved SafeArea here
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Consumer<ImgToTextProvider>(
              builder: (context, provider, _) => Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () async => await provider.pickImageFromCamera(context),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async => await provider.pickImagesFromGallery(context),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                  ),
                  if (provider.recognizedText.isNotEmpty) ...[
                    ElevatedButton.icon(
                      onPressed: () => provider.copyToClipboard(context),
                      icon: const Icon(Icons.content_copy),
                      label: const Text('Copy'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () async {
                        String textToSave = provider.recognizedText;
                        await provider.saveTextAsPdf(context, textToSave);
                      },
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text('PDF'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}