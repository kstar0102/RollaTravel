import 'package:RollaTravel/src/constants/app_styles.dart';
import 'package:RollaTravel/src/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:RollaTravel/src/utils/index.dart';
import 'package:RollaTravel/src/widget/bottombar.dart';
import 'package:logger/logger.dart';
import 'package:RollaTravel/src/screen/profile/profile_screen.dart';
class ProfileFollowingScreen extends ConsumerStatefulWidget {
  final int? userid;
  const ProfileFollowingScreen({super.key, required this.userid});

  @override
  ConsumerState<ProfileFollowingScreen> createState() => ProfileFollowScreenState();
}

class ProfileFollowScreenState extends ConsumerState<ProfileFollowingScreen> {
  final int _currentIndex = 4;
  double keyboardHeight = 0;
  List<Map<String, dynamic>> followers = [];
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

    _loadFollowers();
  }

  Future<void> _loadFollowers() async {
    try {
      final apiservice = ApiService();
      followers = await apiservice.fetchFollowedUsers(widget.userid!);
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
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation1, animation2) =>
                                const ProfileScreen(),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      );
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
                            'Following',
                            style: TextStyle(
                              fontSize: 20,
                              letterSpacing: -0.1,
                              fontFamily: 'interBold',
                            ),
                          ),
                          Text(
                            'List of users you follow',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                              letterSpacing: -0.1,
                              fontFamily: 'inter',
                            ),
                          ),
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
                            height: 50, // Adjust the size as needed
                            width: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: kColorHereButton, // Adjust border color
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
