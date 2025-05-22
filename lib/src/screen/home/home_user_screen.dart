import 'dart:convert';

import 'package:RollaTravel/src/constants/app_styles.dart';
import 'package:RollaTravel/src/screen/home/home_follower_screen.dart';
import 'package:RollaTravel/src/screen/home/home_screen.dart';
import 'package:RollaTravel/src/services/api_service.dart';
import 'package:RollaTravel/src/translate/en.dart';
import 'package:RollaTravel/src/utils/global_variable.dart';
import 'package:RollaTravel/src/utils/index.dart';
import 'package:RollaTravel/src/utils/spinner_loader.dart';
import 'package:RollaTravel/src/widget/bottombar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:logger/logger.dart';

class HomeUserScreen extends ConsumerStatefulWidget {
  final int userId;
  const HomeUserScreen({super.key, required this.userId});

  @override
  ConsumerState<HomeUserScreen> createState() => HomeUserScreenState();
}

class HomeUserScreenState extends ConsumerState<HomeUserScreen> {
  double screenHeight = 0;
  double keyboardHeight = 0;
  final int _currentIndex = 5;
  int? userid;
  bool isLiked = false;
  bool showLikesDropdown = false;
  Map<String, dynamic>? userProfile;
  String? rollaUserName;
  String? rollaUserImage;
  String? tripCount;
  String? followingCount;
  String? happlyPlace;
  String? garageLogoUrl;
  final logger = Logger();
  bool isloding = true;
  bool isfollow = false;
  bool isMefollow = false;
  List<Map<String, dynamic>>? userTrips;
  bool isLoadingTrips = true;
  LatLng? startPoint;
  LatLng? endPoint;
  List<LatLng> locations = [];
  late List<dynamic> dropPinsData = [];

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
    _fetchUserProfile();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _fetchUserProfile() async {
    try {
      setState(() {
        isloding = true;
      });

      final result  = await ApiService().fetchUserTrips(widget.userId);
      var userProfile = result['trips'];
      final userInfo = result['userInfo'];
      logger.i(userInfo);

      rollaUserName = userInfo[0]['rolla_username'] ?? " ";
      rollaUserImage = userInfo[0]['photo'];
      userid = userInfo[0]['id'];

      if (userInfo[0]['bio'] != null) {
        happlyPlace = userInfo[0]['bio'];
      }

      if(userInfo[0]['id'] == GlobalVariables.userId){
        isMefollow = true;
      }

      if (userInfo[0]['garage'] != null && userInfo[0]['garage'].isNotEmpty) {
        garageLogoUrl = userInfo[0]['garage'][0]['logo_path'];
      }

      int triplenght;
      if (userProfile.isNotEmpty) {
        triplenght = userProfile.length;
        tripCount = triplenght.toString();
      } else {
        tripCount = "0";
      }

      int? followcount;
      if (userInfo[0]['following_user_id'] != "") {
        followcount = userInfo[0]['following_user_id'].split(',').length;

        String userIdString = GlobalVariables.userId.toString();
        List<String> followingUserIds = userInfo[0]['following_user_id'].split(',');
        if (followingUserIds.contains(userIdString)) {
          isfollow = true;
        }
      } else {
        followcount = 0;
      }
      followingCount = followcount.toString();

      List<dynamic> allDroppins = [];
      for (var trip in userProfile) {
        if (trip['droppins'] != null) {
          allDroppins.addAll(trip['droppins'] as List<dynamic>);
        }
      }
      // userProfile.reverse(); 
      userProfile = userProfile.reversed.toList();
      allDroppins = allDroppins.reversed.toList();
      setState(() {
        userTrips = userProfile;
        dropPinsData = allDroppins.isNotEmpty ? allDroppins : [];
        isLoadingTrips = false;
      });

    } catch (e) {
      logger.e("Error fetching user profile: $e");
    } finally {
      setState(() {
        isloding = false;
      });
    }
  }

  void _onFollowers() {
    String fromUser = "@$rollaUserName";
    Navigator.push(context,
        MaterialPageRoute(builder: (context) =>  HomeFollowScreen(userid: userid, fromUser: fromUser,)));
  }

