import 'dart:io';
import 'package:flutter/material.dart';

class ImageListView extends StatelessWidget {
  final List<File> images;

  const ImageListView({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: images.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.file(images[index], height: 200, fit: BoxFit.cover),
        );
      },
    );
  }
}
