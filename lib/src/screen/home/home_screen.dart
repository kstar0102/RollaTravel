import 'package:RollaTravel/src/screen/home/home_tag_screen.dart';
import 'package:RollaTravel/src/screen/home/home_user_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:RollaTravel/src/constants/app_styles.dart';
import 'package:RollaTravel/src/utils/index.dart';
import 'package:RollaTravel/src/widget/bottombar.dart';
import 'package:RollaTravel/src/utils/home_post.dart';
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
      commentsList: [
        {"user": "@User1", "comment": "Great place!"},
        {"user": "@User2", "comment": "Looks amazing!"},
        {"user": "@User3", "comment": "I want to visit!"},
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
      commentsList: [
        {"user": "@User13", "comment": "Example 1 Great place!"},
        {"user": "@User23", "comment": "Example 2 Looks amazing!"},
        {"user": "@User13", "comment": "Example 3 I want to visit!"},
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
                    return PostWidget( post: post, dropIndex: index,);
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
  final int dropIndex;
  const PostWidget({super.key, required this.post, required this.dropIndex});

  @override
  PostWidgetState createState() => PostWidgetState();

}

class PostWidgetState extends State<PostWidget> {
  late MapController mapController;
  List<LatLng> routePoints = [];
  bool showComments = false;
  bool isAddComments = false;
  bool isLiked = false;
  bool showLikesDropdown = false;
  final TextEditingController _addCommitController = TextEditingController();
  // bool isLiked = true;
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
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
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
                          style: iamgeModalCaptionTextStyle,
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.black),
                          onPressed: () {
                            Navigator.of(context).pop();
                            setState(() {
                              showLikesDropdown = false; // Hide the likes dropdown when the dialog is closed
                            });
                          }
                        ),
                      ],
                    ),
                  ),
                  // Image
                  Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    width: MediaQuery.of(context).size.width * 0.9, // Replace vww
                    height: MediaQuery.of(context).size.height * 0.5, // Replace vhh
                  ),
                  const Divider(height: 1, color: Colors.grey), // Divider between image and footer
                  // Footer with Like Icon and Likes Count
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            // Update dialog state
                            setState(() {
                              isLiked = !isLiked;
                            });
                          },
                          child: Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            color: isLiked ? Colors.red : Colors.black,
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              showLikesDropdown = !showLikesDropdown; // Toggle the visibility of the dropdown
                            });
                          },
                          child: Text(
                            '$likes likes',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              fontFamily: 'Kadaw'
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (showLikesDropdown)
                    Column(
                      children: widget.post.commentsList.map((comment) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              Container(
                                height: vhh(context, 4),
                                width: vhh(context, 4),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  border: Border.all(
                                    color: kColorHereButton,
                                    width: 2,
                                  ),
                                  image: const DecorationImage(
                                    image: AssetImage("assets/images/background/image1.png"),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 5),
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        comment['user']!,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold, 
                                          color: kColorHereButton,
                                          fontSize: 13,
                                          fontFamily: 'Kadaw'
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      const Icon(Icons.verified, color: Colors.blue, size: 16),
                                    ],
                                  ),
                                  const Text("Brain Smith", style: TextStyle(fontFamily: 'Kadaw'),)
                                ],
                              ),
                              
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _goTagScreen(){
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HomeTagScreen()),
    );
  }

  void _goUserScreen(){
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HomeUserScreen()),
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
            GestureDetector(
              onTap: () {
                _goUserScreen();
              },
              child: Container(
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
            ),  
            const SizedBox(width: 10),
            Text(widget.post.username, style: const TextStyle(fontSize: 18, fontFamily: 'KadawBold')),
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
                Text('Destination', style: TextStyle(fontSize: 15, fontFamily: 'KadawBold')),
                SizedBox(height: 3),
                Text('Miles traveled', style: TextStyle(fontSize: 15, fontFamily: 'KadawBold')),
                SizedBox(height: 3),
                Text('Soundtrack', style: TextStyle(fontSize: 15, fontFamily: 'KadawBold')),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(widget.post.destination, style: const TextStyle(fontSize: 16, color: Colors.brown, decoration: TextDecoration.underline, fontFamily: 'Kadaw')),
                const SizedBox(height: 3),
                Text('${widget.post.milesTraveled}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Kadaw')),
                const SizedBox(height: 3),
                Text(widget.post.soundtrack, style: const TextStyle(fontSize: 16, color: Colors.brown, decoration: TextDecoration.underline, fontFamily: 'Kadaw')),
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
              child: GestureDetector(
                onTap: () {
                  _showImageDialog(widget.post.locationImages[index], widget.post.locationDecription[index], index);
                },
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
                      heroTag: 'zoom_in_button_homescreen',
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
                      heroTag: 'zoom_out_button_homescreen',
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
        const SizedBox(height: 5,),
        if(isAddComments)
          TextField(
            controller: _addCommitController,
            decoration: const InputDecoration(
              hintText: 'add a comment',
              hintStyle: TextStyle(
                color: Colors.grey,
                fontSize: 15,
                fontFamily: 'Kadaw'
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0)), // Optional: Add border radius for rounded corners
                borderSide: BorderSide(
                  color: Colors.grey, // Set the border color
                  width: 1.0, // Set the border width
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0)), // Optional: Add border radius for rounded corners
                borderSide: BorderSide(
                  color: Colors.grey, // Set the border color
                  width: 1.0, // Set the border width
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0)), // Optional: Add border radius for rounded corners
                borderSide: BorderSide(
                  color: Colors.grey, // Set the border color when focused
                  width: 1.0, // Set the border width when focused
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 8.0, // Adjust horizontal padding
                vertical: 5.0, // Adjust vertical padding
              ),
            ),
            style: const TextStyle(
              fontFamily: 'Kadaw', // Set your custom font family here
              fontSize: 15,        // Optional: Adjust font size
              color: Colors.black, // Optional: Adjust text color
            ),
          ),
        const SizedBox(height: 10),
        // Likes and Comments Section
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: (){
                    _showImageDialog(widget.post.locationImages[widget.dropIndex], widget.post.locationDecription[widget.dropIndex], widget.dropIndex);
                    setState(() {
                      showLikesDropdown = true;
                    });
                  },
                  child: const Text(
                  '# likes', 
                  style: TextStyle(
                    fontWeight: FontWeight.bold, 
                    color: Colors.grey, 
                    fontSize: 16,
                    fontFamily: 'Kadaw',)
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isAddComments = !isAddComments; // Toggle the visibility of comments
                    });
                  },
                  child: Image.asset("assets/images/icons/messageicon.png", width: vww(context, 5)),
                ),
                const SizedBox(width: 15),
                GestureDetector(
                  onTap: () {
                    _goTagScreen();
                  },
                  child: Image.asset("assets/images/icons/add_car.png", width: vww(context, 9)),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.post.username, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15,fontFamily: 'Kadaw',)),
                const SizedBox(width: 15),
                Text(widget.post.caption, style: const TextStyle(color: kColorButtonPrimary, fontSize: 15,fontFamily: 'Kadaw',)),
              ],
            ),
            const SizedBox(height: 10),
            Center(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    showComments = !showComments; // Toggle the visibility of comments
                  });
                },
                child: Text(
                  '${widget.post.comments} comments',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    fontFamily: 'Kadaw',
                  ),
                ),
              ),
            ),
            if (showComments)
              Column(
                children: widget.post.commentsList.map((comment) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        Container(
                          height: vhh(context, 3),
                          width: vhh(context, 3),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              color: kColorHereButton,
                              width: 2,
                            ),
                            image: const DecorationImage(
                              image: AssetImage("assets/images/background/image1.png"),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          comment['user']!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold, 
                            color: kColorHereButton,
                            fontSize: 13,
                            fontFamily: 'Kadaw',
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Icon(Icons.verified, color: Colors.blue, size: 16),
                        const SizedBox(width: 8),
                        Text(comment['comment']!, style: const TextStyle(fontFamily: 'Kadaw', fontSize: 14),),
                      ],
                    ),
                  );
                }).toList(),
              ),
            const SizedBox(height: 8),
            Text(widget.post.lastUpdated, style: const TextStyle(color: Colors.grey, fontSize: 12, fontFamily: 'Kadaw')),
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
