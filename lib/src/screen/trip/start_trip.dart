import 'package:RollaTravel/src/constants/app_button.dart';
import 'package:RollaTravel/src/constants/app_styles.dart';
import 'package:RollaTravel/src/screen/trip/destination_screen.dart';
import 'package:RollaTravel/src/screen/trip/end_trip.dart';
import 'package:RollaTravel/src/screen/trip/sound_screen.dart';
import 'package:RollaTravel/src/screen/trip/trip_settting_screen.dart';
import 'package:RollaTravel/src/screen/trip/trip_tag_screen.dart';
import 'package:RollaTravel/src/translate/en.dart';
import 'package:RollaTravel/src/utils/index.dart';
import 'package:RollaTravel/src/utils/location.permission.dart';
import 'package:RollaTravel/src/utils/stop_marker_provider.dart';
import 'package:RollaTravel/src/widget/bottombar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:logger/logger.dart';
import 'package:RollaTravel/src/utils/global_variable.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:intl/intl.dart';
// import 'dart:math';

class StartTripScreen extends ConsumerStatefulWidget {
  const StartTripScreen({super.key});

  @override
  ConsumerState<StartTripScreen> createState() => _StartTripScreenState();
}

class _StartTripScreenState extends ConsumerState<StartTripScreen> {
  double screenHeight = 0;
  double keyboardHeight = 0;
  final int _currentIndex = 2;
  StreamSubscription<Position>? _positionStreamSubscription;
  final MapController _mapController = MapController();
  bool hasSetStartPoint = false;
  final logger = Logger();
  LatLng? currentLocation;
  final TextEditingController _captionController = TextEditingController();
  // String editDestination = 'Edit destination';
  String initialSound = "Edit Playlist";
  double totalDistanceInMiles = 0;
  List<LatLng> pathCoordinates = [];
  bool isStateRestored = false;

  static const String mapboxAccessToken =
      "pk.eyJ1Ijoicm9sbGExIiwiYSI6ImNseGppNHN5eDF3eHoyam9oN2QyeW5mZncifQ.iLIVq7aRpvMf6J3NmQTNAw";

  @override
  void initState() {
    super.initState();
    _restoreState();
    if (PermissionService().hasLocationPermission) {
      _getCurrentLocation(); // ✅ It will not request permission again
    }
    _startTrackingMovement();
    _checkLocationServices();
  }

  @override
  void dispose() {
    super.dispose();
    _mapController.dispose();
    _positionStreamSubscription?.cancel();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _restoreState(); // Restore map and path state
  }

