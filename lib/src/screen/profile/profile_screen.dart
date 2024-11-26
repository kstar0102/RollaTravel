import 'package:RollaTravel/src/constants/app_button.dart';
import 'package:RollaTravel/src/constants/app_styles.dart';
import 'package:RollaTravel/src/screen/home/home_follower_screen.dart';
import 'package:RollaTravel/src/screen/profile/edit_profile.dart';
import 'package:RollaTravel/src/screen/settings/settings_screen.dart';
import 'package:RollaTravel/src/translate/en.dart';
import 'package:RollaTravel/src/utils/global_variable.dart';
import 'package:RollaTravel/src/utils/index.dart';
import 'package:RollaTravel/src/widget/bottombar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => ProfileScreenState();
}

class ProfileScreenState extends ConsumerState<ProfileScreen> {
  double screenHeight = 0;
  double keyboardHeight = 0;
  final int _currentIndex = 4;
  // final bool _isKeyboardVisible = false;
  bool isLiked = false;
  bool showLikesDropdown = false;
  String? followingCount;

  final logger = Logger();

  final List<Map<String, String>> commentsList = [
    {"user": "@User13", "comment": "Example 1 Great place!"},
    {"user": "@User23", "comment": "Example 2 Looks amazing!"},
    {"user": "@User13", "comment": "Example 3 I want to visit!"},
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
    if (GlobalVariables.followingIds != null && GlobalVariables.followingIds!.isNotEmpty) {
      int count = GlobalVariables.followingIds!.split(',').length;
      followingCount = count.toString();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    return false;
  }

  void _onFollowers(){
    Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeFollowScreen()));
  }

  // void _showImageDialog(String imagePath, String caption, int likes) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return StatefulBuilder(
  //         builder: (BuildContext context, StateSetter setState) {
  //           return Dialog(
  //             insetPadding: const EdgeInsets.symmetric(horizontal: 30), // Adjust padding to match the screenshot
  //             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  //             child: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 // Caption and Close Icon Row
  //                 Padding(
  //                   padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
  //                   child: Row(
  //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                     children: [
  //                       Text(
  //                         caption,
  //                         style: const TextStyle(
  //                           fontSize: 16,
  //                           fontWeight: FontWeight.bold,
  //                           color: Colors.grey,
  //                           fontFamily: 'Kadaw'
  //                         ),
  //                       ),
  //                       IconButton(
  //                         icon: const Icon(Icons.close, color: Colors.black),
  //                         onPressed: () {
  //                           Navigator.of(context).pop();
  //                           setState(() {
  //                             showLikesDropdown = false; // Hide the likes dropdown when the dialog is closed
  //                           });
  //                         }
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //                 // Image
  //                 Image.network(
  //                   imagePath,
  //                   fit: BoxFit.cover,
  //                   width: MediaQuery.of(context).size.width * 0.9, // Replace vww
  //                   height: MediaQuery.of(context).size.height * 0.5, // Replace vhh
  //                 ),
  //                 const Divider(height: 1, color: Colors.grey), // Divider between image and footer
  //                 // Footer with Like Icon and Likes Count
  //                 Padding(
  //                   padding: const EdgeInsets.all(8.0),
  //                   child: Row(
  //                     children: [
  //                       GestureDetector(
  //                         behavior: HitTestBehavior.opaque,
  //                         onTap: () {
  //                           // Update dialog state
  //                           setState(() {
  //                             isLiked = !isLiked;
  //                           });
  //                         },
  //                         child: Icon(
  //                           isLiked ? Icons.favorite : Icons.favorite_border,
  //                           color: isLiked ? Colors.red : Colors.black,
  //                         ),
  //                       ),
  //                       const SizedBox(width: 4),
  //                       GestureDetector(
  //                         onTap: () {
  //                           setState(() {
  //                             showLikesDropdown = !showLikesDropdown; // Toggle the visibility of the dropdown
  //                           });
  //                         },
  //                         child: Text(
  //                           '$likes likes',
  //                           style: const TextStyle(
  //                             fontWeight: FontWeight.bold,
  //                             fontSize: 16,
  //                             fontFamily: 'Kadaw'
  //                           ),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //                 if (showLikesDropdown)
  //                   Column(
  //                     children: commentsList.map((comment) {
  //                       return Padding(
  //                         padding: const EdgeInsets.symmetric(vertical: 4.0),
  //                         child: Row(
  //                           children: [
  //                             Container(
  //                               height: vhh(context, 4),
  //                               width: vhh(context, 4),
  //                               decoration: BoxDecoration(
  //                                 borderRadius: BorderRadius.circular(100),
  //                                 border: Border.all(
  //                                   color: kColorHereButton,
  //                                   width: 2,
  //                                 ),
  //                                 image: const DecorationImage(
  //                                   image: AssetImage("assets/images/background/image1.png"),
  //                                   fit: BoxFit.cover,
  //                                 ),
  //                               ),
  //                             ),
  //                             const SizedBox(width: 5),
  //                             Column(
  //                               children: [
  //                                 Row(
  //                                   children: [
  //                                     Text(
  //                                       comment['user']!,
  //                                       style: const TextStyle(
  //                                         fontWeight: FontWeight.bold, 
  //                                         color: kColorHereButton,
  //                                         fontSize: 13,
  //                                         fontFamily: 'Kadaw'
  //                                       ),
  //                                     ),
  //                                     const SizedBox(width: 5),
  //                                     const Icon(Icons.verified, color: Colors.blue, size: 16),
  //                                   ],
  //                                 ),
  //                                 const Text("Brain Smith", style: TextStyle(fontFamily: 'Kadaw'),)
  //                               ],
  //                             ),
                              
  //                           ],
  //                         ),
  //                       );
  //                     }).toList(),
  //                   ),
  //               ],
  //             ),
  //           );
  //         },
  //       );
  //     },
  //   );
  // }

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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
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
                    padding: EdgeInsets.symmetric(horizontal: vww(context, 4)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(height: vhh(context, 5)),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Image.asset(
                              'assets/images/icons/logo.png',
                              width: vww(context, 20),
                            ),
                            SizedBox(width: vww(context, 20)),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  GlobalVariables.userName!,
                                  style: const TextStyle(
                                      color: kColorBlack, fontSize: 18, fontFamily: 'KadawBold'),
                                ),
                                Image.asset(
                                  'assets/images/icons/verify.png',
                                  width: vww(context, 10),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: vhh(context, 1)),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Container(),
                            Column(
                              children: [
                                Image.asset(
                                  'assets/images/icons/trips.png',
                                  width: vww(context, 15),
                                ),
                                Text(
                                  GlobalVariables.tripCount != null ? GlobalVariables.tripCount!.toString() : "0",
                                  style: const TextStyle(
                                      fontSize: 20,
                                      color: kColorButtonPrimary,
                                      fontFamily: 'KadawBold'),
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
                                image: GlobalVariables.userImageUrl != null ?  
                                  DecorationImage(
                                    image: NetworkImage(GlobalVariables.userImageUrl!), // Use NetworkImage for URL
                                    fit: BoxFit.cover,
                                  ) : null
                              ),
                            ),
                            Column(
                              children: [
                                Image.asset(
                                  'assets/images/icons/followers.png',
                                  width: vww(context, 15),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    _onFollowers();
                                  },
                                  child: Text(
                                    followingCount != null ? followingCount! : "0",
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
                              fontFamily: 'KadawBold'),
                        ),
                        SizedBox(height: vhh(context, 1)),
                        
                        Text(
                          GlobalVariables.bio != null ? GlobalVariables.bio! : " ",
                          style: const TextStyle(
                            color: kColorGrey,
                            fontSize: 18,
                            fontFamily: 'Kadaw'
                          ),
                        ),
                        SizedBox(height: vhh(context, 2)),
                        Row(
                          children: [
                            SizedBox(
                              width: vww(context, 30),
                              child: ButtonWidget(
                                btnType: ButtonWidgetType.editProfileText,
                                borderColor: kColorStrongGrey,
                                textColor: kColorWhite,
                                fullColor: kColorStrongGrey,
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(
                                    builder: (context) => const EditProfileScreen(),
                                  ));
                                },
                              ),
                            ),
                            SizedBox(width: vww(context, 1)),
                            SizedBox(
                              width: vww(context, 30),
                              child: ButtonWidget(
                                btnType: ButtonWidgetType.followingText,
                                borderColor: kColorStrongGrey,
                                textColor: kColorWhite,
                                fullColor: kColorStrongGrey,
                                onPressed: () {
                                  _onFollowers();
                                },
                              ),
                            ),
                            SizedBox(width: vww(context, 1)),
                            SizedBox(
                              width: vww(context, 30),
                              child: ButtonWidget(
                                btnType: ButtonWidgetType.settingText,
                                borderColor: kColorStrongGrey,
                                textColor: kColorWhite,
                                fullColor: kColorStrongGrey,
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(
                                    builder: (context) => const SettingsScreen(),
                                  ));
                                },
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
                                    fontFamily: 'Kadaw'
                                  ),
                                ),
                                Text(
                                  GlobalVariables.odometer != null
                                    ? '${GlobalVariables.odometer!} Km'
                                    : ' ', 
                                  style: const TextStyle(
                                    color: kColorButtonPrimary,
                                    fontSize: 14,
                                    fontFamily: 'Kadaw'
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
                                    fontFamily: 'Kadaw'
                                  ),
                                ),
                                Text(
                                  GlobalVariables.happyPlace != null ? GlobalVariables.happyPlace! : " ",
                                  style: const TextStyle(
                                    color: kColorButtonPrimary,
                                    fontSize: 14,
                                    fontFamily: 'Kadaw'
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
                                    fontFamily: 'Kadaw'
                                  ),
                                ),
                                Text(
                                  GlobalVariables.garage != null ? GlobalVariables.garage! : " ",
                                  style: const TextStyle(
                                    color: kColorButtonPrimary,
                                    fontSize: 14,
                                    fontFamily: 'Kadaw'
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: vhh(context, 1)),
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: GlobalVariables.dropPinsData?.length ?? 0,
                            itemBuilder: (context, index) {
                              final dropPin = GlobalVariables.dropPinsData![index] as Map<String, dynamic>;

                              final String imagePath = dropPin['image_path'] ?? '';
                              final String caption = dropPin['image_caption'] ?? 'No caption';
                              final List<dynamic> likedUsers = dropPin['liked_users'] ?? [];
 
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 3),
                                child: GestureDetector(
                                  onTap: () {
                                    // Handle the click event
                                    _showImageDialog(imagePath, caption, dropPin['liked_users'].length, likedUsers);
                                  },
                                  child: imagePath.isNotEmpty
                                      ? Container(
                                          width: 100,
                                          height: 100,
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: NetworkImage(imagePath),
                                              fit: BoxFit.cover,
                                            ),
                                            borderRadius: BorderRadius.circular(8),
                                            gradient: LinearGradient(
                                              colors: [Colors.black.withOpacity(0.5), Colors.transparent],
                                              begin: Alignment.bottomCenter,
                                              end: Alignment.topCenter,
                                            ),
                                          ),
                                        )
                                      : const Icon(Icons.image_not_supported, size: 100), // Placeholder if imagePath is empty
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: vhh(context, 1)),
                        
                        // Map and Route Section with Dividers
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Column(
                            children: [
                              // Map Image Placeholder
                              Container(
                                height: 150,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                ),
                                child: const Center(
                                  child: Text(
                                    "Map Route Here",
                                    style: TextStyle(color: Colors.black, fontFamily: 'Kadaw'),
                                  ),
                                ),
                              ),
                              SizedBox(height: vhh(context, 1)),
                              
                              // Dividers and Sections
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Left Divider
                                  Expanded(
                                    child: Divider(
                                      color: Colors.grey,
                                      thickness: 1,
                                      indent: 20,
                                      endIndent: 10,
                                    ),
                                  ),
                                  
                                  // Center Vertical Divider
                                  Column(
                                    children: [
                                      VerticalDivider(
                                        color: Colors.grey,
                                        thickness: 1,
                                        width: 20,
                                      ),
                                      SizedBox(height: 10),
                                      VerticalDivider(
                                        color: Colors.grey,
                                        thickness: 1,
                                        width: 20,
                                      ),
                                    ],
                                  ),
                                  
                                  // Right Divider
                                  Expanded(
                                    child: Divider(
                                      color: Colors.grey,
                                      thickness: 1,
                                      indent: 10,
                                      endIndent: 20,
                                    ),
                                  ),
                                ],
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
