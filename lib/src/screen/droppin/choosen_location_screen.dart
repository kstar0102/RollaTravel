import 'package:RollaTravel/src/screen/trip/start_trip.dart';
import 'package:RollaTravel/src/utils/stop_marker_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:RollaTravel/src/utils/index.dart';
import 'package:RollaTravel/src/widget/bottombar.dart';
import 'package:RollaTravel/src/translate/en.dart';
import 'package:RollaTravel/src/constants/app_styles.dart';
import 'package:latlong2/latlong.dart';
import 'dart:io';

class ChoosenLocationScreen extends ConsumerStatefulWidget{
  final LatLng? location;
  final String caption;
  final String imagePath;

  const ChoosenLocationScreen({super.key, required this.caption, required this.imagePath, required this.location});

  @override
  ConsumerState<ChoosenLocationScreen> createState() => ChoosenLocationScreenState();
}

class ChoosenLocationScreenState extends ConsumerState<ChoosenLocationScreen> {
  double screenHeight = 0;
  double keyboardHeight = 0;
  final int _currentIndex = 3;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();               
  }

  Future<bool> _onWillPop() async {
    return false;
  }

  void _onShareClicked(){
    final markerData = MarkerData(
      location: widget.location!,
      imagePath: widget.imagePath,
      caption: widget.caption
    );

    // Add the marker to the provider
    ref.read(markersProvider.notifier).state = [
      ...ref.read(markersProvider),
      markerData,
    ];
  
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => const StartTripScreen(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: _onWillPop,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: vhh(context, 5),),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey, width: 1.5),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.9),
                      spreadRadius: -5,
                      blurRadius: 15,
                      offset: const Offset(0, 5), // Only apply shadow at the top
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
                              'assets/images/icons/logo.png', // Replace with your logo asset path
                              height: vh(context, 13),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: 10,
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.black, size: 28),
                            onPressed: () {
                              Navigator.pop(context); // Close action
                            },
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0), // Adjust the value as needed
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            destination,
                            style: TextStyle(
                              color: kColorBlack,
                              fontSize: 14,
                              fontFamily: 'Kadaw'
                            ),
                          ),
                          Text(
                            edit_destination,
                            style: TextStyle(
                              color: kColorButtonPrimary,
                              fontSize: 14,
                              decoration: TextDecoration.underline,
                              decorationColor: kColorButtonPrimary,
                              fontFamily: 'Kadaw'
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0), // Adjust the value as needed
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            miles_traveled,
                            style: TextStyle(
                              color: kColorBlack,
                              fontSize: 14,
                              fontFamily: 'Kadaw'
                            ),
                          ),
                          Text(
                            "0",
                            style: TextStyle(
                              color: kColorBlack,
                              fontSize: 14,
                              fontFamily: 'Kadaw'
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0), // Adjust the value as needed
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            soundtrack,
                            style: TextStyle(
                              color: kColorBlack,
                              fontSize: 14,
                              fontFamily: 'Kadaw'
                            ),
                          ),
                          Text(
                            edit_playlist,
                            style: TextStyle(
                              color: kColorButtonPrimary,
                              fontSize: 14,
                              decoration: TextDecoration.underline,
                              decorationColor: kColorButtonPrimary,
                              fontFamily: 'Kadaw'
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
                                border: Border.all(color: Colors.grey, width: 1.0), // Set border color and width
                                borderRadius: BorderRadius.circular(8.0), // Optional: Add border radius for rounded corners
                              ),
                              child: Column(
                                children: [
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 10.0, top: 5, bottom: 5),
                                        child: Text(
                                        widget.caption,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey,
                                          fontFamily: 'Kadaw'
                                        ),
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
                                  fontFamily: 'KadawBold'
                                ),
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
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  "Share this summary:",
                  style: TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    fontFamily: 'Kadaw'
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
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: _currentIndex),
    );
  }
}