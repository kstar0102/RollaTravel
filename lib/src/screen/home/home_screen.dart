import 'package:RollaStrava/src/utils/index.dart';
import 'package:RollaStrava/src/widget/bottombar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:RollaStrava/src/constants/app_styles.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends ConsumerState<HomeScreen> {
  double screenHeight = 0;
  double keyboardHeight = 0;
  final int _currentIndex = 0;

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
  }


  @override
  void dispose() {
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: _onWillPop,
        child: Padding(
        padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: vhh(context, 3),),
              // Header Section
              Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Image.asset(
                      'assets/images/icons/logo.png',
                      width: vww(context, 20),
                    ),
                  ),
                  Image.asset("assets/images/icons/notification.png", width: vww(context, 4),),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0), // Adjust the value as needed
                child: Divider(),
              ),

              // Profile Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: vhh(context, 7),
                        width: vhh(context, 7),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: kColorHereButton,
                            width: 2,
                          ),
                          image: const DecorationImage(
                            image: AssetImage("assets/images/background/2.png"),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text('@smith', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 10),
                      const Icon(Icons.verified, color: Colors.blue, size: 16),
                      const Spacer(),
                      Image.asset("assets/images/icons/reference.png")
                    ],
                  ),
                  SizedBox(height: vhh(context, 2),),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Left Column: Labels
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Destination', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          SizedBox(height: 3),
                          Text('Miles traveled', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          SizedBox(height: 3),
                          Text('Soundtrack', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      // Right Column: Values and Links
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () {
                              // Navigate to location link
                            },
                            child: const Text(
                              'Lake Placid, NY',
                              style: TextStyle(fontSize: 16, color: Colors.brown, decoration: TextDecoration.underline),
                            ),
                          ),
                          const SizedBox(height: 3),
                          const Text(
                            '247',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 3),
                          GestureDetector(
                            onTap: () {
                              // Open Spotify playlist link
                            },
                            child: const Text(
                              'Spotify Playlist',
                              style: TextStyle(fontSize: 16, color: Colors.brown, decoration: TextDecoration.underline),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: vhh(context, 2),),
              // Trip Details Section
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: List.generate(5, (index) => 
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    padding: const EdgeInsets.all(2), // Outer border space
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: index >= 3 ? Colors.red : Colors.black, // Red for 4 and 5, Black for others
                        width: 1,
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(1), // Inner border space
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: index >= 3 ? Colors.blue : Colors.black, // Blue for 4 and 5, Black for others
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 10, // Adjust radius to fit within borders
                        backgroundColor: Colors.white, // Inner circle color
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),
              // Map Section
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text('Map goes here'), // Replace with map widget if available
                ),
              ),

              const SizedBox(height: 10),

              // Likes and Comments Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Likes and Adventure Text
                  Row(
                    children: [
                      const Text(
                        '# likes',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 16),
                      ),
                      const Spacer(),
                      Image.asset("assets/images/icons/messageicon.png", width: vww(context, 5),),
                      const SizedBox(width: 15),
                      Image.asset("assets/images/icons/add_car.png", width: vww(context, 9),),
                    ],
                  ),
                  const SizedBox(height: 5),
                  const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('@smith', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      SizedBox(width: 15),
                      Text('Adventure bound..', style: TextStyle(color: kColorButtonPrimary, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Comments Section
                  const Center(
                    child: Text(
                      '3 comments',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 8), // Spacing before last updated text
                  // Last Updated Text
                  const Text(
                    'last updated 3 hrs ago',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              )
            ],
          ),
        ),
    
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: _currentIndex),
    );
  }
}