import 'dart:io';
// import 'dart:typed_data';
import 'dart:ui';
import 'package:RollaTravel/src/screen/trip/sound_screen.dart';
import 'package:RollaTravel/src/screen/trip/start_trip.dart';
import 'package:RollaTravel/src/utils/global_variable.dart';
import 'package:RollaTravel/src/utils/spinner_loader.dart';
import 'package:RollaTravel/src/utils/stop_marker_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:RollaTravel/src/utils/index.dart';
import 'package:RollaTravel/src/constants/app_styles.dart';
import 'package:RollaTravel/src/translate/en.dart';
import 'package:logger/logger.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:RollaTravel/src/widget/bottombar.dart';
// import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class EndTripScreen extends ConsumerStatefulWidget {
  final LatLng? startLocation;
  final LatLng? endLocation;
  final List<MarkerData> stopMarkers;
  final String tripStartDate;
  final String tripEndDate;
  final String endDestination;

  const EndTripScreen(
      {super.key,
      required this.startLocation,
      required this.endLocation,
      required this.stopMarkers,
      required this.tripStartDate,
      required this.tripEndDate,
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
  final GlobalKey mapKey = GlobalKey();
  final GlobalKey _shareWidgetKey = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _mapController.dispose();
  }

  // Future<Uint8List?> captureMap() async {
  //   try {
  //     RenderRepaintBoundary boundary =
  //         mapKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
  //     var image = await boundary.toImage(pixelRatio: 3.0);
  //     ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
  //     return byteData?.buffer.asUint8List();
  //   } catch (e) {
  //     logger.i('Error capturing map: $e');
  //     return null;
  //   }
  // }

  // Future<void> shareCapturedMap() async {
  //   try {
  //     final capturedBytes = await captureMap();
  //     if (capturedBytes == null) {
  //       if (!mounted) return;
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Failed to capture the map')),
  //       );
  //       return;
  //     }

  //     final tempDir = await getTemporaryDirectory();
  //     final file = await File('${tempDir.path}/captured_map.png').create();
  //     await file.writeAsBytes(capturedBytes);

  //     await Share.shareXFiles([XFile(file.path)], text: 'Check out my trip map!');
  //   } catch (e) {
  //     logger.i('Error while sharing map: $e');
  //     if (!mounted) return;
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Error sharing the map: $e')),
  //     );
  //   }
  // }

  Future<void> _onShareClicked() async {
    try {
      RenderRepaintBoundary boundary = _shareWidgetKey.currentContext?.findRenderObject() as RenderRepaintBoundary;
      if (boundary.debugNeedsPaint) {
        await Future.delayed(const Duration(milliseconds: 20));
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      final tempDir = await Directory.systemTemp.createTemp();
      final file = await File('${tempDir.path}/shared_polaroid.png').create();
      await file.writeAsBytes(pngBytes);

      await Share.shareXFiles([XFile(file.path)]);
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
    final pathCoordinates = ref.watch(pathCoordinatesProvider);
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
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: vhh(context, 8),
                    ),
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
                            ]
                        ),
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                Center(
                                  child: GestureDetector(
                                    onTap: () {

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
                                    onPressed: () {
                                      GlobalVariables.editDestination = null;
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
                                  horizontal: 11.0), 
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    destination,
                                    style: TextStyle(
                                        color: kColorBlack,
                                        fontSize: 13,
                                        letterSpacing: -0.1,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'inter',),
                                  ),
                                  Flexible(
                                    child: Text(
                                      widget.endDestination,
                                      style: const TextStyle(
                                        color: kColorButtonPrimary,
                                        fontSize: 14,
                                        decoration: TextDecoration.underline,
                                        decorationColor: kColorButtonPrimary,
                                        fontFamily: 'inter',
                                      ),
                                      softWrap: true, 
                                      overflow: TextOverflow.visible,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    soundtrack,
                                    style: TextStyle(
                                        color: kColorBlack,
                                        fontSize: 13,
                                        letterSpacing: -0.1,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'inter',),
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
                            const SizedBox(height: 10),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: vww(context, 2)),
                              child: Container(
                                height: vhh(context, 30),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: kColorStrongGrey,
                                    width: 1,            
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    RepaintBoundary(
                                      key: mapKey,
                                      child: FlutterMap(
                                        mapController: _mapController,
                                        options: MapOptions(
                                          initialCenter: widget.startLocation!,
                                          initialZoom: 11.0,
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
                                              // if (widget.startLocation != null)
                                              //   Marker(
                                              //     width: 80.0,
                                              //     height: 80.0,
                                              //     point: widget.startLocation!,
                                              //     child: const Icon(Icons.flag,
                                              //         color: Colors.red, size: 40),
                                              //   ),
                                              // if (widget.endLocation != null)
                                              //   Marker(
                                              //     width: 80.0,
                                              //     height: 80.0,
                                              //     point: widget.endLocation!,
                                              //     child: const Icon(Icons.flag,
                                              //         color: Colors.green,
                                              //         size: 40),
                                              //   ),
                                              if (widget.stopMarkers.isNotEmpty)
                                                ...widget.stopMarkers
                                                    .map((markerData) {
                                                  int index = widget.stopMarkers
                                                          .indexOf(markerData) +
                                                      1;
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
                                                                              'inter',
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
                                                                      return child;
                                                                    } else {
                                                                      return const Center(
                                                                        child: SpinningLoader(),
                                                                      );
                                                                    }
                                                                  },
                                                                  errorBuilder:
                                                                      (context,
                                                                          error,
                                                                          stackTrace) {
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
                                                        width:30, 
                                                        height: 30,
                                                        decoration: BoxDecoration(
                                                          shape: BoxShape.circle,
                                                          color: Colors
                                                              .white, 
                                                          border: Border.all(
                                                            color: Colors.black,
                                                            width:
                                                                2, // Black border
                                                          ),
                                                        ),
                                                        alignment: Alignment.center,
                                                        child: Text(
                                                          index
                                                              .toString(), // Display index number
                                                          style: const TextStyle(
                                                            fontSize: 13,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                }),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Zoom in/out buttons
                                    // Positioned(
                                    //   right: 10,
                                    //   top: 30,
                                    //   child: Column(
                                    //     children: [
                                    //       FloatingActionButton(
                                    //         heroTag: 'zoom_in_button_endtrip_1',
                                    //         onPressed: () {
                                    //           _mapController.move(
                                    //             _mapController.camera.center,
                                    //             _mapController.camera.zoom + 1,
                                    //           );
                                    //         },
                                    //         mini: true,
                                    //         child: const Icon(Icons.zoom_in),
                                    //       ),
                                    //       const SizedBox(height: 8),
                                    //       FloatingActionButton(
                                    //         heroTag: 'zoom_in_button_endtrip_2',
                                    //         onPressed: () {
                                    //           _mapController.move(
                                    //             _mapController.camera.center,
                                    //             _mapController.camera.zoom - 1,
                                    //           );
                                    //         },
                                    //         mini: true,
                                    //         child: const Icon(Icons.zoom_out),
                                    //       ),
                                    //     ],
                                    //   ),
                                    // ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),
                            // Footer Text
                            // const Text(
                            //   'Travel. Share.',
                            //   style: TextStyle(
                            //       fontSize: 16,
                            //       fontFamily: 'interBold',
                            //       color: Colors.grey),
                            // ),
                            Image.asset(
                                      'assets/images/icons/logo.png',
                                      width: 90,
                                      height: 80,
                                    ),
                            const SizedBox(height: 15),
                            const Text(
                              'the Rolla travel app',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                  fontFamily: 'inter'),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Padding(
                        padding: EdgeInsets.only(top: 10.0),
                        child: Text(
                          "Share this summary:",
                            style: TextStyle(
                              fontSize: 14,
                              color: kColorStrongGrey,
                              fontStyle: FontStyle.italic,
                              fontFamily: 'inter',
                            ),
                          ),
                        ),
                        const SizedBox(height: 15,),
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
                  ],
                ),
              ),
            ),
          )),
      bottomNavigationBar: BottomNavBar(currentIndex: _currentIndex),
    );
  }
}
