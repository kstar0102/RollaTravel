import 'package:RollaTravel/src/screen/trip/start_trip.dart';
import 'package:RollaTravel/src/services/api_service.dart';
import 'package:RollaTravel/src/utils/common.dart';
import 'package:RollaTravel/src/utils/global_variable.dart';
import 'package:RollaTravel/src/utils/stop_marker_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:RollaTravel/src/utils/index.dart';
import 'package:RollaTravel/src/constants/app_styles.dart';
import 'package:RollaTravel/src/translate/en.dart';
import 'package:logger/logger.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:RollaTravel/src/widget/bottombar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EndTripScreen extends ConsumerStatefulWidget {
  final LatLng? startLocation;
  final LatLng? endLocation;
  final List<MarkerData> stopMarkers;
  final String tripStartDate;
  final String tripEndDate;
  final String tripDistance;
  final String endDestination;

  const EndTripScreen(
      {super.key,
      required this.startLocation,
      required this.endLocation,
      required this.stopMarkers,
      required this.tripStartDate,
      required this.tripEndDate,
      required this.tripDistance,
      required this.endDestination});

  @override
  ConsumerState<EndTripScreen> createState() => _EndTripScreenState();
}

class _EndTripScreenState extends ConsumerState<EndTripScreen> {
  double screenHeight = 0;
  double keyboardHeight = 0;
  final int _currentIndex = 2;
  final Logger logger = Logger();
  final MapController _mapController = MapController();
  double totalDistanceInMeters = 0;

  String? startAddress;
  String? endAddress;
  String stopAddressesString = "";
  List<String> formattedStopAddresses = [];
  List<Map<String, dynamic>> droppins = [];

  @override
  void initState() {
    super.initState();
    _fetchAddresses();
    // _fetchRoute();
    _fetchDropPins();
    logger.i(GlobalVariables.editDestination);
    logger.i(widget.endDestination);
  }

  @override
  void dispose() {
    super.dispose();
    _mapController.dispose();
  }

  Future<void> _fetchDropPins() async {
    // Convert the list of MarkerData to the desired format
    droppins = widget.stopMarkers.asMap().entries.map((entry) {
      final int index = entry.key + 1; // stop_index starts from 1
      final MarkerData marker = entry.value;

      return {
        "stop_index": index,
        "image_path": marker.imagePath,
        "image_caption": marker.caption,
      };
    }).toList();

    // Log the formatted droppins
    // logger.i("Droppins: $droppins");
  }

