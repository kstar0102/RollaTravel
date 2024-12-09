import 'package:RollaTravel/src/constants/app_button.dart';
import 'package:RollaTravel/src/constants/app_styles.dart';
import 'package:RollaTravel/src/screen/trip/destination_screen.dart';
import 'package:RollaTravel/src/screen/trip/end_trip.dart';
import 'package:RollaTravel/src/screen/trip/sound_screen.dart';
import 'package:RollaTravel/src/screen/trip/trip_settting_screen.dart';
import 'package:RollaTravel/src/screen/trip/trip_tag_screen.dart';
import 'package:RollaTravel/src/translate/en.dart';
import 'package:RollaTravel/src/utils/index.dart';
import 'package:RollaTravel/src/widget/bottombar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:logger/logger.dart';
import 'package:RollaTravel/src/utils/global_variable.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
// import 'package:polyline_points/polyline_points.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';


class StartTripScreen extends ConsumerStatefulWidget {
  const StartTripScreen({super.key});

  @override
  ConsumerState<StartTripScreen> createState() => _StartTripScreenState();
}

class _StartTripScreenState extends ConsumerState<StartTripScreen> {
  double screenHeight = 0;
  double keyboardHeight = 0;
  final int _currentIndex = 2;
  LatLng? _currentLocation;
  LatLng? _movingLocation; // Location of the moving marker
  List<LatLng> _pathCoordinates = []; // List of coordinates for the path
  final MapController _mapController = MapController();
  final logger = Logger();
  final TextEditingController _captionController = TextEditingController();
  String editDestination = 'Edit destination';
  String initialSound = "Edit Playlist";

  bool isTripStarted = false;

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

  void toggleTrip() {
    setState(() {
      isTripStarted = !isTripStarted;
      if (isTripStarted) {
        _startTrackingMovement();
      }
      // ref.read(isTripStartedProvider.notifier).state = isTripStarted;
      // if (!isTripStarted) {
      //   Navigator.push(
      //     context,
      //     MaterialPageRoute(builder: (context) => const EndTripScreen()),
      //   );
      // }
    });
  }

