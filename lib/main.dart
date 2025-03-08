import 'package:file_smith/data/provider/docs_to_pdf_provider.dart';
import 'package:file_smith/features/DocsToPdfScreen.dart';
import 'package:file_smith/features/ImageToPdfScreen.dart';
import 'package:file_smith/features/PptToPdfScreen.dart';
import 'package:file_smith/features/imgToTextScreen.dart';
import 'package:file_smith/presentation/view/home_screen.dart';
import 'package:file_smith/presentation/view/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/services/app_localizations.dart';
import 'data/provider/app_state.dart';
import 'data/provider/drawer_state_provider.dart';
import 'data/provider/imgToTextProvider.dart';
import 'data/provider/img_to_pdf_provider.dart';
import 'features/AIToolsScreen.dart';
import 'features/merge_pdf_screen.dart';
import 'features/pdf_to_doc_conversion.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
        ChangeNotifierProvider(create: (_) => DrawerStateProvider()),
        ChangeNotifierProvider(create: (_) => ImageToPdfProvider()),
        ChangeNotifierProvider(create: (_) => ImgToTextProvider()),

        //ChangeNotifierProvider(create: (_) => DocsToPdfProvider()),
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
        '/imagesToPdf': (context) => const ImageToPdfScreen(),
        '/aiTools': (context) => const AIToolsScreen(),
        '/extractText': (context) => const ImgToTextScreen(),
        //'/pptToPdf': (context) => const PptToPdfScreen(),
        //'/docsToPdf': (context) => const DocsToPdfScreen(),
        // '/docToPdf': (context) => const DocToPdfConversionScreen(),
        // Add more routes for other features like Speech to Text, Summarization, etc.
        // '/speechToText': (context) => SpeechToTextScreen(),
        // '/summarization': (context) => SummarizationScreen(),
        // etc.
      },
    );
  }
}
