import 'dart:convert';

import 'package:RollaTravel/src/constants/app_styles.dart';
import 'package:RollaTravel/src/screen/home/home_screen.dart';
import 'package:RollaTravel/src/screen/trip/start_trip.dart';
import 'package:RollaTravel/src/services/api_service.dart';
import 'package:RollaTravel/src/utils/global_variable.dart';
import 'package:RollaTravel/src/utils/spinner_loader.dart';
import 'package:RollaTravel/src/widget/bottombar.dart';
import 'package:flutter/material.dart';
import 'package:RollaTravel/src/utils/index.dart';

class TripTagSearchScreen extends StatefulWidget {
  const TripTagSearchScreen({super.key});

  @override
  TripTagSettingScreenState createState() => TripTagSettingScreenState();
}

class TripTagSettingScreenState extends State<TripTagSearchScreen> {
  bool isLoading = false;
  final TextEditingController _searchTagController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<dynamic> allUserData = [];
  List<dynamic> filteredUserData = [];
  final int _currentIndex = 2;
  List<int> selectedUserIds = [];

  @override
  void initState() {
    super.initState();
    _searchTagController.addListener(_filterResults);
    selectedUserIds = List<int>.from(GlobalVariables.selectedUserIds);
    getAllUserData();
  }

  @override
  void dispose() {
    _searchTagController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }


  Future<void> getAllUserData() async {
    setState(() => isLoading = true);
    final authService = ApiService();

    try {
      final userresponse = await authService.fetchUserInfo(GlobalVariables.userId!);
      final response = await authService.fetchAllUserData();
      
      if (response.containsKey("status") && response.containsKey("data")) {
        setState(() {
          allUserData = response["data"];

          // Decode the lists of following and followed user IDs
          List<dynamic> followingUsers = List.from(jsonDecode(userresponse?['following_user_id']));
          List<dynamic> followedUsers = List.from(jsonDecode(userresponse?['followed_user_id']));

          // Combine both lists and remove duplicates
          Set<int> uniqueUserIds = <int>{};

          // Add ids from following users
          for (var user in followingUsers) {
            uniqueUserIds.add(user['id']);
          }

          // Add ids from followed users
          for (var user in followedUsers) {
            uniqueUserIds.add(user['id']);
          }

          // Log the unique user IDs
          // logger.i("uniqueUserIds: $uniqueUserIds");

          // Filter the users by checking if their ID is in the uniqueUserIds set
          filteredUserData = allUserData
              .where((user) => uniqueUserIds.contains(user['id']) && user['id'] != GlobalVariables.userId)
              .toList();

          isLoading = false;
        });
      } else {
        logger.e("Failed to fetch user data.");
        setState(() => isLoading = false);
      }
    } catch (e) {
      logger.e("Error fetching user data: $e");
      setState(() => isLoading = false);
    }
  }


  void _filterResults() {
    String query = _searchTagController.text.toLowerCase();
    setState(() {
      filteredUserData = allUserData
          .where((user) {
            final fullName = '${user['first_name']} ${user['last_name']}';
            final email = user['email'] ?? '';
            return (fullName.toLowerCase().contains(query) ||
                email.toLowerCase().contains(query)) &&
                user['id'] != GlobalVariables.userId;
          })
          .toList();
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            return;
          }
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40), // Spacing from the top
              Row(
                children: [
                  const SizedBox(width: 20),
                  InkWell(
                    onTap: () {
                      GlobalVariables.selectedUserIds = selectedUserIds;
                      Navigator.push(context,
                        MaterialPageRoute(builder: (context) => const StartTripScreen()));
                    },
                    child: Image.asset(
                      'assets/images/icons/allow-left.png',
                      width: vww(context, 5),
                      height: 20,
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Tag Rolla users',
                        style: TextStyle(
                          fontSize: 21,
                          fontFamily: 'inter',
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.1
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Image.asset(
                    'assets/images/icons/add_car1.png',
                    width: vww(context, 8),
                  ),
                  const SizedBox(
                    width: 30,
                  )
                ],
              ),

              Row(
                children: [
                  const SizedBox(
                    width: 20,
                  ),
                  const Icon(Icons.search, size: 24, color: Colors.black),
                  const SizedBox(
                    width: 5,
                  ),
                  SizedBox(
                    height: 30,
                    width: vww(context, 80),
                    child: TextField(
                      controller: _searchTagController,
                      focusNode: _searchFocusNode, 
                      decoration: InputDecoration(
                        hintText:
                            'Search Rolla users and add them to your trip',
                        hintStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.1,
                          fontFamily: 'inter',
                        ), // Set font size for hint text
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 5.0,
                            horizontal: 5.0), // Set inner padding
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4.0),
                          borderSide:
                              const BorderSide(color: Colors.black, width: 1.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4.0),
                          borderSide:
                              const BorderSide(color: Colors.black, width: 1.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4.0),
                          borderSide:
                              const BorderSide(color: Colors.black, width: 1.0),
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.1,
                        fontFamily: 'inter',
                      ),
                      textInputAction: TextInputAction.done,
                      onEditingComplete: () {
                        _searchFocusNode.unfocus();
                      },
                    ),
                  ),
                ],
              ),
              isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(20),
                        child: SpinningLoader(),
                      )
                    : Expanded(
                      child: _buildUserList(),
                      ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: _currentIndex),
    );
  }

  Widget _buildUserList() {
    return ListView.builder(
      itemCount: filteredUserData.length,
      itemBuilder: (context, index) {
        final user = filteredUserData[index];
        final fullName = '${user['first_name']} ${user['last_name']}';
        final userImageUrl = user['photo'];
        final userid = user['id'];
        final rollaUsername = user['rolla_username'];

        // Check if the current user is selected (pre-select checkboxes)
        bool isSelected = selectedUserIds.contains(userid);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 20.0),
          child: GestureDetector(
            onTap: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //       builder: (context) => HomeUserScreen(
              //             userId: userid,
              //           )),
              // );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: kColorGrey, width: 0.6),
              ),
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: userImageUrl != null && userImageUrl.isNotEmpty
                        ? Image.network(
                            userImageUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.broken_image,
                                    size: 60, color: Colors.grey),
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              } else {
                                return const SizedBox(
                                  width: 60,
                                  height: 60,
                                  child: Center(
                                    child: SpinningLoader(),
                                  ),
                                );
                              }
                            },
                          )
                        : const Icon(Icons.person,
                            size: 60, color: Colors.grey),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          fullName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.1,
                            fontFamily: 'inter',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "@$rollaUsername",
                          style: const TextStyle(
                            fontSize: 14,
                            letterSpacing: -0.1,
                            fontFamily: 'inter',
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Custom checkbox to select/deselect the user
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          selectedUserIds.remove(userid); // Deselect the user ID
                        } else {
                          selectedUserIds.add(userid); // Select the user ID
                        }
                      });
                    },
                    child: Container(
                      width: 24,  // Size of the checkbox
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,  // Round shape
                        color: isSelected ? kColorHereButton : Colors.grey[300],  // Background color
                        border: Border.all(
                          color: isSelected ? kColorHereButton : Colors.grey,  // Border color
                          width: 2,  // Border width
                        ),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white, size: 15)  // Check mark when selected
                          : null,  // Empty when not selected
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


}
