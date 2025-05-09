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

  const TripMapWidget({
    super.key,
    required this.trip,
    required this.index,
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
  // bool _isSelected = false; 
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
                FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    initialCenter:
                        startPoint != null ? startPoint! : const LatLng(0, 0),
                    initialZoom: 3,
                    onTap: (_, LatLng position) {
                      _onMapTap();
                      logger.i('Map tapped at: $position');
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
                              width: 12, // Smaller width
                              height: 12, // Smaller height
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                border: Border.all(
                                  color: kColorBlack, // Border color
                                  width: 2, // Border width
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
                                  '${locations.indexOf(location) + 1}', // Display index + 1 inside the circle
                                  style: const TextStyle(
                                    color: Colors
                                        .black, // Text color to match border
                                    fontSize: 13, // Smaller font size
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
                // ... Zoom controls
              ],
            ),
    );
  }

  
}