  void follow() async {
    try {
      final apiservice = ApiService();
      final result = await apiservice.followUser(userid!, GlobalVariables.userId!);

      if (result['statusCode'] == true) {
        setState(() {
          isfollow = !isfollow;
          if (isfollow) {
            followingCount = (int.parse(followingCount!) + 1).toString();
          } else {
            followingCount = (int.parse(followingCount!) - 1).toString();
          }
        });
      }
    } catch (e) {
      logger.i('Error: $e');
    }
  }

  void _showImageDialog(
      String imagePath, String caption, int likes, List<dynamic> likedUsers) {
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
                          ),
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
                            return const Center(
                              child: SpinningLoader(),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  const Divider(
                      height: 1,
                      color: Colors.grey), 
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
                              showLikesDropdown = !showLikesDropdown; 
                            });
                          },
                          child: Text(
                            '$likes likes',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              fontFamily: 'inter',
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
                                    ? const Icon(Icons.person,
                                        size: 20)
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
                                      fontFamily: 'inter',
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    username,
                                    style: const TextStyle(
                                      fontSize: 12,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isloding) {
      return const Scaffold(
        body: Center(child: SpinningLoader()),
      );
    }
    return Scaffold(
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            return;
          }
        },
        child: Scaffold(
          backgroundColor: kColorWhite,
          resizeToAvoidBottomInset: true,
          body: SingleChildScrollView(
            child: FocusScope(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height,
                ),
                child: IntrinsicHeight(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: kColorWhite,
                    ),
                    padding: EdgeInsets.symmetric(horizontal: vww(context, 0)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(height: vhh(context, 5)),
                        Stack(
                          alignment: Alignment.topCenter,
                          children: [
                            // === Trips - Avatar - Followers Row ===
                            Padding(
                              padding: EdgeInsets.only(top: vhh(context, 7.5)), 
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Container(),
                                  Column(
                                    children: [
                                      Image.asset(
                                        'assets/images/icons/trips1.png',
                                        width: vww(context, 20),
                                      ),
                                      Text(
                                        tripCount!,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          color: kColorButtonPrimary,
                                          fontFamily: 'interBold',
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    height: vhh(context, 15),
                                    width: vhh(context, 15),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(100),
                                        border: Border.all(
                                          color: kColorHereButton,
                                          width: 2,
                                        ),
                                        image: rollaUserImage != null
                                            ? DecorationImage(
                                                image: NetworkImage(
                                                    rollaUserImage!), // Use NetworkImage for URL
                                                fit: BoxFit.cover,
                                              )
                                            : null),
                                  ),
                                  Column(
                                    children: [
                                      Image.asset(
                                        'assets/images/icons/follower1.png',
                                        width: vww(context, 21),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          _onFollowers();
                                        },
                                        child: Text(
                                          followingCount!,
                                          style: const TextStyle(
                                            fontSize: 20,
                                            color: kColorButtonPrimary,
                                            fontFamily: 'interBold',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(),
                                ],
                              ),
                            ),

                            // === Username & Verified Row (overlays the top center) ===
                            Positioned(
                              top: vhh(context, 0), 
                              left: 0,
                              right: 0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Image.asset(
                                    'assets/images/icons/logo.png',
                                    width: 90,
                                    height: 80,
                                  ),
                                  const Spacer(),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        "@$rollaUserName",
                                        style: const TextStyle(
                                          color: kColorBlack,
                                          fontSize: 17,
                                          fontWeight: FontWeight.w500,
                                          fontFamily: 'inter',
                                          letterSpacing: -0.1,
                                        ),
                                      ),
                                      Image.asset(
                                        'assets/images/icons/verify.png',
                                        width: vww(context, 10),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    icon: const Icon(Icons.close, size: 30),
                                    onPressed: () {
                                      Navigator.of(context).pop(); // Close the screen
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: vhh(context, 1)),
                        Text(
                          rollaUserName ?? "",
                          style: const TextStyle(
                            color: kColorBlack,
                            fontSize: 17,
                            letterSpacing: -0.1,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'inter'
                          ),
                        ),
                        Text(
                          happlyPlace ?? "",
                          style: const TextStyle(
                            color: kColorGrey,
                            fontSize: 15,
                            letterSpacing: -0.1,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'inter'
                          ),
                        ),
                        SizedBox(height: vhh(context, 2)),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: isMefollow ? null : () {
                                follow();
                              },
                              child: Container(
                                width: vww(context, 90),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                margin: const EdgeInsets.only(right: 5), 
                                decoration: BoxDecoration(
                                  color: isMefollow ? Colors.grey : kColorButtonPrimary,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.2),
                                      offset: const Offset(0, 2),
                                      blurRadius: 4, 
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    isfollow ? 'Unfollow' : "Follow",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14, 
                                      fontFamily: 'inter',
                                      fontWeight: FontWeight.bold
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // GestureDetector(
                            //   onTap: () {
                            //     // Add functionality for Send Message button
                            //   },
                            //   child: Container(
                            //     width: vww(context, 40),
                            //     padding: const EdgeInsets.symmetric(
                            //         horizontal: 10, vertical: 3),
                            //     decoration: BoxDecoration(
                            //       color: kColorHereButton,
                            //       borderRadius: BorderRadius.circular(20), 
                            //       boxShadow: [
                            //         BoxShadow(
                            //           color: Colors.black.withValues(alpha: 0.2),
                            //           offset: const Offset(0, 2),
                            //           blurRadius: 4,
                            //         ),
                            //       ],
                            //     ),
                            //     child: const Center(
                            //       child: Row(
                            //         mainAxisSize: MainAxisSize.min,
                            //         children: [
                            //           Icon(
                            //             Icons.message_sharp, // Add an icon
                            //             color: Colors.white, // Icon color
                            //             size: 16, // Icon size
                            //           ),
                            //           SizedBox(
                            //               width:
                            //                   2),
                            //           Text(
                            //             'Send Message',
                            //             style: TextStyle(
                            //               color: Colors.white, // Text color
                            //               fontSize: 14, // Font size
                            //               fontFamily:
                            //                   'interBold', // Font weight
                            //             ),
                            //           ),
                            //         ],
                            //       ),
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),

                        SizedBox(height: vhh(context, 1)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    happy_place,
                                    style: TextStyle(
                                      color: kColorBlack,
                                      fontSize: 14,
                                      fontFamily: 'inter',
                                    ),
                                  ),
                                  Text(
                                    happlyPlace ?? "",
                                    style: const TextStyle(
                                      color: kColorButtonPrimary,
                                      fontSize: 14,
                                      fontFamily: 'inter',
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    my_garage,
                                    style: TextStyle(
                                      color: kColorBlack,
                                      fontSize: 14,
                                      fontFamily: 'inter',
                                    ),
                                  ),
                                  garageLogoUrl != null
                                    ? Image.network(
                                        garageLogoUrl!,
                                        width: 25,
                                        height: 25,
                                      )
                                    : const Text(""),
                                ],
                              ),
                              SizedBox(height: vhh(context, 1)),
                              SizedBox(
                                height: 100,
                                child: (dropPinsData).isEmpty
                                ? const Center(
                                    child: Text("No drop pins available",
                                        style: TextStyle(
                                            color: Colors.grey,
                                            letterSpacing: -0.1,
                                            fontFamily: 'inter')),
                                  )
                                : ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: dropPinsData.length,
                                  itemBuilder: (context, index) {
                                    final dropPin = dropPinsData[index]
                                        as Map<String, dynamic>;
                                    final String imagePath =
                                        dropPin['image_path'] ?? '';
                                    final String caption =
                                        dropPin['image_caption'] ?? 'No caption';
                                    final List<dynamic> likedUsers =
                                        dropPin['liked_users'] ?? [];

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 3),
                                      child: GestureDetector(
                                        onTap: () {
                                          _showImageDialog(imagePath, caption,
                                              likedUsers.length, likedUsers);
                                        },
                                        child: imagePath.isNotEmpty
                                            ? Container(
                                                width: 100,
                                                height: 100,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Colors.black
                                                          .withValues(alpha: 0.5),
                                                      Colors.transparent
                                                    ],
                                                    begin: Alignment.bottomCenter,
                                                    end: Alignment.topCenter,
                                                  ),
                                                ),
                                                child: Image.network(
                                                  imagePath,
                                                  fit: BoxFit.cover,
                                                  loadingBuilder: (context, child,
                                                      loadingProgress) {
                                                    if (loadingProgress == null) {
                                                      return child;
                                                    } else {
                                                      return const Center(
                                                          child:
                                                              SpinningLoader());
                                                    }
                                                  },
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return const Icon(
                                                        Icons.broken_image,
                                                        size: 100);
                                                  },
                                                ),
                                              )
                                            : const Icon(
                                                Icons.image_not_supported,
                                                size: 100),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        

                        
                        ),
                        
                        SizedBox(height: vhh(context, 1)),

                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          color: kColorWhite,
                        child: Column(
                          children: [
                            const Padding(padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Divider(
                                height: 1,
                                thickness: 2,
                                color: Colors.blue,
                              ),
                            ),
                            SizedBox(height: vhh(context, 1)),
                            userTrips == null
                                ? const Center(
                                    child: SpinningLoader())
                                : userTrips!.isEmpty
                                    ? const Center(
                                        child: Text("No trips to display"))
                                    : Column(
                                        children: List.generate(
                                          (userTrips!.length / 2).ceil(),
                                          (rowIndex) => Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.4,
                                                    height: 110,
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                        color: Colors.black,
                                                        width: 1,
                                                      ),
                                                    ),
                                                    child: TripMapWidget(
                                                      trip: userTrips![
                                                          rowIndex * 2],
                                                      index: rowIndex * 2,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12,),
                                                  if (rowIndex * 2 + 1 <
                                                      userTrips!.length)
                                                    Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.4,
                                                      height: 110,
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                          color: Colors.black,
                                                          width: 1,
                                                        ),
                                                      ),
                                                      child: TripMapWidget(
                                                        trip: userTrips![
                                                            rowIndex * 2 + 1],
                                                        index: rowIndex * 2 + 1,
                                                      ),
                                                    ),
                                                  if (rowIndex * 2 + 1 >=
                                                      userTrips!.length)
                                                    SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.4),
                                                ],
                                              ),
                                              if (rowIndex <
                                                  (userTrips!.length / 2)
                                                          .ceil() -
                                                      1)
                                                Column(
                                                  children: [
                                                    SizedBox(
                                                        height:
                                                            vhh(context, 1)),
                                                  ],
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                          ],
                        ),
                      ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: _currentIndex),
    );
  }
}


