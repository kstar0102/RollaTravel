import 'package:RollaTravel/src/screen/trip/start_trip.dart';
import 'package:RollaTravel/src/services/api_service.dart';
import 'package:RollaTravel/src/utils/common.dart';
import 'package:RollaTravel/src/utils/global_variable.dart';
import 'package:RollaTravel/src/utils/stop_marker_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:RollaTravel/src/utils/index.dart';
import 'package:RollaTravel/src/widget/bottombar.dart';
import 'package:RollaTravel/src/translate/en.dart';
import 'package:RollaTravel/src/constants/app_styles.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:ui';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  Future<bool> _onWillPop() async {
    return false;
  }

  Future<void> _onShareClicked() async {
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

    final markerData = MarkerData(
        location: widget.location!,
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
        // Navigate to the next page
        Navigator.pushReplacement(
          // ignore: use_build_context_synchronously
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) =>
                const StartTripScreen(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
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
        Navigator.pushReplacement(
          // ignore: use_build_context_synchronously
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) =>
                const StartTripScreen(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
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
    }
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
                                onPressed: () {
                                  Navigator.pop(context); // Close action
                                },
                              ),
                            ),
                          ],
                        ),

                        // Additional Rows and Summary
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                destination,
                                style: TextStyle(
                                  color: kColorBlack,
                                  fontSize: 14,
                                  fontFamily: 'Kadaw',
                                ),
                              ),
                              Text(
                                edit_destination,
                                style: TextStyle(
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
                        const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.0), // Adjust the value as needed
                          child: Row(
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
                                              left: 10.0, top: 5, bottom: 5),
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
                                        fontSize: 15, fontFamily: 'KadawBold'),
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
                      Colors.black.withOpacity(0.3), // Semi-transparent overlay
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
      bottomNavigationBar: BottomNavBar(currentIndex: _currentIndex),
    );
  }
}