  Future<void> _checkLocationServices() async {
    bool isLocationEnabled = await Geolocator.isLocationServiceEnabled();
    LocationPermission permission = await Geolocator.checkPermission();

    // ✅ If location services are OFF, show a notification dialog
    if (!isLocationEnabled) {
      logger.e("Location services are disabled!");
      _showLocationDisabledDialog();
      return;
    }

    // ✅ If permission is denied, request it
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        logger.e("Location permission denied!");
        _showPermissionDeniedDialog();
        return;
      }
    }

    // ✅ If permission is permanently denied, open settings
    if (permission == LocationPermission.deniedForever) {
      logger.e("Location permission permanently denied!");
      _showPermissionDeniedDialog();
      return;
    }

    // ✅ If everything is enabled, log success
    logger.i("Location services and permissions are enabled.");
  }

  void _showLocationDisabledDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Location Services Disabled"),
          content: const Text(
            "Please enable location services to track your movement.",
          ),
          actions: [
            TextButton(
              child: const Text("Open Settings"),
              onPressed: () async {
                await Geolocator.openLocationSettings(); // ✅ Opens GPS settings
                Navigator.of(context).pop();
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

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();

    // ✅ If permission is already granted, use the current location
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      currentLocation = LatLng(position.latitude, position.longitude);
      ref.read(movingLocationProvider.notifier).state ??= currentLocation;
      _mapController.move(currentLocation!, 15.0);
      return;
    }

    // 🛑 If permission is denied, only ask ONCE
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        logger.i("Location permission denied.");
        _showPermissionDeniedDialog();
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      logger.i("Location permission permanently denied.");
      _showPermissionDeniedDialog();
      return;
    }
  }

  Future<void> _startTrackingMovement() async {
    if (_positionStreamSubscription != null) {
      return; // Prevent multiple listeners
    }
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 10,
      ),
    ).listen((Position position) async {
      final LatLng newLocation = LatLng(position.latitude, position.longitude);

      // Update moving location
      ref.read(movingLocationProvider.notifier).state = newLocation;

      if (!GlobalVariables.isTripStarted) {
        ref.read(staticStartingPointProvider.notifier).state = newLocation;
      } else {
        // Calculate the distance from the last point
        if (pathCoordinates.isNotEmpty) {
          final lastLocation = pathCoordinates.last;
          final distance = Geolocator.distanceBetween(
            lastLocation.latitude,
            lastLocation.longitude,
            newLocation.latitude,
            newLocation.longitude,
          );

          // Update total distance
          GlobalVariables.totalDistance +=
              distance / 1609.34; // Convert to miles
          ref.read(totalDistanceProvider.notifier).state =
              GlobalVariables.totalDistance;
        }

        // Add the new location to the path
        pathCoordinates.add(newLocation);
        await _fetchSnappedRoute();
      }

      // Always update pathCoordinates state
      ref.read(pathCoordinatesProvider.notifier).state = [...pathCoordinates];

      // Smoothly move the map to the new location
      _mapController.move(newLocation, 15.0);
    });
  }

  Future<void> _fetchSnappedRoute() async {
    if (pathCoordinates.length < 2) {
      logger.i("Not enough coordinates for route snapping");
      return;
    }

    final coordinates = pathCoordinates
        .map((point) => "${point.longitude},${point.latitude}")
        .join(";");

    final url =
        "https://api.mapbox.com/matching/v5/mapbox/driving/$coordinates?access_token=$mapboxAccessToken&geometries=geojson&steps=false&overview=full";

    try {
      final response = await http.get(Uri.parse(url));
      // logger.i("Response from Mapbox: ${response.body}");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> matchedPoints =
            data['matchings'][0]['geometry']['coordinates'];

        // Update pathCoordinates with matched points
        final updatedPath =
            matchedPoints.map((coord) => LatLng(coord[1], coord[0])).toList();

        if (pathCoordinates.isNotEmpty) {
          updatedPath.insert(0, pathCoordinates.first);
        }

        ref.read(pathCoordinatesProvider.notifier).state = updatedPath;
        setState(() {
          pathCoordinates = updatedPath;
        });
      } else {
        logger.e("Failed to fetch snapped route: ${response.statusCode}");
      }
    } catch (e) {
      logger.e("Error fetching snapped route: $e");
    }
  }

  void toggleTrip() {
    if (GlobalVariables.isTripStarted) {
      // ✅ End the trip
      _endTrip();
    } else {
      // ✅ Start the trip
      _startTrip();
    }
  }

  void _startTrip() {
    if (GlobalVariables.editDestination == "Edit destination" ||
        GlobalVariables.editDestination.isEmpty) {
      _showDestinationAlert(context);
      return;
    }
    GlobalVariables.isTripStarted = true;
    ref.read(isTripStartedProvider.notifier).state = true;
    ref.read(pathCoordinatesProvider.notifier).state = [];

    // ✅ Record trip start time
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
    GlobalVariables.tripStartDate = formattedDate;

    // ✅ Set static starting point (this is the current location at the moment the trip starts)
    final currentLocation = ref.read(movingLocationProvider);
    if (currentLocation != null) {
      // ✅ Set this location as the starting point for the trip
      ref.read(staticStartingPointProvider.notifier).state = currentLocation;
      logger.i("currentLocation : $currentLocation");

      // Add starting location to pathCoordinates
      pathCoordinates = [currentLocation];
      ref.read(pathCoordinatesProvider.notifier).state = [...pathCoordinates];
    }

    // ✅ Start tracking user movement
    _startTrackingMovement();
  }

  void _showDestinationAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Destination Required"),
          content: const Text(
              "Please enter the destination before starting the trip."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _restoreState() {
    final movingLocation = ref.read(movingLocationProvider);
    final staticStartingPoint = ref.read(staticStartingPointProvider);
    final restoredPath = ref.read(pathCoordinatesProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (staticStartingPoint != null) {
        // Center the map at the static starting point
        _mapController.move(staticStartingPoint, 15.0);
      } else if (movingLocation != null) {
        // Center the map at the moving location
        _mapController.move(movingLocation, 14.0);
      }
    });

    // Restore pathCoordinates state
    if (restoredPath.isNotEmpty) {
      Future.microtask(() {
        ref.read(pathCoordinatesProvider.notifier).state = [...restoredPath];
      });
    }

    // Mark state as restored and force rebuild
    setState(() {
      isStateRestored = true;
    });
  }

  void _endTrip() async {
    LatLng? startLocation = ref.read(staticStartingPointProvider);
    // ✅ Get the most recent location before setting `endLocation`
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );

    // ✅ Assign `endLocation` the most accurate position
    LatLng endLocation = LatLng(position.latitude, position.longitude);
    logger.i("end trip location : $endLocation");
    List<MarkerData> stopMarkers = ref.read(markersProvider);

    // Check if there are no stop markers
    if (stopMarkers.isEmpty) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Warning"),
            content: const Text(
                "You need to add at least one stop marker (drop pin) before ending the trip."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
      return; // Prevent further execution
    }

    // ✅ Record trip end time
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
    GlobalVariables.tripEndDate = formattedDate;

    String tripMiles =
        "${GlobalVariables.totalDistance.toStringAsFixed(3)} miles";

    GlobalVariables.editDestination = 'Edit destination';

    if (GlobalVariables.tripStartDate != null &&
        GlobalVariables.tripEndDate != null) {
      if (!mounted) return;
      // ✅ End the trip and navigate to the EndTripScreen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EndTripScreen(
            startLocation: startLocation,
            endLocation: endLocation,
            stopMarkers: stopMarkers,
            tripStartDate: GlobalVariables.tripStartDate!,
            tripEndDate: GlobalVariables.tripEndDate!,
            tripDistance: tripMiles,
            endDestination: GlobalVariables.editDestination,
          ),
        ),
      );

      // ✅ Reset the trip state
      ref.read(isTripStartedProvider.notifier).state = false;
      GlobalVariables.isTripStarted = false;

      // ✅ Reset all trip-related data
      ref.read(staticStartingPointProvider.notifier).state =
          ref.read(movingLocationProvider);
      ref.read(movingLocationProvider.notifier).state = null;
      ref.read(markersProvider.notifier).state = [];
      ref.read(totalDistanceProvider.notifier).state = 0.0;
      GlobalVariables.totalDistance = 0.0;
    } else {
      logger.i("tripStartDate is null.");
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Location Permission Required"),
          content: const Text(
            "To access your location, please enable permissions in Settings > Privacy & Security > Location Services.",
          ),
          actions: [
            TextButton(
              child: const Text("Open Settings"),
              onPressed: () async {
                await Geolocator.openAppSettings(); // Open settings for iOS
                if (mounted) {
                  // ignore: use_build_context_synchronously
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

  void _onSettingClicked() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const TripSetttingScreen()));
  }

  void _onTagClicked() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const TripTagSearchScreen()));
  }

  Future<bool> _onWillPop() async {
    return false;
  }

  Future<void> _onDestintionClick() async {
    final result = await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => DestinationScreen(
            initialDestination: GlobalVariables.editDestination),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
    if (result != null) {
      setState(() {
        GlobalVariables.editDestination = result;
      });
      logger.i(GlobalVariables.editDestination);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pathCoordinates = ref.watch(pathCoordinatesProvider);
    final movingLocation = ref.watch(movingLocationProvider);
    final staticStartingPoint = ref.watch(staticStartingPointProvider);

    return Scaffold(
      backgroundColor: kColorWhite,
      // ignore: deprecated_member_use
      body: WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          backgroundColor: Colors.white,
          resizeToAvoidBottomInset: true,
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: vhh(context, 5)),
                Padding(
                  padding: EdgeInsets.only(
                      left: vww(context, 4), right: vww(context, 4)),
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
                  // child: Container(

                  // )
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
                                fontFamily: 'Kadaw'),
                          ),
                          GestureDetector(
                            onTap: () {
                              _onDestintionClick();
                            },
                            child: Text(
                              GlobalVariables.editDestination.length > 30
                                  ? '${GlobalVariables.editDestination.substring(0, 30)}...'
                                  : GlobalVariables.editDestination,
                              style: const TextStyle(
                                color: kColorButtonPrimary,
                                fontSize: 14,
                                fontFamily: 'Kadaw',
                                decoration: TextDecoration.underline,
                                decorationColor: kColorButtonPrimary,
                              ),
                              overflow: TextOverflow
                                  .ellipsis, // Add ellipsis if text is too long
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
                                fontFamily: 'Kadaw'),
                          ),
                          Text(
                            "0",
                            style: TextStyle(
                                color: kColorBlack,
                                fontSize: 14,
                                fontFamily: 'Kadaw'),
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
                                fontFamily: 'Kadaw'),
                          ),
                          GestureDetector(
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation1,
                                          animation2) =>
                                      SoundScreen(initialSound: initialSound),
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
                                  fontFamily: 'Kadaw'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(
                  height: vhh(context, 1),
                ),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: vww(context, 4)),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors
                          .grey[200], // Background color similar to the image
                      border: Border.all(color: Colors.black), // Black border
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0), // Inner padding
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Caption:',
                          style: TextStyle(
                              color: kColorBlack,
                              fontSize: 14,
                              fontFamily: 'Kadaw'),
                        ),
                        const SizedBox(
                            width:
                                8), // Spacing between the label and input field
                        Expanded(
                          child: TextField(
                            controller: _captionController,
                            decoration: const InputDecoration(
                              isDense:
                                  true, // Reduces padding inside the TextField
                              border: InputBorder
                                  .none, // Removes default TextField border
                              hintText:
                                  '', // Empty hint text for a cleaner look
                            ),
                            style: const TextStyle(
                                fontSize: 14,
                                color: kColorBlack,
                                fontFamily: 'Kadaw'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(
                  height: vhh(context, 1),
                ),

                // MapBox integration with a customized size
                !isStateRestored
                    ? const Center(child: CircularProgressIndicator())
                    : Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: vww(context, 4)),
                        child: SizedBox(
                          height: vhh(context, 55),
                          child: Stack(
                            children: [
                              FlutterMap(
                                mapController: _mapController,
                                options: MapOptions(
                                  initialCenter: movingLocation ??
                                      staticStartingPoint ??
                                      const LatLng(43.1557, -77.6157),
                                  initialZoom: 15.0,
                                ),
                                children: [
                                  TileLayer(
                                    urlTemplate:
                                        "https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/{z}/{x}/{y}?access_token=$mapboxAccessToken",
                                    additionalOptions: const {
                                      'access_token':
                                          'pk.eyJ1Ijoicm9sbGExIiwiYSI6ImNseGppNHN5eDF3eHoyam9oN2QyeW5mZncifQ.iLIVq7aRpvMf6J3NmQTNAw',
                                    },
                                  ),
                                  MarkerLayer(
                                    markers: [
                                      if (movingLocation != null &&
                                          GlobalVariables.isTripStarted)
                                        Marker(
                                          width: 40.0,
                                          height: 40.0,
                                          point: movingLocation,
                                          child: Image.asset(
                                            'assets/images/icons/car_icon.png',
                                            width: 40,
                                            height: 35,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      if (staticStartingPoint != null)
                                        Marker(
                                          width: 80.0,
                                          height: 80.0,
                                          point: staticStartingPoint,
                                          child: const Icon(Icons.location_on,
                                              color: Colors.red, size: 30),
                                        ),
                                      // Markers from markersProvider
                                      ...ref
                                          .watch(markersProvider)
                                          .map((markerData) {
                                        return Marker(
                                          width: 80.0,
                                          height: 80.0,
                                          point: markerData.location,
                                          child: GestureDetector(
                                            onTap: () {
                                              // Display the image in a dialog
                                              showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    AlertDialog(
                                                  content: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 8.0,
                                                                vertical: 4.0),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Text(
                                                              markerData
                                                                  .caption,
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color:
                                                                    Colors.grey,
                                                                fontFamily:
                                                                    'Kadaw',
                                                              ),
                                                            ),
                                                            IconButton(
                                                              icon: const Icon(
                                                                  Icons.close,
                                                                  color: Colors
                                                                      .black),
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Image.network(
                                                        markerData.imagePath,
                                                        fit: BoxFit.cover,
                                                        loadingBuilder: (context,
                                                            child,
                                                            loadingProgress) {
                                                          if (loadingProgress ==
                                                              null) {
                                                            // Image has loaded successfully
                                                            return child;
                                                          } else {
                                                            // Display a loading indicator while the image is loading
                                                            return Center(
                                                              child:
                                                                  CircularProgressIndicator(
                                                                value: loadingProgress
                                                                            .expectedTotalBytes !=
                                                                        null
                                                                    ? loadingProgress
                                                                            .cumulativeBytesLoaded /
                                                                        (loadingProgress.expectedTotalBytes ??
                                                                            1)
                                                                    : null, // Show progress if available
                                                              ),
                                                            );
                                                          }
                                                        },
                                                        errorBuilder: (context,
                                                            error, stackTrace) {
                                                          // Fallback widget in case of an error
                                                          return const Icon(
                                                              Icons
                                                                  .broken_image,
                                                              size: 100);
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                            child: const Icon(
                                              Icons.location_on,
                                              color: Colors
                                                  .blue, // Blue for additional markers
                                              size: 30,
                                            ),
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                  PolylineLayer(polylines: [
                                    Polyline(
                                        points: pathCoordinates,
                                        strokeWidth: 4.0,
                                        color: Colors.blue)
                                  ]),
                                ],
                              ),

                              GlobalVariables.isTripStarted
                                  ? Positioned(
                                      top: 1,
                                      left: 0,
                                      right: 0,
                                      child: Padding(
                                        padding:
                                            EdgeInsets.zero, // Adjust for width
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
                                                    fontFamily: 'KadawBold'),
                                                textAlign: TextAlign.center,
                                              ),
                                              Text(
                                                'Drop a pin to post your map',
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 14,
                                                    fontStyle: FontStyle.italic,
                                                    fontFamily: 'Kadaw'),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                                  : const SizedBox(),

                              // Zoom in/out buttons
                              Positioned(
                                right: 10,
                                top: 70,
                                child: Column(
                                  children: [
                                    FloatingActionButton(
                                      heroTag:
                                          'zoom_in_button_starttrip_1', // Unique tag for the zoom in button
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
                                      heroTag:
                                          'zoom_out_button_starttrip_2', // Unique tag for the zoom out button
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
                                    padding: EdgeInsets.only(
                                        left: vww(context, 15),
                                        right: vww(context, 15),
                                        top: vhh(context, 3)),
                                    child: ButtonWidget(
                                      btnType: GlobalVariables.isTripStarted
                                          ? ButtonWidgetType.endTripTitle
                                          : ButtonWidgetType.startTripTitle,
                                      borderColor: GlobalVariables.isTripStarted
                                          ? Colors.red
                                          : kColorButtonPrimary,
                                      textColor: kColorWhite,
                                      fullColor: GlobalVariables.isTripStarted
                                          ? Colors.red
                                          : kColorButtonPrimary,
                                      onPressed: toggleTrip,
                                    ),
                                  ),
                                ),
                              ),

                              Positioned(
                                bottom: 13,
                                left: 0,
                                right: 0,
                                child: Padding(
                                  padding: EdgeInsets.zero, // Adjust for width
                                  child: Container(
                                    padding: const EdgeInsets.all(
                                        3.0), // Inner padding for spacing around text
                                    color: Colors.white.withOpacity(
                                        0.5), // Background color with slight transparency
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
