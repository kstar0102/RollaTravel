import 'package:RollaTravel/src/constants/app_styles.dart';
import 'package:RollaTravel/src/screen/home/home_screen.dart';
import 'package:RollaTravel/src/utils/global_variable.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TripMapWidget extends StatefulWidget {
  final Map<String, dynamic> trip;
  final int index;
  final bool isSelectMode;
  final List<int> selectedMapIndices; // Accept the list
  final Function(int) onSelectTrip;
  final VoidCallback onDeleteButtonPressed;

  const TripMapWidget({
    super.key,
    required this.trip,
    required this.index,
    required this.isSelectMode,
    required this.selectedMapIndices, // Pass the selectedMapIndices
    required this.onSelectTrip, 
    required this.onDeleteButtonPressed,
  });

  @override
  State<TripMapWidget> createState() => _TripMapWidgetState();
}

class _TripMapWidgetState extends State<TripMapWidget> {
  late MapController mapController;
  List<LatLng> routePoints = [];
  List<LatLng> locations = [];
  LatLng? startPoint;
  LatLng? endPoint;
  bool isLoading = true;
  final logger = Logger();
  bool _isSelected = false; 

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    _initializeRoutePoints();
    _getLocations().then((_) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    });
    logger.i(widget.isSelectMode);
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  void _initializeRoutePoints() {
    if (widget.trip['trip_coordinates'] != null) {
      setState(() {
        routePoints =
            List<Map<String, dynamic>>.from(widget.trip['trip_coordinates'])
                .map((coord) {
                  if (coord['latitude'] is double &&
                      coord['longitude'] is double) {
                    return LatLng(coord['latitude'], coord['longitude']);
                  } else {
                    logger.e('Invalid coordinate data: $coord');
                    return null;
                  }
                })
                .where((latLng) => latLng != null)
                .cast<LatLng>()
                .toList();
      });
    }
  }

  Future<LatLng?> _getCoordinates(String address) async {
    try {
      final url = Uri.parse(
          'https://api.mapbox.com/geocoding/v5/mapbox.places/${Uri.encodeComponent(address)}.json?access_token=pk.eyJ1Ijoicm9sbGExIiwiYSI6ImNseGppNHN5eDF3eHoyam9oN2QyeW5mZncifQ.iLIVq7aRpvMf6J3NmQTNAw');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['features'] != null && data['features'].isNotEmpty) {
          final coordinates = data['features'][0]['center'];
          return LatLng(coordinates[1], coordinates[0]); 
        }
      }
      return null;
    } catch (e) {
      logger.e('Error getting coordinates: $e');
      return null;
    }
  }

  Future<void> _getLocations() async {
    List<LatLng> tempLocations = [];

    try {
      final startCoordinates =
          await _getCoordinates(widget.trip['start_address']);
      if (startCoordinates != null) {
        startPoint = startCoordinates;
      }
    } catch (e) {
      logger.e('Failed to fetch start address coordinates: $e');
    }

    if (widget.trip['stop_locations'] != null) {
      try {
        final stopLocations =
            List<Map<String, dynamic>>.from(widget.trip['stop_locations']);
        for (var location in stopLocations) {
          final latitude = double.parse(location['latitude'].toString());
          final longitude = double.parse(location['longitude'].toString());
          tempLocations.add(LatLng(latitude, longitude));
        }
      } catch (e) {
        logger.e('Failed to process stop locations: $e');
      }
    }

    try {
      final destinationCoordinates =
          await _getCoordinates(widget.trip['destination_address']);
      if (destinationCoordinates != null) {
        endPoint = destinationCoordinates;
      }
    } catch (e) {
      logger.e('Failed to fetch destination address coordinates: $e');
    }

    setState(() {
      locations = tempLocations;
    });
  }

  // Function to toggle selection mode
  // void _toggleSelectMode() {
  //   setState(() {
  //     _isSelectMode = !_isSelectMode; // Toggle the select mode
  //   });
  //   logger.i('Select mode is now: $_isSelectMode');
  // }

  // Function to toggle individual selection
  void _onSelectTrip() {
    setState(() {
      _isSelected = !_isSelected; // Toggle the selection state
      if (_isSelected) {
        widget.onSelectTrip(widget.trip['id']); // Add the trip ID to the list if selected
      } else {
        widget.onSelectTrip(widget.trip['id']); // Remove the trip ID from the list if deselected
      }
    });
  }

  void _onMapTap() {
    GlobalVariables.homeTripID = widget.trip['id'];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Opacity(
                  opacity: widget.isSelectMode ? 0.5 : 1.0, // Grey out effect
                  child: FlutterMap(
                    mapController: mapController,
                    options: MapOptions(
                      initialCenter:
                          startPoint != null ? startPoint! : const LatLng(0, 0),
                      initialZoom: 3,
                      onTap: (_, LatLng position) {
                        if (widget.isSelectMode == false) {
                            _onMapTap(); // Only call _onMapTap when select mode is true
                          }
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
                      MarkerLayer(
                        markers: [
                          if (startPoint != null)
                            Marker(
                              width: 80,
                              height: 80,
                              point: startPoint!,
                              child: Icon(Icons.location_on,
                                  color: Colors.red, size: 60.sp),
                            ),
                          if (endPoint != null)
                            Marker(
                              width: 80.0,
                              height: 80.0,
                              point: endPoint!,
                              child: Icon(Icons.location_on,
                                  color: Colors.green, size: 60.sp),
                            ),
                          ...locations.map((location) {
                            return Marker(
                              width: 20.0,
                              height: 20.0,
                              point: location,
                              child: Container(
                                width: 12, 
                                height: 12, 
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  border: Border.all(
                                    color: kColorBlack,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.3),
                                      spreadRadius: 0.5,
                                      blurRadius: 6,
                                      offset: const Offset(-3, 5),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    '${locations.indexOf(location) + 1}',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                      // Polyline layer for the route
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: routePoints,
                            strokeWidth: 4.0,
                            color: Colors.blue,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                widget.isSelectMode ?
                  Positioned(
                    right: 10,
                    bottom: 10,
                    child: GestureDetector(
                      onTap: _onSelectTrip,
                      child: Container(
                        width: 25,
                        height: 25,
                        decoration: BoxDecoration(
                          color: _isSelected ? Colors.black : Colors.white,
                          border: Border.all(color: Colors.black),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: _isSelected
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 24,
                                )
                              : null,
                        ),
                      ),
                    ),
                  ) : const SizedBox.square(),
              ],
            ),
    );
  }
}
