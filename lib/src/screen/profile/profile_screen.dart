import 'package:RollaTravel/src/constants/app_styles.dart';
import 'package:RollaTravel/src/screen/home/home_follower_screen.dart';
import 'package:RollaTravel/src/screen/profile/edit_profile.dart';
import 'package:RollaTravel/src/screen/profile/profile_following_screen.dart';
import 'package:RollaTravel/src/screen/profile/profile_map_widget.dart';
import 'package:RollaTravel/src/screen/settings/settings_screen.dart';
import 'package:RollaTravel/src/services/api_service.dart';
import 'package:RollaTravel/src/translate/en.dart';
import 'package:RollaTravel/src/utils/global_variable.dart';
import 'package:RollaTravel/src/utils/index.dart';
import 'package:RollaTravel/src/widget/bottombar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:latlong2/latlong.dart';
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
  String? username;
  String? happyPlace;
  bool _isLoading = false;
  final logger = Logger();
  List<Map<String, dynamic>>? userTrips;
  Map<String, dynamic>? userInfo;

  bool isLoadingTrips = true;
  LatLng? startPoint;
  LatLng? endPoint;
  List<LatLng> locations = [];
  late List<dynamic> dropPinsData = [];

  bool _isSelectMode = false;
  final List<int> _selectedMapIndices = [];

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
    garageImageUrl = GlobalVariables.garageLogoUrl;
   
  }

  Future<void> _loadUserTrips() async {
    try {
      final apiService = ApiService();
      final result  = await apiService.fetchUserTrips(GlobalVariables.userId!);
      // logger.i(result);
      if (result.isNotEmpty) { 
        final trips = result['trips'] as List<dynamic>;
        final userInfoList = result['userInfo'] as List<dynamic>?;

        List<dynamic> allDroppins = [] ;
        for (var trip in trips) {
          if (trip['droppins'] != null) {
            allDroppins.addAll(trip['droppins'] as List<dynamic>);
          }
        }

        if (userInfoList != null && userInfoList.isNotEmpty) {
          final user = Map<String, dynamic>.from(userInfoList.first);

          setState(() {
            username = user['rolla_username'] ?? '@unknown';
            happyPlace = user['happy_place'];

            final following = user['following_user_id'];
            if (following != null && following.toString().isNotEmpty) {
              followingCount = following.toString().split(',').length.toString();
            } else {
              followingCount = "0";
            }

            final garageList = user['garage'] as List<dynamic>?;
            if (garageList != null && garageList.isNotEmpty) {
              garageImageUrl = garageList.first['logo_path'];
              GlobalVariables.garageLogoUrl = garageImageUrl;
            } else {
              garageImageUrl = null;
              GlobalVariables.garageLogoUrl = garageImageUrl;
            }
          });
        }

        setState(() {
          userTrips = List<Map<String, dynamic>>.from(trips.reversed);
          dropPinsData = allDroppins.isNotEmpty ? allDroppins.reversed.toList() : [];
          isLoadingTrips = false;
        });
      } else {
        setState(() {
          userTrips = [];
          dropPinsData = [];
          isLoadingTrips = false;
        });
        logger.i("No trips found for user.");
      }
    } catch (error) {
      logger.e('Error fetching user trips: $error');
      setState(() {
        userTrips = [];
        dropPinsData = [];
        isLoadingTrips = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _showLoadingDialog() {
    setState(() {
      _isLoading = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CircularProgressIndicator(), // Progress bar
              SizedBox(width: 20),
              Text("Loading..."), // Loading text
            ],
          ),
        );
      },
    );
  }

  void _hideLoadingDialog() {
    if (_isLoading) {
      Navigator.of(context).pop();
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _onSelectTrip(int tripId) {
    setState(() {
      if (_selectedMapIndices.contains(tripId)) {
        _selectedMapIndices.remove(tripId); // Deselect the trip
      } else {
        _selectedMapIndices.add(tripId); // Select the trip
      }
      logger.i('Selected trip IDs: $_selectedMapIndices');
    });
  }

  void _onSelectButtonPressed() {
    setState(() {
      _isSelectMode = !_isSelectMode;
      _selectedMapIndices.clear();
    });
  }

  void _onDeleteButtonPressed() async {
    final apiService = ApiService();
    bool allDeletedSuccessfully = true;
    _showLoadingDialog();
    for (int tripId in _selectedMapIndices) {
      try {
        final result = await apiService.deleteTrip(tripId);

        if (result['statusCode'] != true) {
          allDeletedSuccessfully = false; 
          logger.e('Failed to delete trip with ID: $tripId');
          break; 
        }
      } catch (e) {
        allDeletedSuccessfully = false; 
        logger.e('Error deleting trip with ID: $tripId. $e');
        break;
      }
    }
    _hideLoadingDialog();

    if (allDeletedSuccessfully) {
      setState(() {
        _isSelectMode = !_isSelectMode;
        _selectedMapIndices.clear();
      });

      if(!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfileScreen()),
      );
    }
  }


  void _onFollowers() {
    Navigator.push(context,
        MaterialPageRoute(
          builder: (context) => 
          HomeFollowScreen(userid: GlobalVariables.userId!, fromUser: "You",)));
  }

  void _onFollowing() {
    Navigator.push(context,
        MaterialPageRoute(
          builder: (context) => 
          ProfileFollowingScreen(userid: GlobalVariables.userId!)));
  }

  void _onSettingButtonClicked() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const SettingsScreen()));
  }

  void _onEditButtonClicked() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return const EditProfileScreen();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0); 
          const end = Offset.zero; 
          const curve = Curves.easeInOut;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          const reverseBegin = Offset(-1.0, 0.0); 
          const reverseEnd = Offset.zero; 
          var reverseTween = Tween(begin: reverseBegin, end: reverseEnd).chain(CurveTween(curve: curve));
          secondaryAnimation.drive(reverseTween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300), 
        reverseTransitionDuration: const Duration(milliseconds: 300),
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
                            fontFamily: 'inter',
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.black),
                          onPressed: () {
                            Navigator.of(context).pop();
                            setState(() {
                              showLikesDropdown =false;
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
    return Scaffold(
      backgroundColor: kColorWhite,
      body: SafeArea(
        child: isLoadingTrips
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Container(
                  decoration: const BoxDecoration(
                    color: kColorWhite,
                  ),
                  padding: EdgeInsets.symmetric(horizontal: vww(context, 4)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          // === Trips - Avatar - Followers Row ===
                          Padding(
                            padding: EdgeInsets.only(top: vhh(context, 7.5)), 
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(),
                                Column(
                                  children: [
                                    Image.asset(
                                      'assets/images/icons/trips1.png',
                                      width: vww(context, 20),
                                    ),
                                    Text(
                                      GlobalVariables.tripCount?.toString() ?? "0",
                                      style: const TextStyle(
                                          fontSize: 20,
                                          color: kColorButtonPrimary,
                                          fontFamily: 'interBold'),
                                    ),
                                  ],
                                ),
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
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
                                      child: ClipOval(
                                        child: GlobalVariables.userImageUrl != null
                                            ? Image.network(
                                                GlobalVariables.userImageUrl!,
                                                fit: BoxFit.cover,
                                                height: vhh(context, 15),
                                                width: vhh(context, 15),
                                                loadingBuilder: (context, child, loadingProgress) {
                                                  if (loadingProgress == null) return child;
                                                  return Center(
                                                    child: CircularProgressIndicator(
                                                      value: loadingProgress.expectedTotalBytes != null
                                                          ? loadingProgress.cumulativeBytesLoaded /
                                                              (loadingProgress.expectedTotalBytes ?? 1)
                                                          : null,
                                                      strokeWidth: 2,
                                                    ),
                                                  );
                                                },
                                                errorBuilder: (context, error, stackTrace) {
                                                  return Container(
                                                    height: vhh(context, 15),
                                                    width: vhh(context, 15),
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Colors.grey[300],
                                                    ),
                                                    child: Icon(Icons.person, color: Colors.grey[600]),
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
                                                child: Icon(Icons.person, color: Colors.grey[600]),
                                              ),
                                      ),
                                    ),
                                    
                                  ],
                                ),
                                Column(
                                  children: [
                                    Image.asset(
                                      'assets/images/icons/follower1.png',
                                      width: vww(context, 21),
                                    ),
                                    GestureDetector(
                                      onTap: _onFollowers,
                                      child: Text(
                                        followingCount ?? "0",
                                        style: const TextStyle(
                                            fontSize: 20,
                                            color: kColorButtonPrimary,
                                            fontFamily: 'interBold'),
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
                            top: vhh(context, 0.3), 
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Image.asset(
                                  'assets/images/icons/logo.png',
                                  width: vww(context, 20),
                                ),
                                const Spacer(),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      "@$username!",
                                      style: const TextStyle(
                                        color: kColorBlack,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'inter',
                                        letterSpacing: -0.1,
                                      ),
                                    ),
                                    const SizedBox(width : 3),
                                    Image.asset(
                                      'assets/images/icons/verify.png',
                                      width: 22,
                                      height: 22,
                                      fit: BoxFit.contain,
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                Row(
                                children: [
                                  if (_isSelectMode)
                                    SizedBox(
                                      height: 30,
                                      child: ElevatedButton(
                                        onPressed: _onDeleteButtonPressed,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: kColorStafGrey,
                                          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
                                        ),
                                        child: const Text(
                                          "Delete",
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'inter',),
                                        ),
                                      ),
                                    ),
                                  if (_isSelectMode)
                                    const SizedBox(width: 3,),
                                  SizedBox(
                                    height: 30, 
                                    child: ElevatedButton(
                                      onPressed: _onSelectButtonPressed,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: kColorStafGrey,
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                      ),
                                      child: Text(
                                        _isSelectMode ? 'Cancel' : 'Select',
                                        style: const TextStyle(
                                          color: Colors.black54,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          fontFamily: 'inter',),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: vhh(context, 1)),
                      Text(
                        GlobalVariables.realName!,
                        style: const TextStyle(
                            color: kColorBlack,
                            fontSize: 17,
                            letterSpacing: -0.1,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'inter'),
                      ),
                      SizedBox(height: vhh(context, 0.5)),
                      Text(
                        GlobalVariables.bio != null
                            ? GlobalVariables.bio!
                            : " ",
                        style: const TextStyle(
                            color: kColorGrey,
                            fontSize: 15,
                            letterSpacing: -0.1,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'inter'),
                      ),
                      SizedBox(height: vhh(context, 2)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: vww(context, 29),
                            height: 23,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    kColorStrongBlue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      30),
                                ),
                                shadowColor:
                                    Colors.black
                                        .withValues(alpha: 0.9),
                                elevation: 3,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 2, vertical: 2),
                              ),
                              onPressed: () {
                                _onEditButtonClicked();
                              },
                              child: Text("Edit Profile",
                                  style: TextStyle(
                                      color: kColorWhite,
                                      fontSize: 36.sp,
                                      letterSpacing: -0.1,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'inter')),
                            ),
                          ),
                          SizedBox(
                            width: vww(context, 29),
                            height: 23,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kColorStrongBlue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                shadowColor:
                                    Colors.black.withValues(alpha: 0.9),
                                elevation: 3,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 2, vertical: 2),
                              ),
                              onPressed: () {
                                _onFollowing();
                              },
                              child: Text("Following",
                                  style: TextStyle(
                                      color: kColorWhite,
                                      fontSize: 36.sp,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: -0.1,
                                      fontFamily: 'inter')),
                            ),
                          ),
                          SizedBox(
                            width: vww(context, 29),
                            height: 23,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    kColorStrongBlue, 
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      30),
                                ),
                                shadowColor:
                                    Colors.black
                                        .withValues(alpha: 0.9),
                                elevation: 3,
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
                                        color:kColorWhite,
                                        fontSize: 36.sp,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: -0.1,
                                        fontFamily:
                                            'inter' // Customize font size
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
                                happy_place,
                                style: TextStyle(
                                    color: kColorBlack,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: -0.1,
                                    fontFamily: 'inter'),
                              ),
                              Text(
                                GlobalVariables.happyPlace != null
                                    ? GlobalVariables.happyPlace!
                                    : " ",
                                style: const TextStyle(
                                    color: kColorButtonPrimary,
                                    fontSize: 14,
                                    letterSpacing: -0.1,
                                    fontFamily: 'inter'),
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
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: -0.1,
                                    fontFamily: 'inter'),
                              ),
                              garageImageUrl != null
                                  ? Image.network(
                                      garageImageUrl!,
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
                                        horizontal: 1),
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

                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        color: kColorWhite,
                        child: Column(
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10.0),
                              child: Divider(
                                height: 1,
                                thickness: 2,
                                color: kColorHereButton,
                              ),
                            ),
                            SizedBox(height: vhh(context, 1)),
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
                                                    width: MediaQuery.of(context).size.width * 0.4,
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
                                                      isSelectMode: _isSelectMode,
                                                      selectedMapIndices: _selectedMapIndices, 
                                                      onSelectTrip: _onSelectTrip, 
                                                      onDeleteButtonPressed: _onDeleteButtonPressed,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12,),
                                                  if (rowIndex * 2 + 1 <
                                                      userTrips!.length)
                                                    Container(
                                                      width: MediaQuery.of(context).size.width * 0.4,
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
                                                        isSelectMode: _isSelectMode,
                                                        selectedMapIndices: _selectedMapIndices,
                                                        onSelectTrip: _onSelectTrip,
                                                        onDeleteButtonPressed: _onDeleteButtonPressed,
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
                                                    // SizedBox(height: vhh(context, 1)),
                                                    // const Padding(
                                                    //   padding: EdgeInsets.symmetric(horizontal: 16),
                                                    //   child: Divider(
                                                    //     height: 1,
                                                    //     thickness: 1,
                                                    //     color: Colors.grey,
                                                    //   ),
                                                    // ),
                                                    SizedBox(height: vhh(context, 1)),
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
