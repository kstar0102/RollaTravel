import 'package:RollaTravel/src/constants/app_styles.dart';
import 'package:RollaTravel/src/screen/droppin/photo_select_screen.dart';
import 'package:RollaTravel/src/screen/droppin/select_locaiton_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:RollaTravel/src/utils/index.dart';
import 'package:RollaTravel/src/widget/bottombar.dart';
import 'package:latlong2/latlong.dart';
import 'package:logger/logger.dart';

class TakePictureScreen extends ConsumerStatefulWidget {
  final String imagePath;

  const TakePictureScreen({super.key, required this.imagePath});

  @override
  ConsumerState<TakePictureScreen> createState() => TakePictureScreenState();
}

class TakePictureScreenState extends ConsumerState<TakePictureScreen> {
  bool showLikes = true;
  final logger = Logger();
  final int _currentIndex = 3;
  final LatLng photoLocation = const LatLng(0, 0);
  final TextEditingController _captionController = TextEditingController();
  int _currentLength = 0;

  @override
  void initState() {
    super.initState();
    _captionController.addListener(_updateTextLength);
  }

  @override
  void dispose() {
    _captionController.removeListener(_updateTextLength);
    _captionController.dispose();
    super.dispose();
  }

  void _updateTextLength() {
    setState(() {
      _currentLength = _captionController.text.length;
    });
  }

  Future<void> _handleLocationSelection() async {
    // logger.i(showLikes);
    if (_captionController.text.isEmpty) {
      // Show error dialog if caption is empty
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Warning!'),
          content: const Text('Please enter a caption before proceeding.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    // Navigate to the next screen with the entered caption
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectLocationScreen(
          selectedLocation: photoLocation,
          caption: _captionController.text,
          imagePath: widget.imagePath,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevents default back navigation
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          return; // Prevent pop action
        }
      },
      child: Scaffold(
        backgroundColor: kColorWhite,
        body: SizedBox.expand(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: vhh(context, 5)),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset(
                        'assets/images/icons/logo.png',
                        width: 90,
                        height: 80,
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 30),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const PhotoSelectScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Image with overlays in a constrained height
                SizedBox(
                  height: vhh(context, 60),
                  width: vww(context, 96),
                  child: Stack(
                    children: [
                      // Display the image as the background with constrained height
                      Center(
                        child: widget.imagePath.isNotEmpty
                            ? SizedBox(
                                width: vww(context, 100), // Set width
                                height: vhh(context, 100), // Set height
                                child: Image.file(
                                  File(widget.imagePath),
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Center(
                                child: Text(
                                'No image selected.',
                                style: TextStyle(fontFamily: 'inter'),
                              )),
                      ),

                      // Overlay elements on top of the image
                      Column(
                        children: [
                          // Caption text field with padding and blue border
                          // Padding(
                          //   padding: const EdgeInsets.all(10.0),
                          //   child: Container(
                          //     color: Colors.transparent,
                          //     child: TextField(
                          //       controller: _captionController,
                          //       textInputAction: TextInputAction.done,
                          //       maxLines: 2,
                          //       decoration: InputDecoration(
                          //         hintText: 'Caption...',
                          //         hintStyle:
                          //             const TextStyle(fontFamily: 'inter'),
                          //         filled: true,
                          //         fillColor:
                          //             Colors.white.withValues(alpha: 0.95),
                          //         contentPadding: const EdgeInsets.symmetric(
                          //             horizontal: 10, vertical: 8),
                          //       ),
                          //       style: const TextStyle(fontFamily: 'inter'),
                          //     ),
                          //   ),
                          // ),

                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  color: Colors.transparent,
                                  child: TextField(
                                    controller: _captionController,
                                    textInputAction: TextInputAction.done,
                                    maxLines: 2,
                                    maxLength: 100, 
                                    decoration: InputDecoration(
                                      hintText: 'Caption...',
                                      hintStyle: const TextStyle(fontFamily: 'inter'),
                                      filled: true,
                                      fillColor: Colors.white.withValues(alpha: 0.95),
                                      contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 8),
                                      counterText: '$_currentLength/100', 
                                      counterStyle: const TextStyle(
                                        fontFamily: 'inter',
                                        fontSize: 10,
                                        letterSpacing: -0.1,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    style: const TextStyle(fontFamily: 'inter'),
                                  ),
                                ),
                                Text(
                                  '${_captionController.text.length}/100',
                                  style: const TextStyle(
                                    fontFamily: 'inter',
                                    fontSize: 10,
                                    letterSpacing: -0.1,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                // Select Location button
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.6),
                            offset: const Offset(0, 5),
                            blurRadius: 10,
                            spreadRadius: -2,
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _handleLocationSelection,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          backgroundColor: kColorButtonPrimary,
                          minimumSize: const Size(150, 30),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Select Location',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'inter',
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.1,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomNavBar(currentIndex: _currentIndex),
      ),
    );
  }
}
