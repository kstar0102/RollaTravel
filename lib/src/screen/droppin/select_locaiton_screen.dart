import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:RollaTravel/src/constants/app_styles.dart';
import 'package:RollaTravel/src/screen/droppin/another_location_screen.dart';
import 'package:RollaTravel/src/screen/droppin/choosen_location_screen.dart';
import 'package:RollaTravel/src/services/api_service.dart';
import 'package:RollaTravel/src/utils/common.dart';
import 'package:RollaTravel/src/utils/global_variable.dart';
import 'package:RollaTravel/src/utils/stop_marker_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:RollaTravel/src/widget/bottombar.dart';
import 'package:RollaTravel/src/utils/index.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

class SelectLocationScreen extends ConsumerStatefulWidget {
  final LatLng? selectedLocation;
  final String caption;
  final String imagePath;
  const SelectLocationScreen(
      {super.key,
      required this.selectedLocation,
      required this.caption,
      required this.imagePath});

  @override
  ConsumerState<SelectLocationScreen> createState() =>
      SelectLocationScreenState();
}

class SelectLocationScreenState extends ConsumerState<SelectLocationScreen> {
  double screenHeight = 0;
  double keyboardHeight = 0;
  final int _currentIndex = 3;
  final logger = Logger();
  LatLng? _currentLocation;
  final MapController _mapController = MapController();
  final Completer<void> _mapReadyCompleter = Completer<void>();
  bool isuploadingImage = false;
  String? tripMiles;
  String? startAddress;
  List<String> formattedStopAddresses = [];
  String stopAddressesString = "";
  List<Map<String, dynamic>> droppins = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
      if (mounted) {
        setState(() {
          this.keyboardHeight = keyboardHeight;
        });
      }
    });
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
      // Permission granted, fetch current location
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        logger.i("Location: $_currentLocation");
      });
      await _mapReadyCompleter.future;
      _mapController.move(_currentLocation!, 13.0);
    } else if (permissionStatus.isDenied ||
        permissionStatus.isPermanentlyDenied) {
      // Permission denied - prompt user to open settings
      logger.i("Location permission denied. Redirecting to settings.");
      _showPermissionDeniedDialog();
    } else {
      logger.i("Location permission status: $permissionStatus");
    }
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
                await openAppSettings(); // This will open app settings
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

  void _showImageDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
              horizontal: 30), // Adjust padding to match the screenshot
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Caption and Close Icon Row
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Caption",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.black),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              // Image
              Image.asset(
                "assets/images/background/Lake1.png",
                fit: BoxFit.cover,
                width: vww(context, 90),
                height: vhh(context, 70),
              ),
              const Divider(
                  height: 1,
                  color: Colors.grey), // Divider between image and footer
              SizedBox(height: vhh(context, 5))
            ],
          ),
        );
      },
    );
  }

  Future<void> _dropPinButtonSelected() async {
    final apiserice = ApiService();
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      isuploadingImage = true;
    });
    File imageFile = File(widget.imagePath);
    List<int> imageBytes = await imageFile.readAsBytes();
    String base64String = base64Encode(imageBytes);
    final apiService = ApiService();
    String imageUrl = await apiService.getImageUrl(base64String);

    if (imageUrl.isNotEmpty) {
      setState(() {
        isuploadingImage = false;
      });
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed upload image....'),
        ),
      );
      return;
    }

    LatLng? testlocation;
    testlocation = widget.selectedLocation;

    final LatLng selectedLocation = (testlocation!.latitude == 0.0 &&
            testlocation.longitude == 0.0)
        ? _currentLocation! // Use _currentLocation if testlocation is invalid
        : testlocation; // Otherwise, use testlocation

    logger.i("Selected location : $selectedLocation");

    final markerData = MarkerData(
        location: selectedLocation, // Use the valid location
        imagePath: imageUrl,
        caption: widget.caption);

