import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/provider/speech_to_text_provider.dart';

class SpeechToTextScreen extends StatefulWidget {
  const SpeechToTextScreen({super.key});

  @override
  _SpeechToTextScreenState createState() => _SpeechToTextScreenState();
}

class _SpeechToTextScreenState extends State<SpeechToTextScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Initialize speech recognition after the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SpeechToTextProvider>(context, listen: false).initSpeech();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SpeechToTextProvider>(
      builder: (context, speechProvider, child) {
        // Only update controller text if the TextField is not focused.
        if (!_focusNode.hasFocus &&
            _textController.text != speechProvider.noteText) {
          _textController.value = TextEditingValue(
            text: speechProvider.noteText,
            selection: TextSelection.fromPosition(
              TextPosition(offset: speechProvider.noteText.length),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text("Speech to Text Notes"),
            actions: [
              IconButton(
                icon: Icon(Icons.delete),
                tooltip: "Clear Text",
                onPressed: () {
                  try {
                    speechProvider.clearNote();
                  } catch (e) {
                    debugPrint("Error clearing text via UI: $e");
                  }
                },
              )
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: TextField(
                      focusNode: _focusNode,
                      controller: _textController,
                      maxLines: null,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        hintText: "Your transcription will appear here...",
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.all(12.0),
                      ),
                      onChanged: (text) => speechProvider.setText(text),
                      onEditingComplete: () {
                        // Remove focus when editing is complete.
                        _focusNode.unfocus();
                      },
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FloatingActionButton.extended(
                      heroTag: "listen",
                      backgroundColor:
                      speechProvider.isListening ? Colors.red : Colors.green,
                      icon: Icon(speechProvider.isListening ? Icons.mic_off : Icons.mic),
                      label:
                      Text(speechProvider.isListening ? "Stop Mic" : "Start Mic"),
                      onPressed: () {
                        // Unfocus the text field so that recognized speech can be updated.
                        _focusNode.unfocus();
                        try {
                          if (speechProvider.isListening) {
                            speechProvider.stopListening();
                          } else {
                            speechProvider.startListening();
                          }
                        } catch (e) {
                          debugPrint("Error toggling mic: $e");
                        }
                      },
                    ),
                    FloatingActionButton.extended(
                      heroTag: "pdf",
                      backgroundColor: Colors.purple,
                      icon: Icon(Icons.picture_as_pdf),
                      label: Text("Save PDF"),
                      onPressed: () async {
                        try {
                          await speechProvider.saveTextAsPdf(context, speechProvider.noteText);
                        } catch (e) {
                          debugPrint("Error saving PDF via UI: $e");
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
