import 'package:RollaTravel/src/constants/app_styles.dart';
import 'package:RollaTravel/src/screen/home/home_follower_screen.dart';
import 'package:RollaTravel/src/screen/home/home_screen.dart';
import 'package:RollaTravel/src/screen/profile/edit_profile.dart';
import 'package:RollaTravel/src/screen/settings/settings_screen.dart';
import 'package:RollaTravel/src/services/api_service.dart';
import 'package:RollaTravel/src/translate/en.dart';
import 'package:RollaTravel/src/utils/global_variable.dart';
import 'package:RollaTravel/src/utils/index.dart';
import 'package:RollaTravel/src/widget/bottombar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => ProfileScreenState();
}

class ProfileScreenState extends ConsumerState<ProfileScreen> {
  double screenHeight = 0;
  double keyboardHeight = 0;
  final int _currentIndex = 4;
  bool isLiked = false;
  bool showLikesDropdown = false;
  String? followingCount;
  String? garageImageUrl;
  final logger = Logger();

  List<Map<String, dynamic>>? userTrips;
  bool isLoadingTrips = true;

  LatLng? startPoint;
  LatLng? endPoint;
  List<LatLng> locations = [];
  late List<dynamic> dropPinsData = []; // Initialize with an empty list

  @override
  void initState() {
    super.initState();
    _loadUserTrips();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
      if (mounted) {
        setState(() {
          this.keyboardHeight = keyboardHeight;
        });
      }
    });
    if (GlobalVariables.followingIds != null &&
        GlobalVariables.followingIds!.isNotEmpty) {
      int count = GlobalVariables.followingIds!.split(',').length;
      followingCount = count.toString();
    }
  }

  Future<void> _loadUserTrips() async {
    try {
      final apiService = ApiService();
      final trips = await apiService.fetchUserTrips(GlobalVariables.userId!);
      logger.i(trips);
      garageImageUrl = trips[0]['user']['garage']['logo_path'];
      List<dynamic> allDroppins = [];

      for (var trip in trips) {
        if (trip['droppins'] != null) {
          allDroppins.addAll(trip['droppins'] as List<dynamic>);
        }
      }

      setState(() {
        userTrips = trips;
        dropPinsData = allDroppins.isNotEmpty ? allDroppins : [];
        isLoadingTrips = false;
      });
      // logger.i(dropPinsData);
      // if (userTrips != null && userTrips!.isNotEmpty) {}
    } catch (error) {
      logger.e('Error fetching user trips: $error');
      setState(() {
        userTrips = [];
        isLoadingTrips = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Future<bool> _onWillPop() async {
  //   return false;
  // }

  void _onFollowers() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const HomeFollowScreen()));
  }

  void _onSettingButtonClicked() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const SettingsScreen()));
  }

  void _onEditButtonClicked() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const EditProfileScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0); // Start from the right
          const end = Offset.zero; // End at the current position
          const curve = Curves.easeInOut;

          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(position: offsetAnimation, child: child);
        },
      ),
    );
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
                  // Caption and Close Icon Row
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
                            fontFamily: 'Kadaw',
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.black),
                          onPressed: () {
                            Navigator.of(context).pop();
                            setState(() {
                              showLikesDropdown =
                                  false; // Hide the dropdown when the dialog is closed
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  // Image
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Image
                      Image.network(
                        imagePath,
                        fit: BoxFit.cover,
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: MediaQuery.of(context).size.height * 0.5,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.broken_image, size: 100),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) {
                            // Image has finished loading
                            return child;
                          } else {
                            // Show a rotating loading indicator while the image loads
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
                  const Divider(
                      height: 1,
                      color: Colors.grey), // Divider between image and footer
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
                              showLikesDropdown =
                                  !showLikesDropdown; // Toggle the visibility of the dropdown
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
                                    ? const Icon(Icons.person,
                                        size: 20) // Placeholder icon
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kColorWhite,
      body: SafeArea(
        child: isLoadingTrips
            ? const Center(
                child: CircularProgressIndicator()) // Show loader while loading
            : SingleChildScrollView(
                child: Container(
                  decoration: const BoxDecoration(
                    color: kColorWhite,
                  ),
                  padding: EdgeInsets.symmetric(horizontal: vww(context, 4)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height: vhh(context, 1)),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Image.asset(
                            'assets/images/icons/logo.png',
                            width: vww(context, 20),
                          ),
                          SizedBox(width: vww(context, 18)),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                '@${GlobalVariables.userName}',
                                style: const TextStyle(
                                    color: kColorBlack,
                                    fontSize: 18,
                                    fontFamily: 'Kadaw'),
                              ),
                              Image.asset(
                                'assets/images/icons/verify.png',
                                width: vww(context, 5),
                                height: 20,
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Container(),
                          Column(
                            children: [
                              Image.asset(
                                'assets/images/icons/trips.png',
                                width: vww(context, 19),
                              ),
                              Text(
                                GlobalVariables.tripCount != null
                                    ? GlobalVariables.tripCount!.toString()
                                    : "0",
                                style: const TextStyle(
                                    fontSize: 20,
                                    color: kColorButtonPrimary,
                                    fontFamily: 'KadawBold'),
                              ),
                            ],
                          ),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              // Circular container with border
                              Container(
                                height: vhh(context, 15),
                                width: vhh(context, 15),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  border: Border.all(
                                    color: kColorHereButton,
                                    width: 2,
                                  ),
                                ),
                              ),

                              // Image with loading indicator
                              ClipOval(
                                child: GlobalVariables.userImageUrl != null
                                    ? Image.network(
                                        GlobalVariables.userImageUrl!,
                                        fit: BoxFit.cover,
                                        height: vhh(context, 15),
                                        width: vhh(context, 15),
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                          if (loadingProgress == null) {
                                            return child;
                                          }
                                          return SizedBox(
                                            height: vhh(context, 15),
                                            width: vhh(context, 15),
                                            child: Center(
                                              child: CircularProgressIndicator(
                                                value: loadingProgress
                                                            .expectedTotalBytes !=
                                                        null
                                                    ? loadingProgress
                                                            .cumulativeBytesLoaded /
                                                        (loadingProgress
                                                                .expectedTotalBytes ??
                                                            1)
                                                    : null,
                                                strokeWidth: 2,
                                              ),
                                            ),
                                          );
                                        },
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Container(
                                            height: vhh(context, 15),
                                            width: vhh(context, 15),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.grey[
                                                  300], // Placeholder background
                                            ),
                                            child: Icon(
                                              Icons.person, // Fallback icon
                                              color: Colors.grey[600],
                                            ),
                                          );
                                        },
                                      )
                                    : Container(
                                        height: vhh(context, 15),
                                        width: vhh(context, 15),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.grey[300],
                                        ),
                                        child: Icon(
                                          Icons.person,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Image.asset(
                                'assets/images/icons/followers.png',
                                width: vww(context, 19),
                              ),
                              GestureDetector(
                                onTap: () {
                                  _onFollowers();
                                },
                                child: Text(
                                  followingCount != null
                                      ? followingCount!
                                      : "0",
                                  style: const TextStyle(
                                      fontSize: 20,
                                      color: kColorButtonPrimary,
                                      fontFamily: 'KadawBold'),
                                ),
                              ),
                            ],
                          ),
                          Container(),
                        ],
                      ),
                      SizedBox(height: vhh(context, 1)),
                      Text(
                        GlobalVariables.realName!,
                        style: const TextStyle(
                            color: kColorBlack,
                            fontSize: 20,
                            fontFamily: 'Kadaw'),
                      ),
                      SizedBox(height: vhh(context, 1)),

                      Text(
                        GlobalVariables.bio != null
                            ? GlobalVariables.bio!
                            : " ",
                        style: const TextStyle(
                            color: kColorGrey,
                            fontSize: 18,
                            fontFamily: 'Kadaw'),
                      ),
                      SizedBox(height: vhh(context, 2)),
                      Row(
                        children: [
                          SizedBox(
                            width: vww(context, 30),
                            height: 28,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    kColorStrongGrey, // Button background color
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      30), // Rounded corners
                                ),
                                shadowColor:
                                    // ignore: deprecated_member_use
                                    Colors.black
                                        // ignore: deprecated_member_use
                                        .withOpacity(0.9), // Shadow color
                                elevation: 6,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 2, vertical: 2),
                              ),
                              onPressed: () {
                                _onEditButtonClicked();
                              },
                              child: Text("Edit Profile",
                                  style: TextStyle(
                                      color: kColorWhite,
                                      fontSize: 34.sp,
                                      fontFamily: 'Kadaw')),
                            ),
                          ),
                          SizedBox(width: vww(context, 1)),
                          SizedBox(
                            width: vww(context, 30),
                            height: 28,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    kColorStrongGrey, // Button background color
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      30), // Rounded corners
                                ),
                                shadowColor:
                                    // ignore: deprecated_member_use
                                    Colors.black
                                        // ignore: deprecated_member_use
                                        .withOpacity(0.9), // Shadow color
                                elevation: 6,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 2, vertical: 2),
                              ),
                              onPressed: () {
                                _onFollowers();
                              },
                              child: Text("Following",
                                  style: TextStyle(
                                      color: kColorWhite,
                                      fontSize: 34.sp,
                                      fontFamily: 'Kadaw')),
                            ),
                          ),
                          SizedBox(width: vww(context, 1)),
                          SizedBox(
                            width: vww(context, 30),
                            height: 28,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    kColorStrongGrey, // Button background color
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      30), // Rounded corners
                                ),
                                shadowColor:
                                    // ignore: deprecated_member_use
                                    Colors.black
                                        // ignore: deprecated_member_use
                                        .withOpacity(0.9), // Shadow color
                                elevation: 6,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 2, vertical: 2),
                              ),
                              onPressed: () {
                                _onSettingButtonClicked();
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.settings, // Settings icon
                                    size: 16,
                                    color: kColorWhite,
                                  ),
                                  const SizedBox(
                                      width:
                                          2), // Spacing between icon and text
                                  Text(
                                    'Settings',
                                    style: TextStyle(
                                        color:
                                            kColorWhite, // Matches the text color to the button theme
                                        fontSize: 34.sp,
                                        fontFamily:
                                            'Kadaw' // Customize font size
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: vhh(context, 1)),
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                odometer,
                                style: TextStyle(
                                    color: kColorBlack,
                                    fontSize: 14,
                                    fontFamily: 'Kadaw'),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical:
                                        0), // Adjust padding for inner spacing
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: kColorButtonPrimary, // Border color
                                    width: 1.5, // Border width
                                  ),
                                  borderRadius: BorderRadius.circular(
                                      8), // Rounded corners
                                ),
                                child: Text(
                                  GlobalVariables.odometer != null
                                      ? '${GlobalVariables.odometer!} Km'
                                      : ' ',
                                  style: const TextStyle(
                                    color: kColorButtonPrimary,
                                    fontSize: 14,
                                    fontFamily: 'Kadaw',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                happy_place,
                                style: TextStyle(
                                    color: kColorBlack,
                                    fontSize: 14,
                                    fontFamily: 'Kadaw'),
                              ),
                              Text(
                                GlobalVariables.happyPlace != null
                                    ? GlobalVariables.happyPlace!
                                    : " ",
                                style: const TextStyle(
                                    color: kColorButtonPrimary,
                                    fontSize: 14,
                                    fontFamily: 'Kadaw'),
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
                                    fontFamily: 'Kadaw'),
                              ),
                              garageImageUrl != null
                                  ? Image.network(
                                      GlobalVariables.garageLogoUrl!,
                                      width: 25, // Adjust width as needed
                                      height: 25, // Adjust height as needed
                                    )
                                  : const Text(""),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: vhh(context, 1)),
                      SizedBox(
                        height: 100,
                        child: (dropPinsData).isEmpty
                            ? const Center(
                                child: Text("No drop pins available",
                                    style: TextStyle(color: Colors.grey)),
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
                                                    // ignore: deprecated_member_use
                                                    Colors.black
                                                        // ignore: deprecated_member_use
                                                        .withOpacity(0.5),
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
                                                            CircularProgressIndicator());
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

                      SizedBox(height: vhh(context, 1)),
                      // Map and Route Section with Dividers
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        color: kColorWhite,
                        child: Column(
                          children: [
                            const Divider(
                              height: 1,
                              thickness: 2,
                              color: Colors.blue,
                            ),
                            SizedBox(height: vhh(context, 2)),
                            userTrips == null
                                ? const Center(
                                    child: CircularProgressIndicator())
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
                                                    height: 150,
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                        color: Colors.grey,
                                                        width: 2,
                                                      ),
                                                    ),
                                                    child: TripMapWidget(
                                                      trip: userTrips![
                                                          rowIndex * 2],
                                                      index: rowIndex * 2,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.05,
                                                    height: 150,
                                                    child:
                                                        const VerticalDivider(
                                                      width: 2,
                                                      thickness: 2,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                  if (rowIndex * 2 + 1 <
                                                      userTrips!.length)
                                                    Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.4,
                                                      height: 150,
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                          color: Colors.grey,
                                                          width: 2,
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
                                                    const Divider(
                                                      height: 1,
                                                      thickness: 2,
                                                      color: Colors.grey,
                                                    ),
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
    return Container(
      height: 150,
      margin: const EdgeInsets.only(bottom: 10),
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    initialCenter:
                        startPoint != null ? startPoint! : const LatLng(0, 0),
                    initialZoom: 11.5,
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