// Add the marker to the provider
    ref.read(markersProvider.notifier).state = [
      ...ref.read(markersProvider),
      markerData,
    ];

    LatLng? startLocation = ref.read(staticStartingPointProvider);
    logger.i("startLocation : $startLocation");
    List<MarkerData> stopMarkers = ref.read(markersProvider);
    tripMiles = "${GlobalVariables.totalDistance.toStringAsFixed(3)} miles";
    if (startLocation != null) {
      startAddress = await Common.getAddressFromLocation(startLocation);
    }

    if (stopMarkers != []) {
      List<String?> stopMarkerAddresses = await Future.wait(
        stopMarkers.map((marker) async {
          try {
            final address =
                await Common.getAddressFromLocation(marker.location);
            return address ?? "";
          } catch (e) {
            logger.e(
                "Error fetching address for marker at ${marker.location}: $e");
            return "";
          }
        }),
      );

      // Format the list as JSON-like array
      formattedStopAddresses =
          stopMarkerAddresses.map((address) => '"$address"').toList();
      stopAddressesString = '[${formattedStopAddresses.join(', ')}]';
    }

    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

    final tripCoordinates = ref
        .read(pathCoordinatesProvider)
        .map((latLng) => {
              'latitude': latLng.latitude,
              'longitude': latLng.longitude,
            })
        .toList();

    final stopLocations = stopMarkers
        .map((marker) => {
              'latitude': marker.location.latitude,
              'longitude': marker.location.longitude,
            })
        .toList();

    String formattedDestination = '["${GlobalVariables.editDestination}"]';
    int? tripId = prefs.getInt("tripId");
    logger.i("tripId : $tripId");

    final Map<String, dynamic> response;

    if (tripId != null) {
      int? dropPinId = prefs.getInt("droppinId"); // Initial droppinId
      int? dropcount = prefs.getInt("dropcount"); // Get dropcount
      int currentDropId = dropPinId ?? 0; // Use 0 if droppinId is null

      droppins = stopMarkers.asMap().entries.map((entry) {
        final int index = entry.key + 1; // stop_index starts from 1
        final MarkerData marker = entry.value;

        // Check if we are within the range of dropcount
        if (dropPinId != null && entry.key < dropcount!) {
          final mapData = {
            "id": currentDropId, // Use the current drop ID
            "stop_index": index,
            "image_path": marker.imagePath,
            "image_caption": marker.caption,
          };
          currentDropId++; // Increment dropPinId for the next iteration
          return mapData;
        } else {
          // After dropcount, do not include droppinId
          return {
            "stop_index": index,
            "image_path": marker.imagePath,
            "image_caption": marker.caption,
          };
        }
      }).toList();

      response = await apiserice.updateTrip(
        tripId: tripId,
        userId: GlobalVariables.userId!,
        startAddress: startAddress!,
        stopAddresses: stopAddressesString,
        destinationAddress: "Destination address for DropPin",
        destinationTextAddress: formattedDestination,
        tripStartDate: GlobalVariables.tripStartDate!,
        tripEndDate: formattedDate,
        tripMiles: tripMiles!,
        tripSound: "tripSound",
        stopLocations: stopLocations,
        tripCoordinates: tripCoordinates,
        droppins: droppins,
      );

      if (response['success'] == true) {
        await prefs.setInt("tripId", response['trip']['id']);
        await prefs.setInt("dropcount", response['trip']['droppins'].length);
        if (mounted) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ChoosenLocationScreen(
                        caption: widget.caption,
                        imagePath: widget.imagePath,
                        location: _currentLocation,
                      )));
        }
      } else {
        // Extract error message from the API response
        String errorMessage =
            response['error'] ?? 'Failed to create the trip. Please try again.';

        // Show an alert dialog with the error message
        showDialog(
          // ignore: use_build_context_synchronously
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Error"),
              content: Text(errorMessage),
              actions: [
                TextButton(
                  child: const Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                ),
              ],
            );
          },
        );
      }
    } else {
      droppins = stopMarkers.asMap().entries.map((entry) {
        final int index = entry.key + 1; // stop_index starts from 1
        final MarkerData marker = entry.value;
        return {
          "stop_index": index,
          "image_path": marker.imagePath,
          "image_caption": marker.caption,
        };
      }).toList();
      response = await apiserice.createTrip(
        userId: GlobalVariables.userId!,
        startAddress: startAddress!,
        stopAddresses: stopAddressesString,
        destinationAddress: "Destination address for DropPin",
        destinationTextAddress: formattedDestination,
        tripStartDate: GlobalVariables.tripStartDate!,
        tripEndDate: formattedDate,
        tripMiles: tripMiles!,
        tripSound: "tripSound",
        stopLocations: stopLocations,
        tripCoordinates: tripCoordinates,
        droppins: droppins,
      );
      logger.i(response);

      if (response['success'] == true) {
        await prefs.setInt("tripId", response['trip']['id']);
        logger.i(response['trip']['droppins'][0]['id']);
        await prefs.setInt("droppinId", response['trip']['droppins'][0]['id']);
        await prefs.setInt("dropcount", response['trip']['droppins'].length);
        // Navigate to the next page
        if (mounted) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ChoosenLocationScreen(
                        caption: widget.caption,
                        imagePath: widget.imagePath,
                        location: _currentLocation,
                      )));
        } else {
          // Extract error message from the API response
          String errorMessage = response['error'] ??
              'Failed to create the trip. Please try again.';

          // Show an alert dialog with the error message
          showDialog(
            // ignore: use_build_context_synchronously
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Error"),
                content: Text(errorMessage),
                actions: [
                  TextButton(
                    child: const Text("OK"),
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                  ),
                ],
              );
            },
          );
        }
      }
    }
  }

  void _onOtherLocationButtonSelected() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AnotherLocationScreen(
                  caption: widget.caption,
                  imagePath: widget.imagePath,
                  location: _currentLocation,
                )));
  }

  Future<bool> _onWillPop() async {
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kColorWhite,
      // ignore: deprecated_member_use
      body: WillPopScope(
          onWillPop: _onWillPop,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Logo and close button aligned at the top
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Image.asset('assets/images/icons/logo.png',
                              height: vhh(context, 12)),
                          IconButton(
                            icon: const Icon(Icons.close, size: 30),
                            onPressed: () {
                              Navigator.of(context).pop(); // Close the screen
                            },
                          ),
                        ],
                      ),
                    ),

                    //title
                    const Center(
                      child: Text(
                        'Select Location',
                        style: TextStyle(
                          fontSize: 24,
                          fontFamily: 'Kadaw',
                          color: Colors.black,
                        ),
                      ),
                    ),

                    // set map
                    Center(
                      child: SizedBox(
                        height: vhh(context, 36),
                        width: vww(context, 96),
                        child: Center(
                            child: Stack(
                          children: [
                            FlutterMap(
                              mapController: _mapController,
                              options: MapOptions(
                                initialCenter: _currentLocation ??
                                    const LatLng(37.7749, -122.4194),
                                initialZoom: 12.0,
                                onMapReady: () {
                                  _mapReadyCompleter.complete();
                                },
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate:
                                      "https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/{z}/{x}/{y}?access_token=pk.eyJ1Ijoicm9sbGExIiwiYSI6ImNseGppNHN5eDF3eHoyam9oN2QyeW5mZncifQ.iLIVq7aRpvMf6J3NmQTNAw",
                                  additionalOptions: const {
                                    'access_token':
                                        'pk.eyJ1Ijoicm9sbGExIiwiYSI6ImNseGppNHN5eDF3eHoyam9oN2QyeW5mZncifQ.iLIVq7aRpvMf6J3NmQTNAw',
                                  },
                                ),
                                MarkerLayer(markers: [
                                  if (widget.selectedLocation ==
                                      const LatLng(0, 0))
                                    Marker(
                                      width: 80.0,
                                      height: 80.0,
                                      point: _currentLocation ??
                                          const LatLng(43.1557, -77.6157),
                                      child: GestureDetector(
                                        onTap: () => _showImageDialog(),
                                        child: const Icon(Icons.location_on,
                                            color: Colors.red, size: 40),
                                      ),
                                    )
                                  else if (widget.selectedLocation !=
                                      const LatLng(0, 0))
                                    Marker(
                                      width: 80.0,
                                      height: 80.0,
                                      point: widget.selectedLocation ??
                                          const LatLng(43.1557, -77.6157),
                                      child: GestureDetector(
                                        onTap: () => _showImageDialog(),
                                        child: const Icon(Icons.location_on,
                                            color: Colors.red, size: 40),
                                      ),
                                    )
                                ]),
                              ],
                            ),
                            Positioned(
                              right: 10,
                              top: 70,
                              child: Column(
                                children: [
                                  FloatingActionButton(
                                    heroTag:
                                        'zoom_in_button_droppin', // Unique tag for the zoom in button
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
                                        'zoom_out_button_droppin', // Unique tag for the zoom out button
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
                              top: 5,
                              left: 0,
                              right: 0,
                              child: Padding(
                                padding: EdgeInsets.zero, // Adjust for width
                                child: Container(
                                  padding: const EdgeInsets.all(
                                      5.0), // Inner padding for spacing around text
                                  child: Text(
                                    'Tap the pin to see your photo',
                                    style: TextStyle(
                                        // ignore: deprecated_member_use
                                        color: Colors.black.withOpacity(0.8),
                                        fontSize: 14,
                                        fontStyle: FontStyle.italic,
                                        fontFamily: 'Kadaw'),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )),
                      ),
                    ),
                    SizedBox(
                      height: vhh(context, 5),
                    ),

                    // drop button
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: ElevatedButton(
                          onPressed: _dropPinButtonSelected,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            backgroundColor: kColorHereButton,
                            minimumSize: const Size(
                                350, 30), // Set button width and height
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(10), // Rounded corners
                            ),
                          ),
                          child: const Text(
                              'Drop pin at location displayed above',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontFamily: 'Kadaw')),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: vhh(context, 1),
                    ),
                    const Center(
                      child: Text(
                        "OR",
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                            fontFamily: 'Kadaw'),
                      ),
                    ),
                    SizedBox(
                      height: vhh(context, 1),
                    ),
                    //choose another location buttion with underline
                    GestureDetector(
                      onTap: () {
                        _onOtherLocationButtonSelected();
                      },
                      child: const Text(
                        "Choose another location",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.black,
                            fontFamily: 'Kadaw'),
                      ),
                    ),
                    // BackdropFilter for uploading state
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
          )),

      bottomNavigationBar: BottomNavBar(currentIndex: _currentIndex),
    );
  }
}
