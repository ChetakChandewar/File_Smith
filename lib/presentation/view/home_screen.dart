import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/provider/drawer_state_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final drawerProvider = Provider.of<DrawerStateProvider>(context);

    return Scaffold(
      key: drawerProvider.scaffoldKey,
      appBar: AppBar(
        title: const Text('Home Screen'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            drawerProvider.openDrawer(); // Open the drawer via Provider
          },
        ),
      ),
      drawer: _buildDrawer(), // Drawer content
      body: LayoutBuilder(
        builder: (context, constraints) {
          int crossAxisCount = _getCrossAxisCount(constraints.maxWidth);
          return GridView.count(
            crossAxisCount: crossAxisCount,
            padding: const EdgeInsets.all(16.0),
            childAspectRatio: 1.5, // Adjust aspect ratio
            children: <Widget>[
              _buildFeatureBlock(context, 'Extract Text', Icons.text_fields, '/extractText'),
              _buildFeatureBlock(context, 'Speech to Text', Icons.mic, '/speechToText'),
              _buildFeatureBlock(context, 'Summarization', Icons.summarize, '/summarization'),
              _buildFeatureBlock(context, 'PDF to Word', Icons.picture_as_pdf, '/pdfToDoc'),
              _buildFeatureBlock(context, 'Images to PDF', Icons.image, '/imagesToPdf'),
              _buildFeatureBlock(context, 'PDF Merge', Icons.merge_type, '/pdfMerge'),
              _buildFeatureBlock(context, 'PDF to XLS', Icons.table_chart, '/pdfToXls'),
              _buildFeatureBlock(context, 'XLS to PDF', Icons.picture_as_pdf, '/xlsToPdf'),
              _buildFeatureBlock(context, 'Doc to PDF', Icons.article, '/docsToPdf'),
              _buildFeatureBlock(context, 'PPT to PDF', Icons.slideshow, '/pptToPdf'),
              _buildFeatureBlock(context, 'PDF to PPT', Icons.picture_as_pdf, '/pdfToPpt'),
              _buildFeatureBlock(context, 'AI Tools', Icons.smart_toy, '/aiTools'), // New AI Tools block
            ],
          );
        },
      ),
    );
  }

  int _getCrossAxisCount(double width) {
    if (width < 600) return 2; // Mobile
    if (width < 900) return 3; // Small Tablet
    if (width < 1200) return 4; // Large Tablet
    return 6; // Desktop and larger screens
  }

  Widget _buildFeatureBlock(BuildContext context, String title, IconData icon, String route) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, route);
      },
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 50, color: Colors.blue),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text(
              'Menu',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
