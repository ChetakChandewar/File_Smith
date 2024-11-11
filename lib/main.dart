import 'package:file_smith/presentation/view/home_screen.dart';
import 'package:file_smith/presentation/view/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/provider/app_state.dart';
import 'data/provider/drawer_state_provider.dart';
import 'features/merge_pdf_screen.dart';
import 'features/pdf_to_doc_conversion.dart';


void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
        ChangeNotifierProvider(create: (_) => DrawerStateProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FileSmith',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SplashScreen(),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/pdfToDoc': (context) => const PdfToDocConversion(),
        '/pdfMerge': (context) => const MergePDFScreen(),
        // '/docToPdf': (context) => const DocToPdfConversionScreen(),
        // Add more routes for other features like Speech to Text, Summarization, etc.
        // '/speechToText': (context) => SpeechToTextScreen(),
        // '/summarization': (context) => SummarizationScreen(),
        // etc.
      },
    );
  }
}