// Create a new StatefulWidget for trip maps
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
  LatLng? lastDropPoint;
  bool isLoading = true;
  final logger = Logger();

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
    mapController.dispose(); // If applicable
    super.dispose();
  }

  void _adjustZoom() {
    if (lastDropPoint != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final bounds = LatLngBounds(
          LatLng(lastDropPoint!.latitude - 0.03, lastDropPoint!.longitude - 0.03),
          LatLng(lastDropPoint!.latitude + 0.03, lastDropPoint!.longitude + 0.03), 
        );

        final center = bounds.center;

        mapController.move(center, 12.0); 
      });
    }
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
          return LatLng(
              coordinates[1], coordinates[0]); // [lng, lat] to LatLng(lat, lng)
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
      // Fetch Start Address
      final startCoordinates =
          await _getCoordinates(widget.trip['start_address']);
      if (startCoordinates != null) {
        startPoint = startCoordinates;
      }
    } catch (e) {
      logger.e('Failed to fetch start address coordinates: $e');
    }

    // Use Stop Locations directly
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

    // Fetch Destination Address
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
      // Assign the last location to lastDropPoint
      if (tempLocations.isNotEmpty) {
        lastDropPoint = tempLocations.last;
      }
    });
    _adjustZoom();
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
    return Container(
      height: 150,
      margin: const EdgeInsets.only(bottom: 10),
      child: isLoading
          ? const Center(child: SpinningLoader())
          : Stack(
              children: [
                FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    initialCenter: lastDropPoint ?? startPoint ?? const LatLng(37.7749, -122.4194), 
                    initialZoom: 12.0,
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
