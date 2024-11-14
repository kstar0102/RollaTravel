import 'package:RollaStrava/src/screen/trip/start_trip.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:RollaStrava/src/utils/index.dart';
import 'package:RollaStrava/src/widget/bottombar.dart';
import 'package:RollaStrava/src/translate/en.dart';
import 'package:RollaStrava/src/constants/app_styles.dart';

class ChoosenLocationScreen extends ConsumerStatefulWidget{
  const ChoosenLocationScreen({super.key});

  @override
  ConsumerState<ChoosenLocationScreen> createState() => ChoosenLocationScreenState();
}

class ChoosenLocationScreenState extends ConsumerState<ChoosenLocationScreen> {
  double screenHeight = 0;
  double keyboardHeight = 0;
  final int _currentIndex = 3;

  @override
  void initState() {
    super.initState();
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: vhh(context, 5),),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey, width: 1.5),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.9),
                      spreadRadius: -5,
                      blurRadius: 15,
                      offset: const Offset(0, 5), // Only apply shadow at the top
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              // Handle tap on the logo if needed
                            },
                            child: Image.asset(
                              'assets/images/icons/logo.png', // Replace with your logo asset path
                              height: vh(context, 13),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: 10,
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.black, size: 28),
                            onPressed: () {
                              Navigator.pop(context); // Close action
                            },
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0), // Adjust the value as needed
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            destination,
                            style: TextStyle(
                              color: kColorBlack,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            edit_destination,
                            style: TextStyle(
                              color: kColorButtonPrimary,
                              fontSize: 14,
                              decoration: TextDecoration.underline,
                              decorationColor: kColorButtonPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0), // Adjust the value as needed
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            miles_traveled,
                            style: TextStyle(
                              color: kColorBlack,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            "0",
                            style: TextStyle(
                              color: kColorBlack,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0), // Adjust the value as needed
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            soundtrack,
                            style: TextStyle(
                              color: kColorBlack,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            edit_playlist,
                            style: TextStyle(
                              color: kColorButtonPrimary,
                              fontSize: 14,
                              decoration: TextDecoration.underline,
                              decorationColor: kColorButtonPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: SizedBox(
                        width: vww(context, 60),
                        height: vhh(context, 45),
                        child: Column(
                          children: [
                            Container(
                              height: vhh(context, 38),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey, width: 1.0), // Set border color and width
                                borderRadius: BorderRadius.circular(8.0), // Optional: Add border radius for rounded corners
                              ),
                              child: Column(
                                children: [
                                  const Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: EdgeInsets.only(left: 10.0, top: 5, bottom: 5),
                                        child: Text(
                                        "Caption",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Image
                                  Expanded(
                                    child: Image.asset(
                                      "assets/images/background/Lake1.png",
                                      fit: BoxFit.cover,
                                      width: vww(context, 100),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: vhh(context, 0.5)),
                            const Padding(
                              padding: EdgeInsets.only(top: 8.0),
                              child: Text(
                                "the Rolla travel app",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  "Share this summary:",
                  style: TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) => const StartTripScreen(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                    ),
                  );
                },
                child: Image.asset(
                  "assets/images/icons/share.png",
                  height: 50,
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