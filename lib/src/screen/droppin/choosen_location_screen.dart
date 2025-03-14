import 'package:RollaTravel/src/screen/trip/start_trip.dart';
import 'package:RollaTravel/src/utils/global_variable.dart';
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

  Future<void> _onShareClicked() async {
    try {
      final imagePath = widget.imagePath;
      final caption = widget.caption;

      if (imagePath.isEmpty || !File(imagePath).existsSync()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image not found!')),
        );
        return;
      }

      XFile file = XFile(imagePath);

      await Share.shareXFiles([file], text: caption);
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to share: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String tripMiles =
        "${GlobalVariables.totalDistance.toStringAsFixed(3)} miles";
    return Scaffold(
      backgroundColor: kColorWhite,
      body: PopScope(
        canPop: false, // Prevents popping by default
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            return; // Prevent pop action
          }
        },
        child: SizedBox.expand(
          child: SingleChildScrollView(
            child: Stack(
              children: [
                // Main body content
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: vhh(context, 5)),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey, width: 1.5),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              // ignore: deprecated_member_use
                              color: Colors.white.withOpacity(0.9),
                              spreadRadius: -5,
                              blurRadius: 15,
                              offset: const Offset(0, 5),
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
                                      height: vh(context, 13),
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
                                  const EdgeInsets.symmetric(horizontal: 10.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    destination,
                                    style: TextStyle(
                                      color: kColorBlack,
                                      fontSize: 14,
                                      fontFamily: 'Kadaw',
                                    ),
                                  ),
                                  Text(
                                    GlobalVariables.editDestination!,
                                    style: const TextStyle(
                                      color: kColorButtonPrimary,
                                      fontSize: 14,
                                      decoration: TextDecoration.underline,
                                      decorationColor: kColorButtonPrimary,
                                      fontFamily: 'Kadaw',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal:
                                      10.0), // Adjust the value as needed
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    miles_traveled,
                                    style: TextStyle(
                                        color: kColorBlack,
                                        fontSize: 14,
                                        fontFamily: 'Kadaw'),
                                  ),
                                  Text(
                                    tripMiles,
                                    style: const TextStyle(
                                        color: kColorBlack,
                                        fontSize: 14,
                                        fontFamily: 'Kadaw'),
                                  ),
                                ],
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal:
                                      10.0), // Adjust the value as needed
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    soundtrack,
                                    style: TextStyle(
                                        color: kColorBlack,
                                        fontSize: 14,
                                        fontFamily: 'Kadaw'),
                                  ),
                                  Text(
                                    edit_playlist,
                                    style: TextStyle(
                                        color: kColorButtonPrimary,
                                        fontSize: 14,
                                        decoration: TextDecoration.underline,
                                        decorationColor: kColorButtonPrimary,
                                        fontFamily: 'Kadaw'),
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
                                                    fontFamily: 'Kadaw'),
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
                                        "the Rolla travel app",
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontFamily: 'KadawBold'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 5.0),
                        child: Text(
                          "Share this summary:",
                          style: TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            fontFamily: 'Kadaw',
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          _onShareClicked();
                        },
                        child: Image.asset(
                          "assets/images/icons/share.png",
                          height: 50,
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
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text(
                              'Updating image to server...',
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
