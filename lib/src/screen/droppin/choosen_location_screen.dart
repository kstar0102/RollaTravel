import 'dart:ui' as ui;

import 'package:RollaTravel/src/screen/home/home_sound_screen.dart';
import 'package:RollaTravel/src/screen/trip/start_trip.dart';
import 'package:RollaTravel/src/utils/global_variable.dart';
import 'package:RollaTravel/src/utils/spinner_loader.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:RollaTravel/src/utils/index.dart';
import 'package:RollaTravel/src/widget/bottombar.dart';
import 'package:RollaTravel/src/translate/en.dart';
import 'package:RollaTravel/src/constants/app_styles.dart';
import 'package:latlong2/latlong.dart';
import 'dart:io';
import 'dart:ui';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ChoosenLocationScreen extends ConsumerStatefulWidget {
  final LatLng? location;
  final String caption;
  final String imagePath;
  final String soundList;

  const ChoosenLocationScreen(
      {super.key,
      required this.caption,
      required this.imagePath,
      required this.location,
      required this.soundList});

  @override
  ConsumerState<ChoosenLocationScreen> createState() =>
      ChoosenLocationScreenState();
}

class ChoosenLocationScreenState extends ConsumerState<ChoosenLocationScreen> {
  double screenHeight = 0;
  double keyboardHeight = 0;
  final int _currentIndex = 3;
  bool isuploadingImage = false;
  String? startAddress;
  String stopAddressesString = "";
  String? tripMiles;
  List<String> formattedStopAddresses = [];
  List<Map<String, dynamic>> droppins = [];
  String? droppinsJson;
  final logger = Logger();
  final GlobalKey _shareWidgetKey = GlobalKey();
  bool _isSharing = false; 

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
        if (mounted) {
          setState(() {
            this.keyboardHeight = keyboardHeight;
          });
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onCloseClicked() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const StartTripScreen()));
  }

  // Future<XFile> _getImageFileFromAssets(String assetPath) async {
  //   final byteData = await rootBundle.load(assetPath);
  //   final tempDir = await getTemporaryDirectory();
  //   final file = File('${tempDir.path}/${assetPath.split('/').last}');
  //   await file.writeAsBytes(byteData.buffer.asUint8List());
  //   return XFile(file.path);
  // }

  // Future<void> _onTestShareClicked() async {
  //   try {
  //     if (!mounted) return;
  //      final xfile = await _getImageFileFromAssets('assets/images/background/1.png');
  //     await Share.shareXFiles(
  //       [xfile],
  //       subject: 'Rolla Travel trip!',
  //       text: 'I just created a trip with Rolla Travel!',
  //     );

  //     logger.i("Share completed");
  //   } catch (e) {
  //     if (!mounted) return;
  //     _showErrorDialog("Sharing failed: ${e.toString().replaceAll('Exception: ', '')}");
  //     logger.e("Sharing error: $e");
  //   }
  // }

  // Future<void> _onShareClicked() async {
  //   if (_isSharing) return;
  //   setState(() => _isSharing = true);
  //   try {
  //     if (!mounted) return;

  //     final boundaryContext = _shareWidgetKey.currentContext;
  //     if (boundaryContext == null) {
  //       _showErrorDialog("Cannot share: Widget not ready.");
  //       return;
  //     }

  //     final boundary = boundaryContext.findRenderObject() as RenderRepaintBoundary?;
  //     if (boundary == null) {
  //       _showErrorDialog("Cannot share: Unable to capture content.");
  //       return;
  //     }

  //     // Wait for rendering if needed
  //     if (boundary.debugNeedsPaint) {
  //       await Future.delayed(const Duration(milliseconds: 100));
  //       await WidgetsBinding.instance.endOfFrame;
  //     }

  //     // Convert widget to image
  //     final image = await boundary.toImage(pixelRatio: 3.0);
  //     final byteData = await image.toByteData(format: ImageByteFormat.png);
  //     if (byteData == null) {
  //       _showErrorDialog("Failed to generate image.");
  //       return;
  //     }

  //     final pngBytes = byteData.buffer.asUint8List();

  //     // Save to temporary file
  //     final tempDir = await getTemporaryDirectory();
  //     final filePath = '${tempDir.path}/shared_polaroid_${DateTime.now().millisecondsSinceEpoch}.png';
  //     final file = File(filePath);
      
  //     await file.writeAsBytes(pngBytes);
  //      // Declare result before usage, assign inside try
  //     try {
  //       await Share.shareXFiles(
  //         [XFile(file.path)],
  //         subject: 'Rolla Travel trip!',
  //         text: 'I just created a trip with Rolla Travel!',
  //       );
  //       logger.i("Share dialog opened successfully");
  //     } catch (e) {
  //       logger.e("in Sharing failed: $e");
  //       if (mounted) _showErrorDialog("in Sharing failed: $e");
  //     }

  //   } catch (e) {
  //     if (!mounted) return;
  //     _showErrorDialog("Sharing failed: ${e.toString().replaceAll('Exception: ', '')}");
  //     logger.e("Sharing error: $e");
  //   } finally {
  //     if (mounted) setState(() => _isSharing = false);
  //   }
  // }
  Future<void> _onShareClicked() async {
    if (_isSharing) return;
    
    setState(() => _isSharing = true);
    
    try {
      // Ensure widget is mounted and ready
      if (!mounted) return;
      await Future.delayed(const Duration(milliseconds: 50)); // Small delay for rendering

      // Get the boundary
      final boundaryContext = _shareWidgetKey.currentContext;
      if (boundaryContext == null || !boundaryContext.mounted) {
        _showErrorDialog("Widget not ready for sharing.");
        return;
      }

      // Wait for the next frame to ensure rendering is complete
      await WidgetsBinding.instance.endOfFrame;
      await Future.delayed(const Duration(milliseconds: 100));

      // ignore: use_build_context_synchronously
      final boundary = boundaryContext.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        _showErrorDialog("Unable to capture content.");
        return;
      }

      // Convert to image with error handling
      ui.Image? image;
      try {
        image = await boundary.toImage(pixelRatio: 3.0);
      } catch (e) {
        logger.e("Image capture error: $e");
        _showErrorDialog("Failed to capture image.");
        return;
      }

      // Convert to bytes
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      if (byteData == null) {
        _showErrorDialog("Failed to convert image.");
        return;
      }

      // Save to file
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${tempDir.path}/rolla_share_$timestamp.png';
      final file = File(filePath);
      
      try {
        await file.writeAsBytes(byteData.buffer.asUint8List());
      } catch (e) {
        logger.e("File write error: $e");
        _showErrorDialog("Failed to save image.");
        return;
      }

      // Share the file with platform-specific handling
      try {
        await Share.shareXFiles(
          [XFile(file.path)],
          subject: 'Rolla Travel trip!',
          text: 'I just created a trip with Rolla Travel!',
        );
        logger.i("Share successful");
      } on PlatformException catch (e) {
        logger.e("Platform sharing error: ${e.message}");
        _showErrorDialog("Sharing failed: ${e.message ?? 'Unknown error'}");
      } catch (e) {
        logger.e("General sharing error: $e");
        _showErrorDialog("Sharing failed: ${e.toString().replaceAll('Exception: ', '')}");
      }
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  /// Helper method to show an error dialog
  void _showErrorDialog(String message) {
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Sharing Failed"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _playListClicked () {
    if (widget.soundList == "tripSound") {
      // Show an alert
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("No playlist"),
            content: const Text("There is no playlist available for this trip."),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  // Close the dialog
                  Navigator.pop(context);
                },
                child: const Text("OK",
                style: TextStyle(color: kColorStrongGrey),),
              ),
            ],
          );
        },
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomeSoundScreen(
            tripSound: widget.soundList,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kColorWhite,
      body: PopScope(
        canPop: !_isSharing,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          if (_isSharing) {
            _showErrorDialog("Please wait while sharing completes");
          }
        },
        child:SizedBox.expand(
          child: SingleChildScrollView(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: vhh(context, 6)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: RepaintBoundary(
                          key: _shareWidgetKey,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withValues(alpha: 0.9),
                                  spreadRadius: 1.5,
                                  blurRadius: 15,
                                  offset: const Offset(0, 0),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Stack(
                                  children: [
                                    Center(
                                      child: GestureDetector(
                                        onTap: () {
                                          // Handle tap on the logo if needed
                                        },
                                        child: Image.asset(
                                          'assets/images/icons/logo.png',
                                          width: 90,
                                          height: 80,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      right: 0,
                                      top: 10,
                                      child: IconButton(
                                        icon: const Icon(Icons.close,
                                            color: Colors.black, size: 28),
                                        onPressed: _onCloseClicked,
                                      ),
                                    ),
                                  ],
                                ),

                                // Additional Rows and Summary
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 11.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        destination,
                                        style: TextStyle(
                                          color: kColorBlack,
                                          fontSize: 13,
                                          letterSpacing: -0.1,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'inter',
                                        ),
                                      ),
                                      Text(
                                        GlobalVariables.editDestination ?? "",
                                        style: const TextStyle(
                                          color: kColorButtonPrimary,
                                          fontSize: 13,
                                          letterSpacing: -0.1,
                                          decoration: TextDecoration.underline,
                                          decorationColor: kColorButtonPrimary,
                                          fontFamily: 'inter',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 7),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        soundtrack,
                                        style: TextStyle(
                                          color: kColorBlack,
                                          fontSize: 13,
                                          letterSpacing: -0.1,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'inter',
                                        ),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(20),
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.3),
                                              spreadRadius: 0.5,
                                              blurRadius: 6,
                                              offset: const Offset(-3, 5),
                                            ),
                                          ],
                                          border: Border.all(
                                            color: kColorButtonPrimary,
                                            width: 1,
                                          ),
                                        ),
                                        padding:
                                            const EdgeInsets.symmetric(horizontal: 12, vertical: 2.5),
                                        child: GestureDetector(
                                          onTap: () {
                                            _playListClicked();
                                          },
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Image.asset(
                                                "assets/images/icons/music.png",
                                                width: 12,
                                                height: 12,
                                              ),
                                              const SizedBox(width: 3),
                                              const Text(
                                                'playlist',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: -0.1,
                                                  fontFamily: 'Inter',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Center(
                                  child: SizedBox(
                                    width: vww(context, 60),
                                    height: vhh(context, 43),
                                    child: Column(
                                      children: [
                                        Container(
                                          height: vhh(context, 38),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: kColorStrongGrey,
                                                width: 0.8),
                                            borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(8.0), 
                                              topRight: Radius.circular(8.0),
                                            ), 
                                          ),
                                          child: Column(
                                            children: [
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: Padding(
                                                  padding: const EdgeInsets.only(
                                                      left: 10.0,
                                                      top: 5,
                                                      bottom: 5),
                                                  child: Text(
                                                    widget.caption,
                                                    style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.grey,
                                                        fontFamily: 'inter'),
                                                  ),
                                                ),
                                              ),
                                              // Image
                                              Expanded(
                                                child: Image.file(
                                                  File(widget.imagePath),
                                                  fit: BoxFit.cover,
                                                  width: vww(context, 100),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: vhh(context, 0.5)),
                                        const Padding(
                                          padding: EdgeInsets.only(top: 5.0),
                                          child: Text(
                                            "the Rolla travel app.",
                                            style: TextStyle(
                                                fontSize: 16,
                                                letterSpacing: -0.1,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'inter'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15,),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: kColorGreen,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.4),
                              blurRadius: 5, 
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Column(
                          children: [
                            SizedBox(height: 5,),
                            Text("Success! This pin has been dropped on your map.",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.1,
                                fontFamily: 'inter',
                                color: kColorWhite,
                              ),
                            ),
                            Text("(limit of 7 pins/trip).",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                                letterSpacing: -0.1,
                                fontFamily: 'inter',
                                color: kColorWhite,
                              ),
                            ),
                            SizedBox(height: 5,),
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 20.0),
                        child: Text(
                          "Share this summary on another platform:",
                          style: TextStyle(
                            fontSize: 14,
                            color: kColorStrongGrey,
                            fontFamily: 'inter',
                            letterSpacing: -0.1
                          ),
                        ),
                      ),
                      const SizedBox(height: 15,),
                      GestureDetector(
                        onTap: () {
                          _onShareClicked();
                        },
                        child: Image.asset(
                          "assets/images/icons/upload_icon.png",
                          height: 20,
                        ),
                      ),
                      const SizedBox(height: 30,),
                    ],
                  ),
                ),

                // BackdropFilter for uploading state
                if (isuploadingImage)
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Container(
                      color:
                          // ignore: deprecated_member_use
                          Colors.black
                              // ignore: deprecated_member_use
                              .withOpacity(0.3), // Semi-transparent overlay
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SpinningLoader(),
                            SizedBox(height: 16),
                            Text(
                              'Uploading image to server...',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),),
      bottomNavigationBar: BottomNavBar(currentIndex: _currentIndex),
    );
  }
}
