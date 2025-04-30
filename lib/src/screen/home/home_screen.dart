import 'package:RollaTravel/src/screen/home/home_tag_screen.dart';
import 'package:RollaTravel/src/screen/home/home_user_screen.dart';
import 'package:RollaTravel/src/screen/home/home_view_screen.dart';
import 'package:RollaTravel/src/services/api_service.dart';
import 'package:RollaTravel/src/utils/global_variable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:RollaTravel/src/constants/app_styles.dart';
import 'package:RollaTravel/src/utils/index.dart';
import 'package:RollaTravel/src/widget/bottombar.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:timeago/timeago.dart' as timeago;

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
  final ScrollController _scrollController =
      ScrollController(); // Add ScrollController

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
      logger.i(trips);

      // Scroll to the correct index if homeTripID is set
      if (GlobalVariables.homeTripID != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToTrip(GlobalVariables.homeTripID!);
        });
      }
    } catch (error) {
      logger.i('Error fetching trips: $error');
      setState(() {
        trips = [];
      });
    }
  }

  void _scrollToTrip(int tripId) {
    if (trips != null) {
      int index = trips!.indexWhere((trip) => trip['id'] == tripId);
      if (index != -1) {
        _scrollController.animateTo(
          index * 520.0, // Approximate height per item, adjust as needed
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );

        // Reset GlobalVariables.homeTripID to null after focusing
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {
            GlobalVariables.homeTripID = null;
          });
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if homeTripID is set and filter the trips accordingly
    final isSpecificTrip = GlobalVariables.homeTripID != null;
    final filteredTrips = trips != null && isSpecificTrip
        ? trips!
            .where((trip) => trip['id'] == GlobalVariables.homeTripID)
            .toList()
        : trips;

    // Once filtered and displayed, reset the homeTripID
    if (isSpecificTrip && filteredTrips != null && filteredTrips.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          GlobalVariables.homeTripID = null;
        });
      });
    }
    return Scaffold(
      backgroundColor: kColorWhite,
      // ignore: deprecated_member_use
      body: WillPopScope(
        onWillPop: () async => false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
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
                  Image.asset("assets/images/icons/notification.png",
                      width: vww(context, 4)),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
                child: Divider(),
              ),

              trips == null
                  ? const Center(
                      child:
                          CircularProgressIndicator()) // Show loading indicator
                  : trips!.isEmpty
                      ? const Center(
                          child: Text(
                              'No trips available')) // Show message if no trips
                      : Expanded(
                          child: ListView.builder(
                            controller:
                                _scrollController, // Attach ScrollController
                            itemCount: trips!.length,
                            itemBuilder: (context, index) {
                              final trip = trips![index];
                              return PostWidget(
                                post: trip, // Pass trip data
                                dropIndex: index, // Current index
                                onLikesUpdated: (updatedLikes) {
                                  setState(() {
                                    trips![index]['totalLikes'] = updatedLikes;
                                  });
                                },
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
  final Function(int) onLikesUpdated;

  const PostWidget({
    super.key,
    required this.post,
    required this.dropIndex,
    required this.onLikesUpdated,
  });

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
  bool isLoading = true;
  final ApiService apiService = ApiService();
  int likes = 0;

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    _initializeRoutePoints();
    startAndendMark();
    _getlocaionts().then((_) {
      setState(() {
        isLoading = false;
        likes = _calculateTotalLikes(widget.post['droppins']);
      });
    });
  }

  Future<void> startAndendMark() async {
    try {
      if (widget.post['start_location'] != null &&
          widget.post['start_location'].toString().contains("LatLng")) {
        final regex =
            RegExp(r"LatLng\(latitude:([\d\.-]+), longitude:([\d\.-]+)\)");
        final match = regex.firstMatch(widget.post['start_location']);

        if (match != null) {
          final double startlatitude = double.parse(match.group(1)!);
          final double startlongitude = double.parse(match.group(2)!);
          setState(() {
            startPoint = LatLng(startlatitude, startlongitude);
          });
        }
      } else {
        final startCoordinates =
            await getCoordinates(widget.post['start_address']);
        setState(() {
          startPoint = LatLng(
              startCoordinates['latitude']!, startCoordinates['longitude']!);
        });
      }
    } catch (e) {
      logger.e('Failed to fetch start address coordinates: $e');
    }

    try {
      if (widget.post['destination_location'] != null) {
        final locationString = widget.post['destination_location'];
        final regex = RegExp(
            r"LatLng\(\s*latitude:\s*([\d\.-]+),\s*longitude:\s*([\d\.-]+)\s*\)");
        final match = regex.firstMatch(locationString ?? '');
        if (match != null) {
          final double endlatitude = double.parse(match.group(1)!);
          final double endlongitude = double.parse(match.group(2)!);
          setState(() {
            endPoint = LatLng(endlatitude, endlongitude);
          });
        } else {
          logger.i("No match found for destination location.");
        }
      }
    } catch (e) {
      logger.e('Failed to fetch destination address coordinates: $e');
    }
  }

  int _calculateTotalLikes(List<dynamic> droppins) {
    return droppins.fold<int>(
      0,
      (sum, droppin) => sum + (droppin['liked_users'].length as int),
    );
  }

  void _initializeRoutePoints() {
    if (widget.post['trip_coordinates'] != null) {
      setState(() {
        routePoints =
            List<Map<String, dynamic>>.from(widget.post['trip_coordinates'])
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

  Future<void> _getlocaionts() async {
    List<LatLng> tempLocations = [];
    if (widget.post['stop_locations'] != null) {
      try {
        final stopLocations =
            List<Map<String, dynamic>>.from(widget.post['stop_locations']);
        for (var location in stopLocations) {
          final latitude = double.parse(location['latitude'].toString());
          final longitude = double.parse(location['longitude'].toString());
          tempLocations.add(LatLng(latitude, longitude));
        }
      } catch (e) {
        logger.e('Failed to process stop locations: $e');
      }
    }
    setState(() {
      locations = tempLocations;
    });
    _autoZoomMap();
  }

  void _autoZoomMap() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Ensure the map has been rendered before interacting with it
      List<LatLng> allLocations = [startPoint, endPoint].whereType<LatLng>().toList();
      allLocations.addAll(locations);

      if (allLocations.isEmpty) return;

      LatLngBounds bounds = LatLngBounds.fromPoints(allLocations);
      mapController.move(bounds.center, _calculateZoom(bounds));
    });
  }

  double _calculateZoom(LatLngBounds bounds) {
    double latDiff = bounds.northEast.latitude - bounds.southWest.latitude;
    double lonDiff = bounds.northEast.longitude - bounds.southWest.longitude;

    double zoom = 12.0; // Default zoom level
    if (latDiff > lonDiff) {
      zoom -= latDiff * 0.1;
    } else {
      zoom -= lonDiff * 0.1;
    }

    return zoom < 5 ? 5 : zoom > 18 ? 18 : zoom;
  }

  Future<Map<String, double>> getCoordinates(String address) async {
    String accessToken =
        'pk.eyJ1Ijoicm9sbGExIiwiYSI6ImNseGppNHN5eDF3eHoyam9oN2QyeW5mZncifQ.iLIVq7aRpvMf6J3NmQTNAw';
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

  bool hasUserViewed(String? viewlist, int userId) {
    if (viewlist == null || viewlist.trim().isEmpty) {
      return false;
    }

    List<int> viewedIds = viewlist
        .split(',')
        .map((e) => e.trim()) // Remove spaces
        .where((e) => e.isNotEmpty) // Clean up empty entries
        .map(int.parse) // Convert to int
        .toList();

    return viewedIds.contains(userId);
  }

  Future<void> _showImageDialog(
    String imagePath,
    String caption,
    int droppinlikes,
    List<dynamic> likedUsers,
    int droppinId,
    int userId,
    String? viewlist,
    int droppinIndex,
  ) async {
    final apiservice = ApiService();
    if (likedUsers.map((user) => user['id']).contains(GlobalVariables.userId)) {
      isLiked = true;
    } else {
      isLiked = false;
    }

    int? viewcount;
    if (viewlist != null) {
      viewcount = viewlist.split(',').length;
    } else {
      logger.i("viewlist is null");
      viewcount = 0;
    }
    int currentUserId = GlobalVariables.userId!;
    bool viewed = hasUserViewed(viewlist, currentUserId);
    if (viewed == false) {
      final result = await apiservice.markDropinAsViewed(
        userId: GlobalVariables.userId!,
        dropinId: droppinId,
      );
      final status = result['statusCode'];
      if (status == true) {
        setState(() {
          if (widget.post['droppins'][droppinIndex]['view_count'] != null) {
            widget.post['droppins'][droppinIndex]['view_count'] +=
                ',${GlobalVariables.userId}';
            viewlist = '${viewlist ?? ''},${GlobalVariables.userId}';
          } else {
            widget.post['droppins'][droppinIndex]['view_count'] =
                '${GlobalVariables.userId}';
            viewlist = '${GlobalVariables.userId}';
          }

          viewcount = widget.post['droppins'][droppinIndex]['view_count']
              .split(',')
              .length;

          viewed = hasUserViewed(
              widget.post['droppins'][droppinIndex]['view_count'],
              currentUserId);
        });
      }
    }
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Dialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 30),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          caption,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                              fontFamily: 'inter',
                              letterSpacing: -0.1),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.black),
                          onPressed: () {
                            Navigator.of(context).pop();
                            setState(() {
                              showLikesDropdown = false;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.network(
                        imagePath,
                        fit: BoxFit.cover,
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: MediaQuery.of(context).size.height * 0.5,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.broken_image, size: 100),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          } else {
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        (loadingProgress.expectedTotalBytes ??
                                            1)
                                    : null,
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  const Divider(height: 1, color: Colors.grey),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () async {
                            final response = await apiService.toggleDroppinLike(
                              userId: GlobalVariables.userId!,
                              droppinId: droppinId,
                              flag: !isLiked,
                            );
                            if (response != null &&
                                response['statusCode'] == true) {
                              setState(() {
                                isLiked = !isLiked;
                                if (isLiked) {
                                  droppinlikes++;
                                  final names =
                                      GlobalVariables.realName?.split(' ') ??
                                          ['Unknown', ''];
                                  final firstName = names[0];
                                  final lastName =
                                      names.length > 1 ? names[1] : '';

                                  widget.post['droppins'][droppinIndex]
                                          ['liked_users']
                                      .add({
                                    'photo': GlobalVariables.userImageUrl,
                                    'first_name': firstName,
                                    'last_name': lastName,
                                    'rolla_username': GlobalVariables.userName,
                                  });
                                } else {
                                  droppinlikes--;
                                  widget.post['droppins'][droppinIndex]
                                          ['liked_users']
                                      .removeWhere((user) =>
                                          user['rolla_username'] ==
                                          GlobalVariables.userName);
                                }
                                setState(() {
                                  likes = _calculateTotalLikes(
                                      widget.post['droppins']);
                                });
                              });
                              logger.i(response['message']);
                            } else {
                              logger.e('Failed to toggle like');
                            }
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
                              showLikesDropdown = !showLikesDropdown;
                            });
                          },
                          child: Text(
                            '$droppinlikes likes',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              letterSpacing: -0.1,
                              fontFamily: 'inter',
                            ),
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            if (GlobalVariables.userId == userId) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => HomeViewScreen(
                                          viewdList: viewlist!,
                                          imagePath: imagePath,
                                        )),
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 2, horizontal: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF933F10),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              '$viewcount Views',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                letterSpacing: -0.1,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ),
                        )
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
                                    ? const Icon(Icons.person, size: 20)
                                    : null,
                              ),
                              const SizedBox(width: 5),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$firstName $lastName',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      letterSpacing: -0.1,
                                      fontFamily: 'inter',
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    username,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      letterSpacing: -0.1,
                                      color: Colors.grey,
                                      fontFamily: 'inter',
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
    ).then((_) {
      widget.onLikesUpdated(likes);
    });
  }

  Future<void> _showLikeDialog(BuildContext context, String imagePath) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0), // Rounded corners
            side: const BorderSide(
              color: Colors.transparent, // Border color (transparent)
              width: 0.5,
            ),
          ),
          child: SizedBox(
            width: 200, // Set the width of the dialog here
            child: Container(
              padding: const EdgeInsets.all(16.0), // Padding inside the dialog
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Profile image at the top
                  Container(
                    height: 60, // Image height
                    width: 60, // Image width
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color:
                            kColorHereButton, // Border color around the image
                        width: 2,
                      ),
                      image: imagePath.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(imagePath),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: imagePath.isEmpty
                        ? const Icon(Icons.person, size: 40) // Default icon
                        : null,
                  ),
                  const SizedBox(
                      height: 16), // Spacing between image and buttons

                  // Mute Posts Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      side: const BorderSide(
                          color: Colors.green, width: 1), // Border color
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(30), // Rounded corners
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Mute Posts',
                      style: TextStyle(
                        fontFamily: 'inter',
                        letterSpacing: -0.1,
                        color: Colors.green,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      side: const BorderSide(color: Colors.orange, width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(30), // Rounded corners
                      ),
                    ),
                    onPressed: () {
                      // Handle unfollow action here
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Unfollow',
                      style: TextStyle(
                        fontFamily: 'inter',
                        letterSpacing: -0.1,
                        color:
                            Colors.orange, // Text color to match button border
                      ),
                    ),
                  ),
                  const SizedBox(height: 8), // Spacing between buttons

                  // Block User Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      side: const BorderSide(color: Colors.red, width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {
                      // Handle block action here
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Block User',
                      style: TextStyle(
                        fontFamily: 'inter',
                        letterSpacing: -0.1,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _goTagScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HomeTagScreen(taglist:  widget.post['trip_tags'])),
    );
  }

  void _goUserScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => HomeUserScreen(
                userId: widget.post['user_id'],
              )),
    );
  }

  Future<void> _sendComment() async {
    final commentText = _addCommitController.text;
    if (commentText.isEmpty) {
      _showAlert('Error', 'Comment text cannot be blank.');
      return;
    }

    setState(() {
      isAddComments = false;
      isLoading = true;
    });

    final response = await apiService.sendComment(
      userId: GlobalVariables.userId!,
      tripId: widget.post['id'],
      content: commentText,
    );

    setState(() {
      isLoading = false;
    });

    if (response != null) {
      _showAlert('Success', 'Comment sent successfully.');
      logger.i('Comment sent successfully: ${response['comment']}');
      setState(() {
        widget.post['comments'].add({
          'user': {
            'rolla_username': GlobalVariables.userName,
            'photo': GlobalVariables.userImageUrl,
          },
          'content': commentText,
        });
      });
      _addCommitController.clear();
    } else {
      _showAlert('Error', 'Failed to send comment.');
      logger.e('Failed to send comment');
    }
  }

  void _showAlert(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final updatedAt = DateTime.parse(widget.post["updated_at"]);
    final now = DateTime.now();
    final difference = now.difference(updatedAt);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(width: 10,),
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
                    width: 1,
                  ),
                  image: widget.post['user']['photo'] != null
                      ? DecorationImage(
                          image: NetworkImage(widget.post['user']['photo']),
                          fit: BoxFit.cover,
                          onError: (exception, stackTrace) {},
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(width: 10),
            // User's username
            Text(
              "@${widget.post['user']['rolla_username']}",
              style: const TextStyle(
                  fontSize: 15,
                  fontFamily: 'inter',
                  letterSpacing: -0.1,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 5),
            // Verified icon
            const Icon(Icons.verified, color: kColorHereButton, size: 18),
            const Spacer(),
            GestureDetector(
              onTap: () {
                _showLikeDialog(context, widget.post['user']['photo']);
              },
              child: Image.asset(
                "assets/images/icons/reference.png",
                width: 24,
                height: 24,
              ),
            ),
            const SizedBox(width: 10,),
          ],
        ),
        SizedBox(height: vhh(context, 0.5)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('destination',
                    style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'inter',
                        letterSpacing: -0.1,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 3),
                Text('soundtrack',
                    style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'inter',
                        letterSpacing: -0.1,
                        fontWeight: FontWeight.bold)),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(
                  width: 210,
                  child: Text(
                    widget.post['destination_text_address']
                                .replaceAll(RegExp(r'[\[\]"]'), '') ==
                            "Edit destination"
                        ? " "
                        : widget.post['destination_text_address']
                            .replaceAll(RegExp(r'[\[\]"]'), ''),
                    style: const TextStyle(
                      fontSize: 13,
                      color: kColorButtonPrimary,
                      fontFamily: 'inter',
                      letterSpacing: -0.1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(height: 3),
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
                      color: Colors.brown, // Border color
                      width: 1, // Thin border
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
              ],
            ),
          ],
        ),
        SizedBox(height: vhh(context, 1)),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: List.generate(
            widget.post['droppins'].length,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.black,
                  width: 1,
                ),
              ),
              child: GestureDetector(
                onTap: () {
                  _showImageDialog(
                      widget.post['droppins'][index]['image_path'],
                      widget.post['droppins'][index]['image_caption'],
                      widget.post['droppins'][index]['liked_users'].length,
                      widget.post['droppins'][index]['liked_users'],
                      widget.post['droppins'][index]['id'],
                      widget.post['user_id'],
                      widget.post['droppins'][index]['view_count'],
                      index);
                },
                child: Container(
                  padding: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white, // Background color
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        spreadRadius: 0.5,
                        blurRadius: 6,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 10,
                    backgroundColor: Colors.white,
                    child: Text('${index + 1}',
                        style: const TextStyle(
                            color: Colors.black,
                            fontFamily: 'inter',
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.1)),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          height: 250,
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(
              color: Colors.black, // or any color you prefer
              width: 0.5, // set the border width
            ),
          ),
          child: Stack(
            children: [
              isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : FlutterMap(
                      mapController: mapController,
                      options: MapOptions(
                        initialCenter: startPoint != null
                            ? startPoint!
                            : const LatLng(0, 0),
                        initialZoom: 11.5,
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
                                width: 80.0,
                                height: 80.0,
                                point: startPoint!,
                                child: const SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: Icon(Icons.flag,
                                      color: Colors.red, size: 30),
                                ),
                              ),
                            if (endPoint != null)
                              Marker(
                                width: 80.0,
                                height: 80.0,
                                point: endPoint!,
                                child: const SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: Icon(Icons.flag,
                                      color: Colors.green, size: 30),
                                ),
                              ),
                            ...locations.map((location) {
                              return Marker(
                                width: 25.0,
                                height: 25.0,
                                point: location,
                                child: GestureDetector(
                                  onTap: () {
                                    // Handle tap logic here
                                    final index = locations.indexOf(location);
                                    final droppin =
                                        widget.post['droppins'][index];
                                    _showImageDialog(
                                      droppin['image_path'],
                                      droppin['image_caption'],
                                      droppin['liked_users'].length,
                                      droppin['liked_users'],
                                      droppin['id'],
                                      widget.post['user_id'],
                                      droppin['view_count'],
                                      index,
                                    );
                                  },
                                  child: Container(
                                    
                                    width: 14, // Smaller width
                                    height: 14, // Smaller height
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                      border: Border.all(
                                        color: kColorBlack, // Border color
                                        width: 1, // Border width
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.4),
                                          spreadRadius: 0.5,
                                          blurRadius: 6,
                                          offset: const Offset(0, 5),
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
                                ),
                              );
                            }),
                          ],
                        ),
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
              Positioned(
                right: 10,
                top: 10,
                child: Column(
                  children: [
                    FloatingActionButton(
                      heroTag:
                          'zoom_in_button_homescreen_tap1_${DateTime.now().millisecondsSinceEpoch}',
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
                      heroTag:
                          'zoom_out_button_homescreen_tap2_${DateTime.now().millisecondsSinceEpoch}',
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
        const SizedBox(
          height: 5,
        ),
        if (isAddComments)
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: TextField(
                    controller: _addCommitController,
                    decoration: const InputDecoration(
                      hintText: 'add a comment',
                      hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 15,
                          letterSpacing: -0.1,
                          fontFamily: 'inter'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        borderSide: BorderSide(
                          color: Colors.grey,
                          width: 1.0,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        borderSide: BorderSide(
                          color: Colors.grey,
                          width: 1.0,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        borderSide: BorderSide(
                          color: Colors.grey,
                          width: 1.0,
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        vertical:
                            10.0, // Adjust vertical padding to center text
                        horizontal: 8.0, // Optional: Adjust horizontal padding
                      ),
                    ),
                    style: const TextStyle(
                      fontFamily: 'inter',
                      fontSize: 15,
                      letterSpacing: -0.1,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send, color: kColorHereButton),
                onPressed: _sendComment,
              ),
            ],
          ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const SizedBox(width: 10,),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      showLikesDropdown = true;
                    });
                  },
                  child: Text(
                    '$likes likes',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      color: widget.post['userId'] == GlobalVariables.userId
                          ? Colors.red
                          : Colors.grey,
                      fontSize: 13,
                      letterSpacing: -0.1,
                      fontFamily: 'inter',
                    ),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isAddComments =
                          !isAddComments; // Toggle the visibility of comments
                    });
                  },
                  child: Image.asset("assets/images/icons/messageicon.png",
                      width: vww(context, 4)),
                ),
                const SizedBox(width: 15),
                GestureDetector(
                  onTap: () {
                    _goTagScreen();
                  },
                  child: Image.asset("assets/images/icons/add_car.png",
                      width: vww(context, 7)),
                ),
                const SizedBox(width: 5,),
              ],
            ),
            const SizedBox(height: 1),
            // Row(
            //   crossAxisAlignment: CrossAxisAlignment.start,
            //   children: [
            //     Text(widget.post['user']['rolla_username'],
            //         style: const TextStyle(
            //           fontWeight: FontWeight.bold,
            //           fontSize: 15,
            //           letterSpacing: -0.1,
            //           fontFamily: 'inter',
            //         )),
            //     const SizedBox(width: 15),
            //     Text(widget.post['trip_caption'] ?? " ",
            //         style: const TextStyle(
            //           color: kColorButtonPrimary,
            //           fontSize: 15,
            //           letterSpacing: -0.1,
            //           fontFamily: 'inter',
            //         )),
            //   ],
            // ),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                widget.post['trip_caption'] ?? "", 
                style: const TextStyle(
                  fontFamily: 'inter', 
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                  letterSpacing: -0.1
                  ),
                ),
            ),
            const SizedBox(height: 12),
            Center(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    showComments = !showComments;
                  });
                },
                child: Text(
                  '${widget.post["comments"].length} comments',
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 13,
                    fontFamily: 'inter',
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
                                    image:
                                        NetworkImage(comment['user']['photo']),
                                    fit: BoxFit.cover,
                                  )
                                : null,
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
                            letterSpacing: -0.1,
                            fontFamily: 'inter',
                          ),
                        ),
                        const SizedBox(width: 5),
                        if (comment['user']['rolla_username'] != null)
                          const Icon(Icons.verified,
                              color: Colors.blue, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            comment['content'] ?? '',
                            style: const TextStyle(
                              fontFamily: 'inter',
                              fontSize: 14,
                              letterSpacing: 0.1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            SizedBox(height: vh(context, 4),),
            Padding(
              padding: const EdgeInsets.only(left: 7),
              child: Text(
                'last updated ${timeago.format(now.subtract(difference), locale: 'en_short')} ago',
                style: const TextStyle(
                  fontFamily: 'inter',
                  color: Color(0xFF95989C),
                  fontSize: 11, 
                )
              ),
            ),
            
          ],
        ),
        const SizedBox(height: 2),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Divider(),
        ),
      ],
    );
  }
}
