import 'package:RollaTravel/src/constants/app_styles.dart';
import 'package:RollaTravel/src/screen/home/home_screen.dart';
import 'package:RollaTravel/src/screen/home/home_user_screen.dart';
import 'package:RollaTravel/src/services/api_service.dart';
import 'package:RollaTravel/src/utils/back_button_header.dart';
import 'package:RollaTravel/src/utils/global_variable.dart';
import 'package:RollaTravel/src/utils/spinner_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:RollaTravel/src/utils/index.dart';
import 'package:RollaTravel/src/widget/bottombar.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  final int? userid;
  const NotificationScreen({super.key, required this.userid});

  @override
  ConsumerState<NotificationScreen> createState() => NotificationScreenState();
}

class NotificationScreenState extends ConsumerState<NotificationScreen> with WidgetsBindingObserver {
  final int _currentIndex = 5;
  List<Map<String, dynamic>> followers = [];
  final logger = Logger();
  bool isloding = false;

  final GlobalKey _backButtonKey = GlobalKey();
  double backButtonWidth = 0;

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
      followers = await apiservice.fetchNotificationUsers(widget.userid!);
      logger.i(followers);
      setState(() {});
    } catch (e) {
      logger.i('Error loading followers: $e');
    }
  }

  Future<void> _acceptButton (int userId) async {
    try {
      final apiservice = ApiService();
      final result = await apiservice.requestFollowAccept(GlobalVariables.userId!, userId);
      logger.i(result);
      if(result['statusCode'] == true){
        if(!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NotificationScreen(userid: GlobalVariables.userId,)), 
        );
        _loadFollowers();
      }
    } catch (e) {
      logger.i('Error loading followers: $e');
    }
  }

  Future<void> _acceptRequestCloseButton (int userId, String fromItem) async {
    try {
      final apiservice = ApiService();
      if(fromItem == "follow"){
        final result = await apiservice.viewAcceptNotification(GlobalVariables.userId!, userId);
        logger.i(result);
        if(result['statusCode'] == true){
          _loadFollowers();
        }  
      } else if (fromItem == "tag") {
        final result = await apiservice.viewedTaged(GlobalVariables.userId!, userId);
        logger.i(result);
        if(result['statusCode'] == true){
          _loadFollowers();
        } 
      } else if (fromItem == "comment"){
        final result = await apiservice.viewedCommented(GlobalVariables.userId!, userId);
        logger.i(result);
        if(result['statusCode'] == true){
          _loadFollowers();
        }
      } else if (fromItem == "like"){
        final result = await apiservice.viewedliked(GlobalVariables.userId!, userId);
        logger.i(result);
        if(result['statusCode'] == true){
          _loadFollowers();
        }
      } else if(fromItem == "followed"){
          final result = await apiservice.tappedFollowed(GlobalVariables.userId!, userId);
          logger.i(result);
          if(result['statusCode'] == true){
            _loadFollowers();
          }
      }
      
    } catch (e) {
      logger.i('Error loading followers: $e');
    }
  }

  Future<void> _denyButton (int userId) async {
    try {
      final apiservice = ApiService();
      final result = await apiservice.removePendingFollow(GlobalVariables.userId!, userId);
      logger.i(result);
      if(result['statusCode'] == true){
        if(!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NotificationScreen(userid: GlobalVariables.userId,)), 
        );
        _loadFollowers();
      }
    } catch (e) {
      logger.i('Error loading followers: $e');
    }
  }
  
  String _getFollowStatusText(String from, String username) {
    switch (from) {
      case 'pending':
        return 'Requested to follow you';
      case 'follow':
        return 'You accepted @$username follow request.';
      case 'tag':
        return "Tagged you in @$username's post";
      case 'comment':
        return 'commented on your post';
      case 'like':
        return 'liked your post';
      case 'followed':
        return '@$username accepted your follow request';
      default:
        return 'Unknown status';
    }
  }

  String _formatDate(String date) {
    try {
      final DateTime parsedDate = DateTime.parse(date);
      return DateFormat('MM/dd/yyyy').format(parsedDate);
    } catch (e) {
      return ''; 
    }
  }

  void _onBackPressed() async {
    List<Map<String, dynamic>> unviewedFollowers = followers
      .where((follower) => follower['viewed'] == false)
      .toList();

    setState(() {
      isloding = true; 
    });

    try {
      for (var follower in unviewedFollowers) {
        final fromItem = follower['from'];
        final userId = follower['id'];
        if (fromItem == 'follow') {
          logger.i(userId);
          await ApiService().viewedFollowingNotification(GlobalVariables.userId!, userId);
        } 
        else if (fromItem == 'pending') {
          logger.i(userId);
          await ApiService().viewedPendingNotification(GlobalVariables.userId!, userId);
        } else if (fromItem == 'followed') {
          logger.i(userId);
          await ApiService().viewedFollowedNotification(GlobalVariables.userId!, userId);
        } else if (fromItem == 'tag') {
          logger.i(userId);
          await ApiService().viewedTagNotification(GlobalVariables.userId!, userId);
        } else if (fromItem == 'comment') {
          await ApiService().viewedCommentNotification(GlobalVariables.userId!, userId);
        } else if (fromItem == 'like') {
          await ApiService().viewedlikeNotification(GlobalVariables.userId!, userId);
        }
      }
    } catch (e) {
      logger.e("Error while marking followers as viewed: $e");
    } finally {
      setState(() {
        isloding = false;
      });
    }
    if(!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => const HomeScreen(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RenderBox renderBox = _backButtonKey.currentContext?.findRenderObject() as RenderBox;
      setState(() {
        backButtonWidth = renderBox.size.width;
      });
    });

    if (isloding) {
      return const Scaffold(
        body: Center(child: SpinningLoader()),
      );
    }

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
              SizedBox(height: vhh(context, 7),),
              Padding(padding: EdgeInsets.symmetric(horizontal: vww(context, 4)),
                child: BackButtonHeader(
                  onBackPressed: _onBackPressed,
                  title: 'Notifications',
                  backButtonKey: _backButtonKey,
                  backButtonWidth: backButtonWidth,
                ),
              ),
              SizedBox(height: vhh(context, 0.5),),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Divider(),),
              Expanded(
                child: ListView.builder(
                  itemCount: followers.length,
                  itemBuilder: (context, index) {
                    final follower = followers[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 20),
                      child: InkWell(
                        onTap: () {
                          final from = follower['from'];
                          final tripId = follower['tripId'];
                          final userId = follower['id'];
                          if (from == 'tag') {
                            GlobalVariables.homeTripID = tripId;
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const HomeScreen()),
                            );
                          } else if (from == 'comment'){
                            GlobalVariables.homeTripID = follower['trip'];
                            logger.i(follower['trip']);
                            GlobalVariables.openComment = true;
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const HomeScreen()),
                            );
                          }
                          else if (from == 'like'){
                            GlobalVariables.homeTripID = tripId;
                            GlobalVariables.likedDroppinId = follower['likeid']; 
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const HomeScreen()),
                            );
                          }
                          else if (from == 'followed'){
                            GlobalVariables.homeTripID = tripId;
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => HomeUserScreen(userId : userId)),
                            );
                          }
                          else if (from == 'follow'){
                            GlobalVariables.homeTripID = tripId;
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => HomeUserScreen(userId : userId)),
                            );
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: follower['viewed'] == true 
                              ? Colors.white
                              : Colors.grey.shade200, 
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 1, 
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                          child: Row(
                            children: [
                              Container(
                                height: vhh(context, 6),
                                width: vhh(context, 6),
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
                                          fontSize: 13,
                                          letterSpacing: -0.1,
                                          fontWeight: FontWeight.bold
                                        ),
                                      ),
                                      const SizedBox(width: 3),
                                      const Icon(Icons.verified,
                                          color: Colors.blue, size: 14),
                                    ],
                                  ),
                                  Text(
                                    _getFollowStatusText(follower['from'], follower['rolla_username']),
                                    style: const TextStyle(
                                      fontFamily: 'inter',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                      letterSpacing: -0.1
                                    ),
                                  ),
                                  Text(
                                    _formatDate(follower['follow_date'] ?? ''),
                                    style: const TextStyle(
                                      fontSize: 9,
                                      color: kColorStrongGrey,
                                      fontFamily: 'inter',
                                      letterSpacing: -0.1,
                                    ),
                                  )
                                ],
                              ),
                              const Spacer(),
                              follower['from'] == 'pending'
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 60,
                                        height: 23,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            _acceptButton(follower['id']);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(30),
                                              side: BorderSide(
                                                color: Colors.grey.withValues(alpha: 0.4), 
                                                width: 0.5,  
                                              ),
                                            ),
                                            padding: EdgeInsets.zero,  
                                            shadowColor: Colors.black.withValues(alpha: 0.4), 
                                            elevation: 4,  
                                          ),
                                          child: const Text(
                                            'Accept',
                                            style: TextStyle(
                                              fontFamily: 'inter',
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: -0.1,
                                              color: kColorGreen,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      SizedBox(
                                        width: 60,
                                        height: 23,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            _denyButton(follower['id']);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(30),
                                              side: BorderSide(
                                                color: Colors.grey.withValues(alpha: 0.4), 
                                                width: 0.5,  
                                              ),
                                            ),
                                            padding: EdgeInsets.zero,  
                                            shadowColor: Colors.black.withValues(alpha: 0.4), 
                                            elevation: 4,  
                                          ),
                                          child: const Text(
                                            'Deny',
                                            style: TextStyle(
                                              fontFamily: 'inter',
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: -0.1,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : GestureDetector(
                                    onTap: () {
                                      _acceptRequestCloseButton(follower['id'], follower['from']);
                                    },
                                    behavior: HitTestBehavior.translucent, // ensures invisible padding is tappable
                                    child: Container(
                                      padding: const EdgeInsets.all(12), // expands tap target
                                      alignment: Alignment.center,
                                      child: const Icon(
                                        Icons.close,
                                        size: 20,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),

                            ],
                          ),
                        ),
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
