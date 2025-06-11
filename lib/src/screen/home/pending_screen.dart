import 'package:RollaTravel/src/constants/app_styles.dart';
import 'package:RollaTravel/src/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:RollaTravel/src/utils/index.dart';
import 'package:RollaTravel/src/widget/bottombar.dart';
import 'package:logger/logger.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  final int? userid;
  const NotificationScreen({super.key, required this.userid});

  @override
  ConsumerState<NotificationScreen> createState() => NotificationScreenState();
}

class NotificationScreenState extends ConsumerState<NotificationScreen> with WidgetsBindingObserver {
  final int _currentIndex = 0;
  List<Map<String, dynamic>> followers = [];
  final logger = Logger();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadFollowers();
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

  Future<void> _loadFollowers() async {
    try {
      final apiservice = ApiService();
      followers = await apiservice.fetchPendingFollowingUsers(widget.userid!);
      logger.i(followers);
      setState(() {});
    } catch (e) {
      logger.i('Error loading followers: $e');
    }
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
              SizedBox(
                height: vhh(context, 6),
              ),
              Row(
                children: [
                  const SizedBox(width: 16),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Image.asset(
                      'assets/images/icons/allow-left.png',
                      width: vww(context, 5),
                      height: 20,
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Column(
                        children: [
                           Text(
                            'Notifications',
                            style: TextStyle(
                              fontSize: 20,
                              letterSpacing: -0.1,
                              fontFamily: 'interBold',
                            ),
                          ),
                          SizedBox(height: 10,)
                          // Text(
                          //   'List of the users who follow ${widget.fromUser}',
                          //   style: const TextStyle(
                          //     fontSize: 13,
                          //     color: Colors.grey,
                          //     letterSpacing: -0.1,
                          //     fontFamily: 'inter',
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Divider(),),

              Expanded(
                child: ListView.builder(
                  itemCount: followers.length,
                  itemBuilder: (context, index) {
                    final follower = followers[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 4.0, horizontal: 20),
                      child: Row(
                        children: [
                          Container(
                            height: 50, 
                            width: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: kColorHereButton,
                                width: 2,
                              ),
                            ),
                            child: ClipOval(
                              child: follower['photo'] != null
                                  ? Image.network(
                                      follower['photo'],
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(Icons.error),
                                    )
                                  : const Icon(Icons.person),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "@${follower['rolla_username']}",
                                    style: const TextStyle(
                                      fontFamily: 'inter',
                                      fontSize: 15,
                                      letterSpacing: -0.1,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  const Icon(Icons.verified,
                                      color: Colors.blue, size: 16),
                                ],
                              ),
                              Text(
                                '${follower['first_name'] ?? ''} ${follower['last_name'] ?? ''}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                  fontFamily: 'inter',
                                  letterSpacing: -0.1,
                                ),
                              )
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
