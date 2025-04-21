import 'package:RollaTravel/src/constants/app_styles.dart';
import 'package:RollaTravel/src/screen/auth/signin_screen.dart';
import 'package:RollaTravel/src/translate/en.dart';
import 'package:RollaTravel/src/utils/index.dart';
import 'package:RollaTravel/src/widget/bottombar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  double screenHeight = 0;
  double keyboardHeight = 0;
  final int _currentIndex = 0;
  bool isPrivateAccount = true;

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

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SigninScreen()),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _showConfirmationDialog({
    required String title,
    required String message,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: const TextStyle(
              fontFamily: 'inter',
              letterSpacing: -0.1,
            ),
          ),
          content: Text(
            message,
            style: const TextStyle(
              fontFamily: 'inter',
              letterSpacing: -0.1,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text(
                "No",
                style: TextStyle(
                  fontFamily: 'inter',
                  letterSpacing: -0.1,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                if (title == "Logout") {
                  _logout();
                } else {
                  _logout();
                }
              },
              child: const Text(
                "Yes",
                style: TextStyle(
                  fontFamily: 'inter',
                  letterSpacing: -0.1,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PopScope(
        canPop: false, // Prevents default back navigation
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            return; // Prevent pop action
          }
        },
        child: Scaffold(
          backgroundColor: kColorWhite,
          resizeToAvoidBottomInset: true,
          body: SingleChildScrollView(
            child: FocusScope(
              child: Container(
                constraints: BoxConstraints(
                  minHeight: vhh(context, 90),
                  minWidth: MediaQuery.of(context).size.width,
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
                        SizedBox(height: vhh(context, 6)),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Image.asset(
                                'assets/images/icons/allow-left.png',
                                width: vww(context, 3),
                              ),
                            ),
                            const Text(
                              settings,
                              style: TextStyle(
                                color: kColorBlack,
                                fontSize: 21,
                                letterSpacing: -0.1,
                                fontFamily: 'inter',
                              ),
                            ),
                            SizedBox(width: vww(context, 3)),
                          ],
                        ),
                        SizedBox(height: vhh(context, 1)),
                        const Divider(color: kColorGrey, thickness: 1),

                        // Private Account Section
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                private_account,
                                style: TextStyle(
                                  fontSize: 18,
                                  letterSpacing: -0.1,
                                  fontFamily: 'inter',
                                ),
                              ),
                              SizedBox(height: vhh(context, 1)),
                              Text(
                                private_account_descrition,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                  fontFamily: 'inter',
                                  letterSpacing: -0.1,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              SizedBox(height: vhh(context, 2)),
                              Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .spaceEvenly, // Ensures equal spacing between items
                                children: [
                                  Column(
                                    children: [
                                      const Text(
                                        "Private\naccount", // Line break for multi-line text
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontFamily: 'inter',
                                            letterSpacing: -0.1,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Radio<bool>(
                                        value: true,
                                        groupValue: isPrivateAccount,
                                        activeColor: Colors.blue,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            isPrivateAccount = value ?? true;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      const Text(
                                        "Public\naccount", // Line break for multi-line text
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontFamily: 'inter',
                                            letterSpacing: -0.1,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Radio<bool>(
                                        value: false,
                                        groupValue: isPrivateAccount,
                                        activeColor: Colors.blue,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            isPrivateAccount = value ?? false;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        SizedBox(
                          height: vhh(context, 10),
                        ),
                        ListTile(
                          title: const Text(
                            logout,
                            style: TextStyle(
                              fontSize: 16,
                              decoration: TextDecoration.underline,
                              letterSpacing: -0.1,
                              fontFamily: 'interBold',
                            ),
                          ),
                          subtitle: Text(
                            logout_description,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.grey[600],
                                fontFamily: 'inter',
                                letterSpacing: -0.1,
                                fontStyle: FontStyle.italic,
                                fontSize: 13),
                          ),
                          onTap: () {
                            _showConfirmationDialog(
                                title: "Logout",
                                message: "Are you sure you want to logout?");
                          },
                        ),
                        ListTile(
                          title: const Text(
                            delete_account,
                            style: TextStyle(
                              fontSize: 16,
                              decoration: TextDecoration.underline,
                              letterSpacing: -0.1,
                              fontFamily: 'interBold',
                            ),
                          ),
                          subtitle: Text(
                            delete_description,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                                fontFamily: 'inter',
                                letterSpacing: -0.1,
                                fontStyle: FontStyle.italic),
                          ),
                          onTap: () {
                            _showConfirmationDialog(
                                title: "Delete Account",
                                message:
                                    "Are you sure you want to delete your account?");
                          },
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
