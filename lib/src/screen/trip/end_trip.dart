import 'package:RollaTravel/src/screen/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:RollaTravel/src/utils/index.dart';
import 'package:RollaTravel/src/constants/app_styles.dart';
import 'package:RollaTravel/src/translate/en.dart';
import 'package:logger/logger.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:RollaTravel/src/widget/bottombar.dart';

class EndTripScreen extends ConsumerStatefulWidget {
  const EndTripScreen({super.key});

  @override
  ConsumerState<EndTripScreen> createState() => _EndTripScreenState();
}

class _EndTripScreenState extends ConsumerState<EndTripScreen> {
  double screenHeight = 0;
  double keyboardHeight = 0;
  final int _currentIndex = 2;
  LatLng? _currentLocation;
  final Logger logger = Logger();
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    super.dispose();
    _mapController.dispose();
  }

  Future<void> _getCurrentLocation() async {
    final permissionStatus = await Permission.location.request();

    if (permissionStatus.isGranted) {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        logger.i("$_currentLocation");
      });
       _mapController.move(_currentLocation!, 13.0);
    } else {
      // Handle the case when location permission is denied.
      logger.i("Location permission denied");
    }
  }

  Future<bool> _onWillPop() async {
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:WillPopScope(
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
                    // Map Image
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: vww(context, 4)),
                      child: SizedBox(
                        height: vhh(context, 30),
                        child: Stack(
                          children: [
                            FlutterMap(
                              mapController: _mapController, 
                              options: MapOptions(
                                initialCenter: _currentLocation ?? const LatLng(37.7749, -122.4194),
                                initialZoom: 12.0,
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate:
                                      "https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/{z}/{x}/{y}?access_token=pk.eyJ1Ijoicm9sbGExIiwiYSI6ImNseGppNHN5eDF3eHoyam9oN2QyeW5mZncifQ.iLIVq7aRpvMf6J3NmQTNAw",
                                  additionalOptions: const {
                                    'access_token': 'pk.eyJ1Ijoicm9sbGExIiwiYSI6ImNseGppNHN5eDF3eHoyam9oN2QyeW5mZncifQ.iLIVq7aRpvMf6J3NmQTNAw',
                                  },
                                ),
                                if (_currentLocation != null)
                                  MarkerLayer(
                                    markers: [
                                      Marker(
                                        width: 80.0,
                                        height: 80.0,
                                        point: _currentLocation!,
                                        child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                            // Zoom in/out buttons
                            Positioned(
                              right: 10,
                              top: 30,
                              child: Column(
                                children: [
                                  FloatingActionButton(
                                    heroTag: 'zoom_in_button_endtrip',
                                    onPressed: () {
                                      _mapController.move(
                                        _mapController.camera.center,
                                        _mapController.camera.zoom + 1,
                                      );
                                    },
                                    mini: true,
                                    child: const Icon(Icons.zoom_in),
                                  ),
                                  const SizedBox(height: 8),
                                  FloatingActionButton(
                                    heroTag: 'zoom_in_button_endtrip',
                                    onPressed: () {
                                      _mapController.move(
                                        _mapController.camera.center,
                                        _mapController.camera.zoom - 1,
                                      );
                                    },
                                    mini: true,
                                    child: const Icon(Icons.zoom_out),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Footer Text
                    const Text(
                      'Travel. Share.',
                      style: TextStyle(fontSize: 16, fontFamily: 'KadawBold', color: Colors.grey),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'the Rolla travel app',
                      style: TextStyle(fontSize: 14, color: Colors.black, fontFamily: 'Kadaw'),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Share this summary:',
                    style: TextStyle(fontSize: 16,fontFamily: 'Kadaw'),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                            pageBuilder: (context, animation1, animation2) => const HomeScreen(),
                            transitionDuration: Duration.zero,
                            reverseTransitionDuration: Duration.zero,
                        ),
                      );
                    },
                    child: Image.asset(
                      "assets/images/icons/share.png",
                      height: 50,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ), 
      bottomNavigationBar: BottomNavBar(currentIndex: _currentIndex),
    );
  }
}
