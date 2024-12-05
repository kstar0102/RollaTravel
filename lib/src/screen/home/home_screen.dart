import 'package:RollaTravel/src/screen/home/home_tag_screen.dart';
import 'package:RollaTravel/src/screen/home/home_user_screen.dart';
import 'package:RollaTravel/src/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:RollaTravel/src/constants/app_styles.dart';
import 'package:RollaTravel/src/utils/index.dart';
import 'package:RollaTravel/src/widget/bottombar.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:permission_handler/permission_handler.dart';
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
  List<Map<String, dynamic>>? trips;
  final apiService = ApiService();
  final logger = Logger();
  

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
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    try {
      final data = await apiService.fetchAllTrips();
      setState(() {
        trips = data;
      });
    } catch (error) {
      logger.i('Error fetching trips: $error');
      setState(() {
        trips = [];
      });
    }
  }

  // Future<void> _getCurrentLocation() async {
  //   final permissionStatus = await Permission.location.request();

  //   if (permissionStatus.isGranted) {
  //     Position position = await Geolocator.getCurrentPosition(
  //       locationSettings: const LocationSettings(
  //         accuracy: LocationAccuracy.high,
  //       ),
  //     );

  //     setState(() {
  //       _currentLocation = LatLng(position.latitude, position.longitude);
  //       logger.i("$_currentLocation");
  //     });
  //   } else {
  //     logger.i("Location permission denied");
  //   }
  // }

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
              
              trips == null
                ? const Center(child: CircularProgressIndicator()) // Show loading indicator
                : trips!.isEmpty
                    ? const Center(child: Text('No trips available')) // Show message if no trips
                    : Expanded(
                        child: ListView.builder(
                          itemCount: trips!.length,
                          itemBuilder: (context, index) {
                            final trip = trips![index];
                            return PostWidget(
                              post: trip,       // Pass trip data to PostWidget
                              dropIndex: index, // Current index
                            );
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
  final Map<String, dynamic> post;
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
  List<String>? stopAddresses;
  List<LatLng> locations = [];
  LatLng? startPoint;
  LatLng? endPoint;
  // bool isLiked = true;
  @override
  void initState() {
    super.initState();
    mapController = MapController();
    _getlocaionts();
    // Use addPostFrameCallback to delay interaction with mapController until after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (locations.length > 1) {
        mapController.move(locations[0], 15.0);
      }
    });
    
  }

   
  Future<void> _getlocaionts() async{
    try {
      final startCoordinates = await getCoordinates(widget.post['start_address']);
      startPoint = LatLng(startCoordinates['latitude']!, startCoordinates['longitude']!);
      locations.add(startPoint!);
    } catch (e) {
      logger.e('Failed to fetch start address coordinates: $e');
    }

    if(widget.post['stop_address'] != null){
      stopAddresses = List<String>.from(jsonDecode(widget.post['stop_address']));
    
      for (String address in stopAddresses!) {
        try {
          final coordinates = await getCoordinates(address);
          locations.add(LatLng(coordinates['latitude']!, coordinates['longitude']!));
        } catch (e) {
          logger.e('Failed to fetch coordinates for $address: $e');
        }
      }
    }

    // Fetch Destination Address
    try {
      final destinationCoordinates = await getCoordinates(widget.post['destination_address']);
      endPoint = LatLng(destinationCoordinates['latitude']!, destinationCoordinates['longitude']!);
      locations.add(endPoint!);
    } catch (e) {
      logger.e('Failed to fetch destination address coordinates: $e');
    }
    
    _fetchDrivingRoute(locations);
  }
  
  Future<Map<String, double>> getCoordinates(String address) async {
    String accessToken = 'pk.eyJ1Ijoicm9sbGExIiwiYSI6ImNseGppNHN5eDF3eHoyam9oN2QyeW5mZncifQ.iLIVq7aRpvMf6J3NmQTNAw';
    final url = Uri.parse(
      'https://api.mapbox.com/geocoding/v5/mapbox.places/${Uri.encodeComponent(address)}.json?access_token=$accessToken',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final coordinates = data['features'][0]['geometry']['coordinates'];
      return {'longitude': coordinates[0], 'latitude': coordinates[1]};
    } else {
      throw Exception('Failed to fetch coordinates');
    }
  }

  Future<void> _fetchDrivingRoute(List<LatLng> locations) async {
    
    if (locations.length < 2) return; // Ensure at least two points for a route

    // Set start, end, and waypoints for Mapbox API
    final start = locations.first;
    final end = locations.last;
     final waypoints = locations.length > 2
      ? locations.sublist(1, locations.length - 1)
          .map((loc) => '${loc.longitude},${loc.latitude}')
          .join(';')
      : '';
    final coordinates = '${start.longitude},${start.latitude};$waypoints;${end.longitude},${end.latitude}';
    final url = 'https://api.mapbox.com/directions/v5/mapbox/driving/$coordinates?geometries=polyline&access_token=pk.eyJ1Ijoicm9sbGExIiwiYSI6ImNseGppNHN5eDF3eHoyam9oN2QyeW5mZncifQ.iLIVq7aRpvMf6J3NmQTNAw';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final polyline = data['routes'][0]['geometry'];
        if (mounted) {
          setState(() {
            routePoints = _decodePolyline(polyline);
          });
        }
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

  // void _showImageDialog(String imagePath, String caption, int likes) {
  void _showImageDialog(String imagePath, String caption, int likes, List<dynamic> likedUsers) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Dialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 30),
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
                            fontFamily: 'Kadaw',
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.black),
                          onPressed: () {
                            Navigator.of(context).pop();
                            setState(() {
                              showLikesDropdown = false; // Hide the dropdown when the dialog is closed
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  // Image
                  Image.network(
                    imagePath,
                    fit: BoxFit.cover,
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: MediaQuery.of(context).size.height * 0.5,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.broken_image, size: 100),
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
                              fontFamily: 'Kadaw',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (showLikesDropdown)
                    Column(
                      children: likedUsers.map((user) {
                        final photo = user['photo'] ?? '';
                        final firstName = user['first_name'] ?? 'Unknown';
                        final lastName = user['last_name'] ?? '';
                        final username = user['rolla_username'] ?? '@unknown';

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              // User Profile Picture
                              Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  border: Border.all(
                                    color: Colors.grey,
                                    width: 2,
                                  ),
                                  image: photo.isNotEmpty
                                      ? DecorationImage(
                                          image: NetworkImage(photo),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: photo.isEmpty
                                    ? const Icon(Icons.person, size: 20) // Placeholder icon
                                    : null,
                              ),
                              const SizedBox(width: 5),
                              // User Information
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$firstName $lastName',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      fontFamily: 'Kadaw',
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    username,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                      fontFamily: 'Kadaw',
                                    ),
                                  ),
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
                  image: widget.post['user']['photo'] != null
                    ? DecorationImage(
                        image: NetworkImage(widget.post['user']['photo']),
                        fit: BoxFit.cover,
                        onError: (exception, stackTrace) {
                          // Handle image loading errors
                        },
                      )
                    : null,
                ),
              ),
            ),  
            const SizedBox(width: 10),
            Text(widget.post['user']['rolla_username'], style: const TextStyle(fontSize: 18, fontFamily: 'KadawBold')),
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
                SizedBox(
                  width: 250, // Set your desired width
                  child: Text(
                    widget.post['destination_address'],
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.brown,
                      decoration: TextDecoration.underline,
                      fontFamily: 'Kadaw',
                    ),
                    maxLines: 1, // Limit to one line
                    overflow: TextOverflow.ellipsis, // Add ellipsis if text overflows
                  ),
                ),
                const SizedBox(height: 3),
                Text('${widget.post['trip_miles']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Kadaw')),
                const SizedBox(height: 3),
                const Text("Spotify Playlist", style: TextStyle(fontSize: 16, color: Colors.brown, decoration: TextDecoration.underline, fontFamily: 'Kadaw')),
              ],
            ),
          ],
        ),
        SizedBox(height: vhh(context, 2)),
        // Trip Details Circles
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: List.generate(widget.post['droppins'].length, (index) => 
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
                  _showImageDialog(
                    widget.post['droppins'][index]['image_path'], 
                    widget.post['droppins'][index]['image_caption'], 
                    widget.post['droppins'][index]['liked_users'].length, 
                    widget.post['droppins'][index]['liked_users']);
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
              locations.isNotEmpty
              ? FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    initialCenter: locations[0], // Use the first location
                    initialZoom: 15.0,
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
                      markers: locations.asMap().entries.map((entry) {
                        int index = entry.key;
                        LatLng location = entry.value;

                        // Define marker styles
                        Widget markerIcon;
                        if (index == 0) {
                          // Start location
                          markerIcon = SizedBox(
                            width: 20,
                            height: 20,
                            child: Image.asset(
                              'assets/images/icons/start_icon.png',
                              fit: BoxFit.contain, // Ensure the image fits within the specified size
                            ),
                          );
                        } else if (index == locations.length - 1) {
                          // Destination location
                          markerIcon = SizedBox(
                            width: 20,
                            height: 20,
                            child: Image.asset(
                              'assets/images/icons/des_icon.png',
                              fit: BoxFit.contain, // Ensure the image fits within the specified size
                            ),
                          );
                        } else {
                          // Waypoints
                          markerIcon = const Icon(Icons.location_on, color: Colors.blue, size: 40);
                        }

                        return Marker(
                          width: 35.0,
                          height: 35.0,
                          point: location,
                          child: GestureDetector(
                            onTap: () {
                              // Handle tap logic if needed
                              if (index > 0 && index < locations.length - 1) {
                                final droppin = widget.post['droppins'][index - 1];
                                _showImageDialog(
                                  droppin['image_path'],
                                  droppin['image_caption'],
                                  droppin['liked_users'].length,
                                  droppin['liked_users'],
                                );
                              }
                              // logger.i(
                              //     'Marker tapped at: ${location.latitude}, ${location.longitude}');
                            },
                            child: markerIcon,
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
                )
              : const Center(
                  child: CircularProgressIndicator(), // Show a loading indicator while waiting for data
                ),
              // Zoom controls
              Positioned(
                right: 10,
                top: 10,
                child: Column(
                  children: [
                    FloatingActionButton(
                      heroTag: 'zoom_in_button_homescreen_1',
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
                      heroTag: 'zoom_out_button_homescreen_2',
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
                    // _showImageDialog(widget.post.locationImages[widget.dropIndex], widget.post.locationDecription[widget.dropIndex], widget.dropIndex);
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
                Text(widget.post['user']['rolla_username'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15,fontFamily: 'Kadaw',)),
                const SizedBox(width: 15),
                Text(
                  widget.post['trip_caption'] ?? " ",
                  style: const TextStyle(color: kColorButtonPrimary, fontSize: 15,fontFamily: 'Kadaw',)),
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
                  '${widget.post["comments"].length} comments',
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
                children: widget.post['comments'].map<Widget>((comment) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        // User photo or placeholder
                        Container(
                          height: vhh(context, 3),
                          width: vhh(context, 3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: kColorHereButton,
                              width: 2,
                            ),
                            image: comment['user']['photo'] != null
                                ? DecorationImage(
                                    image: NetworkImage(comment['user']['photo']),
                                    fit: BoxFit.cover,
                                  )
                                :null,
                          ),
                        ),
                        const SizedBox(width: 5),
                        // Username
                        Text(
                          comment['user']['rolla_username'] ?? 'Unknown User',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: kColorHereButton,
                            fontSize: 13,
                            fontFamily: 'Kadaw',
                          ),
                        ),
                        const SizedBox(width: 5),
                        // Verified icon (optional)
                        if (comment['user']['rolla_username'] != null) // Add condition if needed
                          const Icon(Icons.verified, color: Colors.blue, size: 16),
                        const SizedBox(width: 8),
                        // Comment content
                        Expanded(
                          child: Text(
                            comment['content'] ?? '',
                            style: const TextStyle(
                              fontFamily: 'Kadaw',
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            const SizedBox(height: 8),
            // Text(widget.post.lastUpdated, style: const TextStyle(color: Colors.grey, fontSize: 12, fontFamily: 'Kadaw')),
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
