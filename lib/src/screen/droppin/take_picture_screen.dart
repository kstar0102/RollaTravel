import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io'; // Import the dart:io package

class TakePictureScreen extends ConsumerStatefulWidget {
  final String imagePath;

  const TakePictureScreen({super.key, required this.imagePath});

  @override
  ConsumerState<TakePictureScreen> createState() => TakePictureScreenState();
}

class TakePictureScreenState extends ConsumerState<TakePictureScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Take a Picture'),
      ),
      body: Center(
        child: widget.imagePath.isNotEmpty
            ? Image.file(File(widget.imagePath))
            : const Text('No image selected.'),
      ),
    );
  }
}