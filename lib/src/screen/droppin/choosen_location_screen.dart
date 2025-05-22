import 'package:RollaTravel/src/screen/trip/sound_screen.dart';
import 'package:RollaTravel/src/screen/trip/start_trip.dart';
import 'package:RollaTravel/src/utils/global_variable.dart';
import 'package:RollaTravel/src/utils/spinner_loader.dart';
import 'package:flutter/rendering.dart';
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
import 'package:share_plus/share_plus.dart';

class ChoosenLocationScreen extends ConsumerStatefulWidget {
  final LatLng? location;
  final String caption;
  final String imagePath;

  const ChoosenLocationScreen(
      {super.key,
      required this.caption,
      required this.imagePath,
      required this.location});

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

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onCloseClicked() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const StartTripScreen()));
  }

  // Future<void> _onShareClicked() async {
  //   try {
  //     final imagePath = widget.imagePath;
  //     final caption = widget.caption;

  //     if (imagePath.isEmpty || !File(imagePath).existsSync()) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Image not found!')),
  //       );
  //       return;
  //     }
  //     XFile file = XFile(imagePath);
  //     await Share.shareXFiles([file], text: caption);
  //   } catch (e) {
  //     if(!mounted) return;
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Failed to share: $e')),
  //     );
  //   }
  // }

  Future<void> _onShareClicked() async {
    try {
      RenderRepaintBoundary boundary = _shareWidgetKey.currentContext?.findRenderObject() as RenderRepaintBoundary;
      if (boundary.debugNeedsPaint) {
        await Future.delayed(const Duration(milliseconds: 20));
        await WidgetsBinding.instance.endOfFrame;
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      final tempDir = await Directory.systemTemp.createTemp();
      final file = await File('${tempDir.path}/shared_polaroid.png').create();
      await file.writeAsBytes(pngBytes);

      await Share.shareXFiles([XFile(file.path)], text: widget.caption);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to share: $e')),
      );
    }
  }


  void _playListClicked () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SoundScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kColorWhite,
      body: PopScope(
        canPop: false, 
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            return; 
          }
        },
        child: SizedBox.expand(
          child: SingleChildScrollView(
            child: Stack(
              children: [
                // Main body content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: vhh(context, 8)),
                      RepaintBoundary(
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
                              // Logo and Close Button
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
                                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
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
                              const SizedBox(height: 20),
                              Center(
                                child: SizedBox(
                                  width: vww(context, 60),
                                  height: vhh(context, 45),
                                  child: Column(
                                    children: [
                                      Container(
                                        height: vhh(context, 38),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.grey,
                                              width:
                                                  1.0), // Set border color and width
                                          borderRadius: BorderRadius.circular(
                                              8.0), // Optional: Add border radius for rounded corners
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
                                        padding: EdgeInsets.only(top: 8.0),
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
                      const Padding(
                        padding: EdgeInsets.only(top: 10.0),
                        child: Text(
                          "Share this summary:",
                          style: TextStyle(
                            fontSize: 14,
                            color: kColorStrongGrey,
                            fontFamily: 'inter',
                          ),
                        ),
                      ),
                      const SizedBox(height: 10,),
                      GestureDetector(
                        onTap: () {
                          _onShareClicked();
                        },
                        child: Image.asset(
                          "assets/images/icons/upload_icon.png",
                          height: 30,
                        ),
                      ),
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
        ),
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: _currentIndex),
    );
  }
}
