import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:RollaTravel/src/utils/index.dart';
import 'package:RollaTravel/src/constants/app_styles.dart';
import 'package:RollaTravel/src/widget/bottombar.dart';
import 'package:logger/logger.dart';
import 'package:RollaTravel/src/services/api_service.dart';

class HomeTagScreen extends ConsumerStatefulWidget {
  final String? taglist;
  const HomeTagScreen({super.key, required this.taglist});

  @override
  ConsumerState<HomeTagScreen> createState() => HomeTagScreenState();
}

class HomeTagScreenState extends ConsumerState<HomeTagScreen> {
  final int _currentIndex = 0;
  final logger = Logger();
  List<dynamic> taggedUsers = []; // Store the fetched user data
  bool isLoading = true; // Track loading state

  @override
  void initState() {
    super.initState();
    logger.i(widget.taglist);
    fetchTaggedUsers();
  }

  Future<void> fetchTaggedUsers() async {
    if (widget.taglist != null) {
      // Convert the string to a list of integers
      List<int> tagIds = widget.taglist!.split(',').map((id) => int.parse(id)).toList();
      
      // Loop through each ID and fetch the user info
      for (int id in tagIds) {
        try {
          final userData = await ApiService().fetchUserInfo(id);
          logger.i('Fetched user info for ID $id: $userData');  // Debug log
          setState(() {
              taggedUsers.add(userData);
            });
          // if (userData != null && userData['statusCode'] == true && userData['data'] != null) {
          //   setState(() {
          //     taggedUsers.add(userData['data']);
          //   });
          // } else {
          //   logger.e('Failed to fetch user info for ID $id: ${userData?['message'] ?? 'Unknown error'}');
          // }
        } catch (e) {
          logger.e('Error fetching user info for ID $id: $e');
        }
      }
    }
    setState(() {
      isLoading = false; // Stop loading after fetching data
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          return;
        }
      },
      child: Scaffold(
        backgroundColor: kColorWhite,
        body: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset('assets/images/icons/logo.png',
                        height: vhh(context, 12)),
                    Center(
                      child: Column(
                        children: [
                          SizedBox(height: vhh(context, 5)),
                          const Text(
                            "Users tagged in this post",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 15,
                              fontFamily: 'inter',
                            ),
                          ),
                          Image.asset("assets/images/icons/add_car.png",
                              width: vww(context, 8)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 30),
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the screen
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: vww(context, 80), // Set the width of the Divider
                child: const Divider(
                  thickness: 0.6, // Set the thickness of the line
                  color: Colors.grey, // Optional: Set the color of the Divider
                ),
              ),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator()) // Show loading while fetching data
                    : taggedUsers.isEmpty
                        ? const Center(child: Text('No users found.')) // Show message if no users are found
                        : ListView.builder(
                            itemCount: taggedUsers.length,
                            itemBuilder: (context, index) {
                              final user = taggedUsers[index];
                              final fullName = '${user['first_name']} ${user['last_name']}';
                              final userImageUrl = user['photo'];
                              final rollaUsername = user['rolla_username'];

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 4.0, horizontal: 20),
                                child: Row(
                                  children: [
                                    Container(
                                      height: vhh(context, 6),
                                      width: vhh(context, 6),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(100),
                                        border: Border.all(
                                          color: kColorHereButton,
                                          width: 2,
                                        ),
                                        image: DecorationImage(
                                          image: NetworkImage(userImageUrl ?? ""),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              "@$rollaUsername",
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontFamily: 'interBold',
                                              ),
                                            ),
                                            const SizedBox(width: 5),
                                            const Icon(Icons.verified,
                                                color: Colors.blue, size: 16),
                                          ],
                                        ),
                                        Text(
                                          fullName,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            color: Colors.grey,
                                            fontFamily: 'inter',
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    Image.asset("assets/images/icons/reference.png"),
                                  ],
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavBar(currentIndex: _currentIndex),
      ),
    );
  }
}