  Future<void> _getCurrentLocation() async {
    logger.i("Checking location permission...");

    final permissionStatus = await Permission.location.request();

    if (permissionStatus.isGranted) {
      // Permission granted, fetch current location
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        // _movingLocation = _currentLocation; // Set moving location to initial position
        // _pathCoordinates.add(_currentLocation!); // Add the starting location to the path
        logger.i("Location: $_currentLocation");
      });
      _mapController.move(_currentLocation!, 14.0);
    } else if (permissionStatus.isDenied || permissionStatus.isPermanentlyDenied) {
      // Permission denied - prompt user to open settings
      logger.i("Location permission denied. Redirecting to settings.");
      _showPermissionDeniedDialog();
    } else {
      logger.i("Location permission status: $permissionStatus");
    }
  }
  
  Future<void> _startTrackingMovement() async {
    // Stream for location changes
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 50, // Update every 50 meters
      ),
    ).listen((Position position) async {
      LatLng newLocation = LatLng(position.latitude, position.longitude);

      // ✅ Await inside async callback
      await _fetchDrivingRoute(_currentLocation!, newLocation);

      setState(() {
        _movingLocation = newLocation;
        // _pathCoordinates.add(_movingLocation!);
        logger.i("Updated Moving Location: $_movingLocation");
      });

      _mapController.move(_movingLocation!, 14.0); // Move map view to new position
    });
  }

  Future<void> _fetchDrivingRoute(LatLng start, LatLng end) async {
    final url = 'https://api.mapbox.com/directions/v5/mapbox/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?geometries=polyline6&access_token=pk.eyJ1Ijoicm9sbGExIiwiYSI6ImNseGppNHN5eDF3eHoyam9oN2QyeW5mZncifQ.iLIVq7aRpvMf6J3NmQTNAw';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final List<dynamic> routes = jsonResponse['routes'];

        if (routes.isNotEmpty) {
          final String polyline = routes[0]['geometry'];

          // ✅ Decode the polyline using a custom polyline6 decoder
          final List<LatLng> decodedPolyline = _decodePolyline6(polyline);

          // ✅ Clear previous path coordinates and add the new route
          setState(() {
            _pathCoordinates.clear(); // Clear previous path
            _pathCoordinates.addAll(decodedPolyline);
          });

        } else {
          logger.i('No routes found.');
        }
      } else {
        logger.i('Error fetching route: ${response.statusCode}');
      }
    } catch (e) {
      logger.i('Error fetching route: $e');
    }
  }

  List<LatLng> _decodePolyline6(String encoded) {
    List<LatLng> polyline = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int deltaLat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += deltaLat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int deltaLng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += deltaLng;

      polyline.add(LatLng(lat / 1E6, lng / 1E6));
    }
    return polyline;
  }


  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Location Permission Required"),
          content: const Text(
            "To access your location, please enable permissions in System Preferences > Security & Privacy > Privacy > Location Services.",
          ),
          actions: [
            TextButton(
              child: const Text("Open Settings"),
              onPressed: () async {
                await openAppSettings();
                if (mounted) {
                  Navigator.of(context).pop();
                }
              },
            ),
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _onSettingClicked(){
    Navigator.push(context, MaterialPageRoute(builder: (context) => const TripSetttingScreen()));
  }

  void _onTagClicked(){
    Navigator.push(context, MaterialPageRoute(builder: (context) => const TripTagSearchScreen()));
  }

  Future<bool> _onWillPop() async {
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: vhh(context, 5)),
                Padding(
                  padding: EdgeInsets.only(left: vww(context, 4), right: vww(context, 4)),
                    child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset(
                        'assets/images/icons/logo.png',
                        width: vww(context, 20),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              _onTagClicked();
                            },
                            child: Image.asset(
                              'assets/images/icons/add_car1.png',
                              width: vww(context, 15),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              _onSettingClicked();
                            },
                            child: Image.asset(
                              'assets/images/icons/setting.png',
                              width: vww(context, 15),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: vww(context, 4)),
                  child: const Divider(color: kColorGrey, thickness: 1),
                ),
                SizedBox(height: vhh(context, 1)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: vww(context, 4)),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            destination,
                            style: TextStyle(
                              color: kColorBlack,
                              fontSize: 14,
                              fontFamily: 'Kadaw'
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation1, animation2) => DestinationScreen(initialDestination: editDestination),
                                  transitionDuration: Duration.zero,
                                  reverseTransitionDuration: Duration.zero,
                                ),
                              );
                              if (result != null) {
                                setState(() {
                                  editDestination = result;
                                });
                              }
                            },
                            child: Text(
                              editDestination.length > 30 ? '${editDestination.substring(0, 30)}...' : editDestination,
                              style: const TextStyle(
                                color: kColorButtonPrimary,
                                fontSize: 14,
                                fontFamily: 'Kadaw',
                                decoration: TextDecoration.underline,
                                decorationColor: kColorButtonPrimary,
                              ),
                              overflow: TextOverflow.ellipsis, // Add ellipsis if text is too long
                              maxLines: 1, // Limit to one line
                            ),
                          ),
                        ],
                      ),
                      const Row(
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            soundtrack,
                            style: TextStyle(
                              color: kColorBlack,
                              fontSize: 14,
                              fontFamily: 'Kadaw'
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation1, animation2) => SoundScreen(initialSound: initialSound),
                                  transitionDuration: Duration.zero,
                                  reverseTransitionDuration: Duration.zero,
                                ),
                              );
                              if (result != null) {
                                setState(() {
                                  initialSound = result;
                                });
                              }
                            },
                            child: const Text(
                              edit_playlist,
                              style: TextStyle(
                                color: kColorButtonPrimary,
                                fontSize: 14,
                                decoration: TextDecoration.underline,
                                decorationColor: kColorButtonPrimary,
                                fontFamily: 'Kadaw'
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: vhh(context, 1),),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: vww(context, 4)),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200], // Background color similar to the image
                      border: Border.all(color: Colors.black), // Black border
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8.0), // Inner padding
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Caption:',
                          style: TextStyle(
                            color: kColorBlack,
                            fontSize: 14,
                            fontFamily: 'Kadaw'
                          ),
                        ),
                        const SizedBox(width: 8), // Spacing between the label and input field
                        Expanded(
                          child: TextField(
                            controller: _captionController,
                            decoration: const InputDecoration(
                              isDense: true, // Reduces padding inside the TextField
                              border: InputBorder.none, // Removes default TextField border
                              hintText: '', // Empty hint text for a cleaner look
                              
                            ),
                            style: const TextStyle(
                              fontSize: 14,
                              color: kColorBlack,
                              fontFamily: 'Kadaw'
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: vhh(context, 1),),

                // MapBox integration with a customized size
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: vww(context, 4)),
                  child: SizedBox(
                    height: vhh(context, 55),
                    child: Stack(
                      children: [
                        FlutterMap(
                          mapController: _mapController, 
                          options: MapOptions(
                            initialCenter: _currentLocation ?? const LatLng(43.1557, -77.6157),
                            initialZoom: 13.0,
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
                                  if (_movingLocation != null)
                                    Marker(
                                      width: 40.0,
                                      height: 40.0,
                                      point: _movingLocation!,
                                      child: Image.asset(
                                        'assets/images/icons/car_icon.png', // Path to your asset image
                                        width: 40, // You can adjust the size
                                        height: 35,
                                        fit: BoxFit.contain, // Ensures the image scales properly
                                      ),
                                    ),
                                ],
                              ),
                            
                            if (_pathCoordinates.isNotEmpty)
                              PolylineLayer(
                                polylines: [
                                  Polyline(
                                    points: _pathCoordinates, // List of LatLng points for the path
                                    strokeWidth: 4.0, // Thickness of the line
                                    color: Colors.blue, // Color of the line
                                  ),
                                ],
                              ),
                          ],
                        ),
                        isTripStarted? Positioned(
                          top: 1,
                          left: 0,
                          right: 0,
                          child: Padding(
                            padding: EdgeInsets.zero, // Adjust for width
                            child: Container(
                              padding: const EdgeInsets.all(3.0),
                              color: Colors.white.withOpacity(0.5),
                              child: const Column(
                                children: [
                                  Text(
                                    'Trip in progress',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                      fontStyle: FontStyle.italic,
                                      fontFamily: 'KadawBold'
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    'Drop a pin to post your map',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                      fontStyle: FontStyle.italic,
                                      fontFamily: 'Kadaw'
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ) : const SizedBox(),
                        
                        // Zoom in/out buttons
                        Positioned(
                          right: 10,
                          top: 70,
                          child: Column(
                            children: [
                              FloatingActionButton(
                                heroTag: 'zoom_in_button_starttrip_1', // Unique tag for the zoom in button
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
                                heroTag: 'zoom_out_button_starttrip_2', // Unique tag for the zoom out button
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
                        
                        // Button overlay
                        Positioned(
                          bottom: 70,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.only(left: vww(context, 15), right: vww(context, 15), top: vhh(context, 3)),
                              child: ButtonWidget(
                                btnType: isTripStarted ? ButtonWidgetType.endTripTitle : ButtonWidgetType.startTripTitle,
                                borderColor: isTripStarted ? Colors.red : kColorButtonPrimary,
                                textColor: kColorWhite,
                                fullColor: isTripStarted ? Colors.red : kColorButtonPrimary,
                                onPressed: toggleTrip,
                              ),
                            ),
                          ),
                        ),

                        Positioned(
                          bottom: 5,
                          left: 0,
                          right: 0,
                          child: Padding(
                            padding: EdgeInsets.zero, // Adjust for width
                            child: Container(
                              padding: const EdgeInsets.all(3.0), // Inner padding for spacing around text
                              color: Colors.white.withOpacity(0.5), // Background color with slight transparency
                              child: const Text(
                                'Note: Start trip, then drop a pin to make\nyour post visible to your followers',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                  fontFamily: 'Kadaw',
                                ),
                                textAlign: TextAlign.center,
                              ),
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
        ),
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: _currentIndex),
    );
  }
}
