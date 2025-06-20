import 'dart:convert';

import 'package:RollaTravel/src/screen/home/home_screen_widget.dart';
import 'package:RollaTravel/src/screen/home/pending_screen.dart';
import 'package:RollaTravel/src/services/api_service.dart';
import 'package:RollaTravel/src/utils/global_variable.dart';
import 'package:RollaTravel/src/utils/spinner_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:RollaTravel/src/constants/app_styles.dart';
import 'package:RollaTravel/src/utils/index.dart';
import 'package:RollaTravel/src/widget/bottombar.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends ConsumerState<HomeScreen> with WidgetsBindingObserver {
  double screenHeight = 0;
  final int _currentIndex = 0;
  List<Map<String, dynamic>>? trips;
  final apiService = ApiService();
  final ScrollController _scrollController = ScrollController();
  bool isSelected = false;
  int totalCount = 0;
  List<int> pendingList = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _followedTrips();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() {});
    }
  }

  Future<void> _followedTrips() async {
  try {
    final blockUsers = await apiService.fetchBlockUsers(GlobalVariables.userId!);
    final blockedUserIds = blockUsers.isEmpty
        ? <String>{}
        : blockUsers.map((user) => user['id'].toString()).toSet();

    final data = await apiService.fetchFollowerTrip(GlobalVariables.userId!);
    logger.i(data);

    // Find the first trip data where the user_id matches GlobalVariables.userId
    final userTripData = data.firstWhere(
      (trip) => trip['user']['id'] == GlobalVariables.userId,
      orElse: () => {}, // If no trip data is found, return an empty map (safe fallback)
    );

    if (userTripData.isNotEmpty) {
      logger.i(userTripData);
      final pendingIdsRaw = userTripData['user']['following_pending_userid'];
      final acceptedRow = userTripData['user']['following_user_id'];
      final tagNotificationRaw = userTripData['user']['tag_notification'];
      final commentNotificationRaw = userTripData['user']['comment_notification'];
      final likenotificationRaw = userTripData['user']['like_notification'];

      int pendingCount = 0;
      int acceptedCount = 0;
      int tagNotificationCount = 0; 
      int commentNotificationCount = 0;
      int likeNotificationCount = 0; 

      // Process pending follow requests
      if (pendingIdsRaw != null && pendingIdsRaw.toString().trim().isNotEmpty) {
        List<dynamic> pendingData = jsonDecode(pendingIdsRaw);
        pendingList = pendingData
            .map((e) => e['id'] as int?)
            .whereType<int>()
            .toList();
        pendingCount = pendingData.length;
      }

      // Process accepted follow requests
      if (acceptedRow != null && acceptedRow.toString().trim().isNotEmpty) {
        List<dynamic> acceptedData = jsonDecode(acceptedRow);
        acceptedCount = acceptedData
            .where((item) => item['notificationBool'] == false)
            .length;
      }

      // Process tag notifications where notificationBool is false
      if (commentNotificationRaw != null && commentNotificationRaw.toString().trim().isNotEmpty) {
        List<dynamic> commentNotificationRawData = jsonDecode(commentNotificationRaw);
        commentNotificationCount = commentNotificationRawData
            .where((item) => item['notificationBool'] == false)
            .length;
      }

      if (likenotificationRaw != null && likenotificationRaw.toString().trim().isNotEmpty) {
        List<dynamic> likenotificationRawData = jsonDecode(likenotificationRaw);
        likeNotificationCount = likenotificationRawData
            .where((item) => item['notificationBool'] == false)
            .length;
      }

      if (tagNotificationRaw != null && tagNotificationRaw.toString().trim().isNotEmpty) {
        List<dynamic> tagNotificationData = jsonDecode(tagNotificationRaw);
        tagNotificationCount = tagNotificationData
            .where((item) => item['notificationBool'] == false)
            .length;
      }

      // Calculate total count
      totalCount = pendingCount + acceptedCount + tagNotificationCount + commentNotificationCount + likeNotificationCount;

    } else {
      logger.w("No trip data found for user_id: ${GlobalVariables.userId}");
    }



    final currentUserId = GlobalVariables.userId.toString();
    final now = DateTime.now();

    final filteredTrips = data.where((trip) {
      final user = trip['user'];
      final userId = user['id'].toString();
      if (blockedUserIds.contains(userId)) return false;

      final mutedIds = trip['muted_ids']?.split(',') ?? [];
      if (mutedIds.contains(currentUserId)) return false;

      // ✅ Keep only if at least one droppin is visible now
      final droppins = trip['droppins'] as List<dynamic>? ?? [];
      final hasVisibleDroppin = droppins.any((droppin) {
        final delayTimeStr = droppin['deley_time'];
        if (delayTimeStr == null || delayTimeStr.isEmpty) {
          return true;
        }
        final delayTime = DateTime.tryParse(delayTimeStr);
        return delayTime == null || !delayTime.isAfter(now);
      });

      return hasVisibleDroppin;
    }).toList();

    setState(() {
      trips = filteredTrips.reversed.toList();
    });
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
          index * 520.0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {
            GlobalVariables.homeTripID = null;
          });
        });
      }
    }
  }

  void follwingUser() async {
    List<int> followedUserIds = [];
    final apiService = ApiService();
    final List<Map<String, dynamic>> users =
        await apiService.fetchFollowedUsers(GlobalVariables.userId!);

    setState(() {
      followedUserIds = users
          .map((user) => user['id'])
          .where((id) => id != null)
          .map<int>((id) => int.parse(id.toString()))
          .toList();

      isSelected = !isSelected;
    });
    logger.i(followedUserIds);
  }

  @override
  Widget build(BuildContext context) {
    final isSpecificTrip = GlobalVariables.homeTripID != null;
    final filteredTrips = trips != null && isSpecificTrip
        ? trips!
            .where((trip) => trip['id'] == GlobalVariables.homeTripID)
            .toList()
        : trips;

    if (isSpecificTrip && filteredTrips != null && filteredTrips.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          GlobalVariables.homeTripID = null;
        });
      });
    }
    return Scaffold(
      backgroundColor: kColorWhite,
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            return;
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: vhh(context, 5)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    'assets/images/icons/logo.png',
                    width: 90,
                    height: 80,
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      if (totalCount != 0) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => NotificationScreen(userid: GlobalVariables.userId,)), // replace with your page
                        );
                      }
                    },
                    child: SizedBox(
                      width: vww(context, 4) + 12,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Image.asset(
                            'assets/images/icons/notification.png',
                            width: vww(context, 4),
                          ),
                          if (totalCount > 0)
                            Positioned(
                              top: -4,
                              left: -20,
                              child: Container(
                                width: 25,
                                height: 16,
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  totalCount > 99 ? '99+' : '$totalCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    iconSize: 47.0,
                    onPressed: () {},
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
                child: Divider(),
              ),
              trips == null
                  ? const Expanded(
                      child: Center(child: SpinningLoader()),
                    )
                  : trips!.isEmpty
                      ? const Center(child: Text('No trips available'))
                      : Expanded(
                          child: ListView.builder(
                            controller: _scrollController,
                            itemCount: trips!.length,
                            itemBuilder: (context, index) {
                              final trip = trips![index];
                              return PostWidget(
                                post: trip,
                                dropIndex: index,
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
