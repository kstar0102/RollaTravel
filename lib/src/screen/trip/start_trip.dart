import 'package:RollaStrava/src/constants/app_styles.dart';
import 'package:RollaStrava/src/translate/en.dart';
import 'package:RollaStrava/src/utils/index.dart';
import 'package:RollaStrava/src/widget/bottombar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StartTripScreen extends ConsumerStatefulWidget {
  const StartTripScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<StartTripScreen> createState() => _StartTripScreenState();
}

class _StartTripScreenState extends ConsumerState<StartTripScreen> {
  double screenHeight = 0;
  double keyboardHeight = 0;
  final int _currentIndex = 0;
  final bool _isKeyboardVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
      if (this.mounted) {
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Image.asset(
                              'assets/images/icons/logo.png',
                              width: vww(context, 15),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/icons/add_car1.png',
                                  width: vww(context, 15),
                                ),
                                
                                Image.asset(
                                  'assets/images/icons/setting.png',
                                  width: vww(context, 15),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: vhh(context, 1)),
                        Padding(padding: EdgeInsets.only(left: vww(context, 3), right: vww(context, 3)),
                          child: const Divider(color: kColorGrey, thickness: 1),
                        ),

                        SizedBox(height: vhh(context, 1)),
                        const Column(
                          children: [
                            Row(
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
                            Row(
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
                            Row(
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
                          ],
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
