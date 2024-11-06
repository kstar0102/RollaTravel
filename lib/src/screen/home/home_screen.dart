import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:RollaStrava/src/constants/app_styles.dart';
import 'package:RollaStrava/src/utils/index.dart';
import 'package:RollaStrava/src/widget/bottombar.dart';
import 'package:RollaStrava/src/utils/home_post.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final logger = Logger();

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends ConsumerState<HomeScreen> {
  double screenHeight = 0;
  double keyboardHeight = 0;
  final int _currentIndex = 0;
  LatLng? _currentLocation;
  final logger = Logger();

  // Sample data for posts
  final List<Post> posts = [
    Post(
      username: "@smith",
      destination: "Lake Placid, NY",
      milesTraveled: 247,
      soundtrack: "Spotify Playlist",
      caption: "Adventure bound..",
      comments: 3,
      lastUpdated: "last updated 3 hrs ago",
      imagePath: "assets/images/background/image2.png",
      locations: [
        const LatLng(44.2937, -73.9916),
        const LatLng(44.3040, -73.9875),
        const LatLng(44.3080, -73.9780),
      ],
      locationImages: [
        "assets/images/background/Lake1.png",
        "assets/images/background/Lake2.png",
        "assets/images/background/Lake3.png",
      ],
      locationDecription: [
        "Lake Placid, NY 1",
        "Lake Placid, NY 2",
        "Lake Placid, NY 3",
      ],
    ),
    Post(
      username: "@john",
      destination: "Yellowstone, WY",
      milesTraveled: 352,
      soundtrack: "Road Trip Vibes",
      caption: "Nature is calling!",
      comments: 5,
      lastUpdated: "last updated 2 hrs ago",
      imagePath: "assets/images/background/image3.png",
      locations: [
        const LatLng(44.4279, -110.5885),
        const LatLng(44.4568, -110.5786),
        const LatLng(44.4622, -110.5884),
      ],
      locationImages: [
        "assets/images/background/yellowstone1.png",
        "assets/images/background/yellowstone2.png",
        "assets/images/background/yellowstone3.png",
      ],
      locationDecription: [
        "Yellowstone, WY 1",
        "Yellowstone, WY 2",
        "Yellowstone, WY 3",
      ],
    ),
    // Add more posts as needed
  ];

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

      // Wait until the first frame is rendered before moving the map
      // WidgetsBinding.instance.addPostFrameCallback((_) {
      //   if (posts[1].locations.isNotEmpty) {
      //     _mapController.move(posts[1].locations[2], 15.0);
      //   }
      // });
    } else {
      // Handle the case when location permission is denied.
      logger.i("Location permission denied");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: () async => false,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: vhh(context, 3)),
              // Header Section
              Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Image.asset(
                      'assets/images/icons/logo.png',
                      width: vww(context, 20),
                    ),
                  ),
                  Image.asset("assets/images/icons/notification.png", width: vww(context, 4)),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Divider(),
              ),
              // Make the posts scrollable
              Expanded(
                child: ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return PostWidget( post: post,);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: _currentIndex),
    );
  }
}

class PostWidget extends StatefulWidget {
  final Post post;

  const PostWidget({super.key, required this.post,});

  @override
  PostWidgetState createState() => PostWidgetState();

}

class PostWidgetState extends State<PostWidget> {
  late MapController mapController;
   List<LatLng> routePoints = [];

