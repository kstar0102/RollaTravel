import 'dart:convert';
import 'package:RollaTravel/src/constants/app_button.dart';
import 'package:RollaTravel/src/constants/app_styles.dart';
import 'package:RollaTravel/src/screen/trip/end_trip.dart';
import 'package:RollaTravel/src/screen/trip/sound_screen.dart';
import 'package:RollaTravel/src/screen/trip/trip_settting_screen.dart';
import 'package:RollaTravel/src/screen/trip/trip_tag_screen.dart';
import 'package:RollaTravel/src/services/api_service.dart';
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
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  String initialSound = "Edit Playlist";
  double totalDistanceInMiles = 0;
  List<LatLng> pathCoordinates = [];
  bool isStateRestored = false;
  bool _isLoading = false;

  static const String mapboxAccessToken =
      "pk.eyJ1Ijoicm9sbGExIiwiYSI6ImNseGppNHN5eDF3eHoyam9oN2QyeW5mZncifQ.iLIVq7aRpvMf6J3NmQTNAw";

  @override
  void initState() {
    super.initState();
    _getFetchTripData();
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
  }

  void _getFetchTripData() async {
    final prefs = await SharedPreferences.getInstance();
    int? tripId = prefs.getInt("tripId");
    logger.i("Saved local database tripId: $tripId");

    if (tripId != null) {
      _showLoadingDialog();
      final apiserice = ApiService();
      GlobalVariables.isTripStarted = true;
      ref.read(isTripStartedProvider.notifier).state = true;
      try {
        final tripData = await apiserice.fetchTripData(tripId);
        var destinationTextAddress =
            tripData['trips'][0]['destination_text_address'];
        if (destinationTextAddress is String) {
          destinationTextAddress = jsonDecode(destinationTextAddress);
        }
        GlobalVariables.editDestination = destinationTextAddress[0];
        GlobalVariables.tripStartDate = tripData['trips'][0]['trip_start_date'];
        var startLocation = tripData['trips'][0]['start_location'];
        List stopLocations = tripData['trips'][0]['stop_locations'];
        List droppins = tripData['trips'][0]['droppins'];
        List<MarkerData> markers = [];
        stopLocations.asMap().forEach((i, stop) {
          if (stop is Map &&
              stop.containsKey('latitude') &&
              stop.containsKey('longitude')) {
            double latitude = stop['latitude'];
            double longitude = stop['longitude'];

            String imagePath = "";
            String caption = "Trip Stop";

            var droppin = droppins.firstWhere(
              (d) => d['stop_index'] == (i + 1), // Matching stop_index
              orElse: () => null,
            );

            if (droppin != null) {
              imagePath = droppin['image_path'] ?? "";
              caption = droppin['image_caption'] ?? "No caption";
            }

            MarkerData marker = MarkerData(
              location: LatLng(latitude, longitude),
              imagePath: imagePath,
              caption: caption,
            );
            markers.add(marker);
          }
        });

        ref.read(markersProvider.notifier).state = markers;

        if (startLocation is String) {
          RegExp regExp =
              RegExp(r'LatLng\((latitude:([0-9.-]+), longitude:([0-9.-]+))\)');
          Match? match = regExp.firstMatch(startLocation);

          if (match != null) {
            double latitude = double.tryParse(match.group(2) ?? "0.0") ?? 0.0;
            double longitude = double.tryParse(match.group(3) ?? "0.0") ?? 0.0;
            LatLng startLatLng = LatLng(latitude, longitude);
            ref.read(staticStartingPointProvider.notifier).state ??=
                startLatLng;
            setState(() {
              isStateRestored = true;
            });
          } else {
            logger.e("Failed to parse start location string");
            setState(() {
              isStateRestored = true;
            });
          }
        }
      } catch (e) {
        logger.e("Error fetching trip data: $e");
      } finally {
        _hideLoadingDialog();
      }
    } else {
      setState(() {
        isStateRestored = true;
      });
      if (PermissionService().hasLocationPermission) {
        _getCurrentLocation();
      }
      logger.w("No tripId found in local database");
    }
  }

  void _showLoadingDialog() {
    setState(() {
      _isLoading = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CircularProgressIndicator(), // Progress bar
              SizedBox(width: 20),
              Text("Loading..."), // Loading text
            ],
          ),
        );
      },
    );
  }

  void _hideLoadingDialog() {
    if (_isLoading) {
      Navigator.of(context).pop();
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _checkLocationServices() async {
    bool isLocationEnabled = await Geolocator.isLocationServiceEnabled();
    LocationPermission permission = await Geolocator.checkPermission();

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
                // ignore: use_build_context_synchronously
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
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      setState(() {
        currentLocation = LatLng(position.latitude, position.longitude);
        ref.read(staticStartingPointProvider.notifier).state ??=
            currentLocation;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            try {
              _mapController.move(currentLocation!, 12.0);
            } catch (e) {
              logger.e("Error moving map: $e");
            }
          }
        });
      });
      return;
    }

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

  void toggleTrip() {
    if (GlobalVariables.isTripStarted) {
      // ✅ End the trip
      _endTrip();
    } else {
      // ✅ Start the trip
      // _startTrip();
      _noTrackingStartTrip();
    }
  }

  void _noTrackingStartTrip() {
    if (GlobalVariables.editDestination == null) {
      _showDestinationAlert(context);
      return;
    }
    GlobalVariables.isTripStarted = true;
    ref.read(isTripStartedProvider.notifier).state = true;

    // ✅ Record trip start time
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
    GlobalVariables.tripStartDate = formattedDate;
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

  void _endTrip() async {
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );

    LatLng? startLocation = ref.read(staticStartingPointProvider);
    LatLng? endLocation = LatLng(position.latitude, position.longitude);
    List<MarkerData> stopMarkers = ref.read(markersProvider);

    logger.i("endlocation : $endLocation");

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
                  Navigator.of(context).pop();
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
      return;
    }

    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
    GlobalVariables.tripEndDate = formattedDate;

    String tripMiles =
        "${GlobalVariables.totalDistance.toStringAsFixed(3)} miles";

    if (GlobalVariables.tripStartDate != null &&
        GlobalVariables.tripEndDate != null) {
      if (!mounted) return;
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
            endDestination: GlobalVariables.editDestination!,
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

  void _onDestintionClick() {
    TextEditingController textController =
        TextEditingController(text: GlobalVariables.editDestination ?? "");

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Edit Destination",
            style: TextStyle(fontFamily: 'interBold'),
          ),
          content: TextField(
            controller: textController,
            decoration: const InputDecoration(
                hintText: "Enter destination",
                hintStyle: TextStyle(fontFamily: 'inter')),
            style: const TextStyle(fontFamily: 'inter', fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text(
                "Cancel",
                style:
                    TextStyle(fontFamily: 'inter', color: kColorButtonPrimary),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  GlobalVariables.editDestination = textController.text;
                });
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text(
                "OK",
                style:
                    TextStyle(fontFamily: 'inter', color: kColorCreateButton),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final pathCoordinates = ref.watch(pathCoordinatesProvider);
    final movingLocation = ref.watch(movingLocationProvider);
    final staticStartingPoint = ref.watch(staticStartingPointProvider);
    final isTripStarted = ref.watch(isTripStartedProvider);

    return Scaffold(
      backgroundColor: kColorWhite,
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            return;
          }
        },
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
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.1,
                                fontFamily: 'inter'),
                          ),
                          GestureDetector(
                            onTap: () {
                              _onDestintionClick();
                            },
                            child: Text(
                              GlobalVariables.editDestination != null &&
                                      GlobalVariables
                                          .editDestination!.isNotEmpty
                                  ? (GlobalVariables.editDestination!.length >
                                          30
                                      ? '${GlobalVariables.editDestination!.substring(0, 30)}...'
                                      : GlobalVariables.editDestination!)
                                  : "Edit Destination",
                              style: const TextStyle(
                                color: kColorButtonPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.1,
                                fontFamily: 'inter',
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
                      SizedBox(
                        height: vh(context, 2),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            soundtrack,
                            style: TextStyle(
                                color: kColorBlack,
                                fontSize: 13,
                                letterSpacing: -0.1,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'inter'),
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
                                  fontSize: 13,
                                  letterSpacing: -0.1,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                  decorationColor: kColorButtonPrimary,
                                  fontFamily: 'inter'),
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
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.black),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 1.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment
                          .start, // Remove vertical misalignment
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 5),
                          child: Text(
                            'Caption:',
                            style: TextStyle(
                              color: kColorBlack,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.1,
                              fontFamily: 'inter',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _captionController,
                            decoration: const InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                              hintText: '',
                            ),
                            style: const TextStyle(
                              fontSize: 14,
                              color: kColorBlack,
                              fontFamily: 'inter',
                            ),
                            minLines: 2,
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
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
                                  initialZoom: 12.0,
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
                                          child: Icon(
                                            isTripStarted
                                                ? Icons.flag
                                                : Icons.location_on,
                                            color: isTripStarted
                                                ? Colors.red
                                                : Colors.red,
                                            size: 30,
                                          ),
                                        ),
                                      // Markers from markersProvider
                                      ...ref
                                          .watch(markersProvider)
                                          .asMap()
                                          .entries
                                          .map((entry) {
                                        int index = entry.key +
                                            1; // Get the index (starting from 1)
                                        MarkerData markerData = entry.value;

                                        return Marker(
                                          width: 20.0,
                                          height: 20.0,
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
                                                                    'inter',
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
                                                            return child;
                                                          } else {
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
                                                                    : null,
                                                              ),
                                                            );
                                                          }
                                                        },
                                                        errorBuilder: (context,
                                                            error, stackTrace) {
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
                                            child: Container(
                                              width: 10,
                                              height: 10,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors
                                                    .white, // White background
                                                border: Border.all(
                                                    color: Colors.black,
                                                    width: 2), // Black border
                                              ),
                                              alignment: Alignment.center,
                                              child: Text(
                                                index
                                                    .toString(), // Display index number
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
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
                                          // ignore: deprecated_member_use
                                          color: Colors.white.withOpacity(0.5),
                                          child: const Column(
                                            children: [
                                              Text(
                                                'Trip in progress',
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 14,
                                                    fontStyle: FontStyle.italic,
                                                    fontFamily: 'interBold'),
                                                textAlign: TextAlign.center,
                                              ),
                                              Text(
                                                'Drop a pin to post your map',
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 14,
                                                    fontStyle: FontStyle.italic,
                                                    fontFamily: 'inter'),
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
                                    child: Consumer(
                                      builder: (context, ref, _) {
                                        final isTripStarted =
                                            ref.watch(isTripStartedProvider);
                                        return ButtonWidget(
                                          btnType: isTripStarted
                                              ? ButtonWidgetType.endTripTitle
                                              : ButtonWidgetType.startTripTitle,
                                          borderColor: isTripStarted
                                              ? Colors.red
                                              : kColorButtonPrimary,
                                          textColor: kColorWhite,
                                          fullColor: isTripStarted
                                              ? Colors.red
                                              : kColorButtonPrimary,
                                          onPressed: toggleTrip,
                                        );
                                      },
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
                                    color: Colors.white.withAlpha(
                                        128), // Background color with slight transparency
                                    child: const Text(
                                      'Note: Start trip, then drop a pin to make\nyour post visible to your followers',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 14,
                                        fontStyle: FontStyle.italic,
                                        fontFamily: 'inter',
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