  Future<void> _fetchAddresses() async {
    if (widget.startLocation != null) {
      // logger.i('start location : $widget.startLocation');
      startAddress = await Common.getAddressFromLocation(widget.startLocation!);
      // logger.i("startAddress : $startAddress");
    }

    if (widget.endLocation != null) {
      endAddress = await Common.getAddressFromLocation(widget.endLocation!);
      // logger.i("endAddress : $endAddress");
    }

    if (widget.stopMarkers != []) {
      List<String?> stopMarkerAddresses = await Future.wait(
        widget.stopMarkers.map((marker) async {
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
  }

  Future<void> sendTripData() async {
    final apiserice = ApiService();

    // Convert pathCoordinates to List<Map<String, double>>
    final tripCoordinates = ref
        .read(pathCoordinatesProvider)
        .map((latLng) => {
              'latitude': latLng.latitude,
              'longitude': latLng.longitude,
            })
        .toList();

    final stopLocations = widget.stopMarkers
        .map((marker) => {
              'latitude': marker.location.latitude,
              'longitude': marker.location.longitude,
            })
        .toList();

    String formattedDestination = '["${GlobalVariables.editDestination}"]';

    final prefs = await SharedPreferences.getInstance();
    int? tripId = prefs.getInt("tripId");

    final response = await apiserice.updateTrip(
      tripId: tripId!,
      userId: GlobalVariables.userId!,
      startAddress: startAddress!,
      stopAddresses: stopAddressesString,
      destinationAddress: endAddress!,
      destinationTextAddress: formattedDestination,
      tripStartDate: widget.tripStartDate,
      tripEndDate: widget.tripEndDate,
      tripMiles: widget.tripDistance,
      tripSound: "tripSound",
      stopLocations: stopLocations,
      tripCoordinates: tripCoordinates,
      startLocation: widget.startLocation.toString(),
      destinationLocation: widget.endLocation.toString(),
      droppins: [],
    );

    if (!mounted) return;

    if (response['success'] == true) {
      await prefs.remove("tripId");
      await prefs.remove("dropcount");

      // Navigate to the next page
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) =>
                const StartTripScreen(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      }
      ref.read(pathCoordinatesProvider.notifier).state = [];
      ref.read(movingLocationProvider.notifier).state = null;
    } else {
      // Extract error message from the API response
      String errorMessage =
          response['error'] ?? 'Failed to create the trip. Please try again.';

      // Show an alert dialog with the error message
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Error"),
            content: Text(errorMessage),
            actions: [
              TextButton(
                child: const Text("OK"),
                onPressed: () {
                  ref.read(pathCoordinatesProvider.notifier).state = [];
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pathCoordinates = ref.watch(pathCoordinatesProvider);
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
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: vhh(context, 5),
                    ),
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
                                  icon: const Icon(Icons.close,
                                      color: Colors.black, size: 28),
                                  onPressed: () {
                                    ref
                                        .read(pathCoordinatesProvider.notifier)
                                        .state = [];
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const StartTripScreen()));
                                  },
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0), // Adjust the value as needed
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  destination,
                                  style: TextStyle(
                                      color: kColorBlack,
                                      fontSize: 14,
                                      fontFamily: 'Kadaw'),
                                ),
                                Flexible(
                                  // Ensures the text takes available space without being cut off
                                  child: Text(
                                    GlobalVariables.editDestination ?? '',
                                    style: const TextStyle(
                                      color: kColorButtonPrimary,
                                      fontSize: 14,
                                      decoration: TextDecoration.underline,
                                      decorationColor: kColorButtonPrimary,
                                      fontFamily: 'Kadaw',
                                    ),
                                    softWrap:
                                        true, // Ensures text wraps instead of truncating
                                    overflow: TextOverflow
                                        .visible, // Makes sure text is displayed fully
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0), // Adjust the value as needed
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  miles_traveled,
                                  style: TextStyle(
                                      color: kColorBlack,
                                      fontSize: 14,
                                      fontFamily: 'Kadaw'),
                                ),
                                Text(
                                  widget.tripDistance,
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
                                horizontal: 10.0), // Adjust the value as needed
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

                          // Map Image
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: vww(context, 4)),
                            child: SizedBox(
                              height: vhh(context, 30),
                              child: Stack(
                                children: [
                                  FlutterMap(
                                    mapController: _mapController,
                                    options: MapOptions(
                                      initialCenter: widget.startLocation!,
                                      initialZoom: 16.0,
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
                                      if (pathCoordinates.isNotEmpty)
                                        PolylineLayer(
                                          polylines: [
                                            Polyline(
                                              points: pathCoordinates,
                                              strokeWidth: 4.0,
                                              color: Colors.blue,
                                            ),
                                          ],
                                        ),
                                      MarkerLayer(
                                        markers: [
                                          if (widget.startLocation != null)
                                            Marker(
                                              width: 80.0,
                                              height: 80.0,
                                              point: widget.startLocation!,
                                              child: const Icon(
                                                  Icons.location_on,
                                                  color: Colors.red,
                                                  size: 40),
                                            ),
                                          if (widget.endLocation != null)
                                            Marker(
                                              width: 80.0,
                                              height: 80.0,
                                              point: widget.endLocation!,
                                              child: const Icon(
                                                  Icons.location_on,
                                                  color: Colors.green,
                                                  size: 40),
                                            ),
                                          if (widget.stopMarkers.isNotEmpty)
                                            ...widget.stopMarkers
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
                                                                      horizontal:
                                                                          8.0,
                                                                      vertical:
                                                                          4.0),
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
                                                                      fontSize:
                                                                          16,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Colors
                                                                          .grey,
                                                                      fontFamily:
                                                                          'Kadaw',
                                                                    ),
                                                                  ),
                                                                  IconButton(
                                                                    icon: const Icon(
                                                                        Icons
                                                                            .close,
                                                                        color: Colors
                                                                            .black),
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                    },
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            Image.network(
                                                              markerData
                                                                  .imagePath,
                                                              fit: BoxFit.cover,
                                                              loadingBuilder:
                                                                  (context,
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
                                                                      value: loadingProgress.expectedTotalBytes !=
                                                                              null
                                                                          ? loadingProgress.cumulativeBytesLoaded /
                                                                              (loadingProgress.expectedTotalBytes ?? 1)
                                                                          : null, // Show progress if available
                                                                    ),
                                                                  );
                                                                }
                                                              },
                                                              errorBuilder:
                                                                  (context,
                                                                      error,
                                                                      stackTrace) {
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
                                                    size: 40,
                                                  ),
                                                ),
                                              );
                                            }),
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
                                          heroTag: 'zoom_in_button_endtrip_1',
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
                                          heroTag: 'zoom_in_button_endtrip_2',
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
                            style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'KadawBold',
                                color: Colors.grey),
                          ),
                          const SizedBox(height: 15),
                          const Text(
                            'the Rolla travel app',
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                                fontFamily: 'Kadaw'),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Post this travel:',
                          style: TextStyle(fontSize: 16, fontFamily: 'Kadaw'),
                        ),
                        GestureDetector(
                          onTap: () {
                            sendTripData();
                          },
                          // child: Image.asset(
                          //   "assets/images/icons/share.png",
                          //   height: 50,
                          // ),
                          child: const Icon(
                            Icons.post_add, // Material Design "Post" icon
                            size: 50,
                            color:
                                kColorCreateButton, // Adjust the color to match your theme
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )),
      bottomNavigationBar: BottomNavBar(currentIndex: _currentIndex),
    );
  }
}
