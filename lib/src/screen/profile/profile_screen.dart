import 'package:RollaStrava/src/constants/app_button.dart';
import 'package:RollaStrava/src/constants/app_styles.dart';
import 'package:RollaStrava/src/screen/profile/edit_profile.dart';
import 'package:RollaStrava/src/screen/settings/settings_screen.dart';
import 'package:RollaStrava/src/translate/en.dart';
import 'package:RollaStrava/src/utils/index.dart';
import 'package:RollaStrava/src/widget/bottombar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
                        SizedBox(height: vhh(context, 10)),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Image.asset(
                              'assets/images/icons/logo.png',
                              width: vww(context, 15),
                            ),
                            SizedBox(width: vww(context, 23)),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                  "@smith",
                                  style: TextStyle(
                                      color: kColorBlack, fontSize: 16),
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
                                const Text(
                                  "1",
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: kColorButtonPrimary,
                                      fontWeight: FontWeight.bold),
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
                                image: const DecorationImage(
                                  image: AssetImage("assets/images/background/image2.png"),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Column(
                              children: [
                                Image.asset(
                                  'assets/images/icons/followers.png',
                                  width: vww(context, 15),
                                ),
                                const Text(
                                  "30",
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: kColorButtonPrimary,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Container(),
                          ],
                        ),
                        SizedBox(height: vhh(context, 1)),
                        const Text(
                          "Brian Smith",
                          style: TextStyle(
                              color: kColorBlack,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: vhh(context, 1)),
                        const Text(
                          "Life is good!",
                          style: TextStyle(
                            color: kColorGrey,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: vhh(context, 2)),
                        Row(
                          children: [
                            SizedBox(
                              width: vww(context, 30),
                              child: ButtonWidget(
                                btnType: ButtonWidgetType.EditProfileText,
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
                                btnType: ButtonWidgetType.FollowingText,
                                borderColor: kColorStrongGrey,
                                textColor: kColorWhite,
                                fullColor: kColorStrongGrey,
                                onPressed: () {},
                              ),
                            ),
                            SizedBox(width: vww(context, 1)),
                            SizedBox(
                              width: vww(context, 30),
                              child: ButtonWidget(
                                btnType: ButtonWidgetType.SettingText,
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
                        const Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  odometer,
                                  style: TextStyle(
                                    color: kColorBlack,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  "00000314",
                                  style: TextStyle(
                                    color: kColorButtonPrimary,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  happy_place,
                                  style: TextStyle(
                                    color: kColorBlack,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  "Lake Placid, NY",
                                  style: TextStyle(
                                    color: kColorButtonPrimary,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  my_garage,
                                  style: TextStyle(
                                    color: kColorBlack,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  "Lexus, Toyota",
                                  style: TextStyle(
                                    color: kColorButtonPrimary,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: vhh(context, 1)),
                        SizedBox(
                          height: 100,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: List.generate(5, (index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 3),
                                child: Image.asset(
                                  'assets/images/background/1.png',
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              );
                            }),
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
                                    style: TextStyle(color: Colors.black),
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