  @override
  void initState() {
    super.initState();
    mapController = MapController();

    // Use addPostFrameCallback to delay interaction with mapController until after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.post.locations.length > 1) {
        mapController.move(widget.post.locations[0], 15.0);
        _fetchDrivingRoute(widget.post.locations);
      }
    });
  }

  Future<void> _fetchDrivingRoute(List<LatLng> locations) async {
    if (locations.length < 2) return; // Ensure at least two points for a route

    // Set start, end, and waypoints for Mapbox API
    final start = locations.first;
    final end = locations.last;
    final waypoints = locations.sublist(1, locations.length - 1)
        .map((loc) => '${loc.longitude},${loc.latitude}')
        .join(';');
    final coordinates = '${start.longitude},${start.latitude};$waypoints;${end.longitude},${end.latitude}';
    final url = 'https://api.mapbox.com/directions/v5/mapbox/driving/$coordinates?geometries=polyline&access_token=pk.eyJ1Ijoicm9sbGExIiwiYSI6ImNseGppNHN5eDF3eHoyam9oN2QyeW5mZncifQ.iLIVq7aRpvMf6J3NmQTNAw';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final polyline = data['routes'][0]['geometry'];

        // Decode the polyline to get LatLng points
        setState(() {
          routePoints = _decodePolyline(polyline);
        });
      } else {
        logger.i('Failed to fetch route: ${response.statusCode}');
      }
    } catch (e) {
      logger.i('Error fetching route: $e');
    }
  }

  // Polyline decoder function for Mapbox-encoded polylines
  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int shift = 0, result = 0;
      int b;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  void _showImageDialog(String imagePath, String caption, int likes) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 30), // Adjust padding to match the screenshot
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Caption and Close Icon Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      caption,
                      style: const TextStyle(
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
              Image.asset(imagePath, fit: BoxFit.cover, width: vww(context, 90), height: vhh(context, 70),),
              const Divider(height: 1, color: Colors.grey), // Divider between image and footer
              // Footer with Like Icon and Likes Count
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Icon(Icons.favorite_border, color: Colors.black),
                    SizedBox(width: 4),
                    Text(
                      '# likes',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Profile Section
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: vhh(context, 7),
              width: vhh(context, 7),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: kColorHereButton,
                  width: 2,
                ),
                image: DecorationImage(
                  image: AssetImage(widget.post.imagePath),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(widget.post.username, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(width: 10),
            const Icon(Icons.verified, color: Colors.blue, size: 16),
            const Spacer(),
            Image.asset("assets/images/icons/reference.png"),
          ],
        ),
        SizedBox(height: vhh(context, 2)),
        // Trip Details
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Destination', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 3),
                Text('Miles traveled', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 3),
                Text('Soundtrack', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(widget.post.destination, style: const TextStyle(fontSize: 16, color: Colors.brown, decoration: TextDecoration.underline)),
                const SizedBox(height: 3),
                Text('${widget.post.milesTraveled}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 3),
                Text(widget.post.soundtrack, style: const TextStyle(fontSize: 16, color: Colors.brown, decoration: TextDecoration.underline)),
              ],
            ),
          ],
        ),
        SizedBox(height: vhh(context, 2)),
        // Trip Details Circles
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: List.generate(3, (index) => 
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: index >= 3 ? Colors.red : Colors.black,
                  width: 1,
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: index >= 3 ? Colors.blue : Colors.black,
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 10,
                  backgroundColor: Colors.white,
                  child: Text('${index + 1}', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Map Section
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Stack(
            children: [
              // The map
              FlutterMap(
                mapController: mapController,
                options: MapOptions(
                  initialCenter: widget.post.locations[1],
                  initialZoom: 15.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        "https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/{z}/{x}/{y}?access_token=pk.eyJ1Ijoicm9sbGExIiwiYSI6ImNseGppNHN5eDF3eHoyam9oN2QyeW5mZncifQ.iLIVq7aRpvMf6J3NmQTNAw",
                    additionalOptions: const {
                      'access_token': 'pk.eyJ1Ijoicm9sbGExIiwiYSI6ImNseGppNHN5eDF3eHoyam9oN2QyeW5mZncifQ.iLIVq7aRpvMf6J3NmQTNAw',
                    },
                  ),
                  MarkerLayer(
                    markers: widget.post.locations.asMap().entries.map((entry) {
                      int index = entry.key;
                      LatLng location = entry.value;
                      return Marker(
                        width: 60.0,
                        height: 60.0,
                        point: location,
                        child: GestureDetector(
                          onTap: () => _showImageDialog(widget.post.locationImages[index], widget.post.locationDecription[index], index), // Show image dialog on tap
                          child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                        ),
                      );
                    }).toList(),
                  ),

                  // Polyline layer for the route
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: routePoints, // Points defining the route
                        strokeWidth: 4.0,
                        color: Colors.blue, // Customize the color as needed
                      ),
                    ],
                  ), 
                ],
              ),
              // Zoom controls
              Positioned(
                right: 10,
                top: 10,
                child: Column(
                  children: [
                    FloatingActionButton(
                      onPressed: () {
                        mapController.move(
                          mapController.camera.center,
                          mapController.camera.zoom + 1,
                        );
                      },
                      mini: true,
                      child: const Icon(Icons.zoom_in),
                    ),
                    const SizedBox(height: 8),
                    FloatingActionButton(
                      onPressed: () {
                        mapController.move(
                          mapController.camera.center,
                          mapController.camera.zoom - 1,
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

        const SizedBox(height: 10),
        // Likes and Comments Section
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('# likes', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 16)),
                const Spacer(),
                Image.asset("assets/images/icons/messageicon.png", width: vww(context, 5)),
                const SizedBox(width: 15),
                Image.asset("assets/images/icons/add_car.png", width: vww(context, 9)),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.post.username, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(width: 15),
                Text(widget.post.caption, style: const TextStyle(color: kColorButtonPrimary, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 10),
            Center(child: Text('${widget.post.comments} comments', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
            const SizedBox(height: 8),
            Text(widget.post.lastUpdated, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 20),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Divider(),
        ),
      ],
    );
  }
}
