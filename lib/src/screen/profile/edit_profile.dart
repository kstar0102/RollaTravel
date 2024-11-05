import 'package:RollaStrava/src/constants/app_styles.dart';
import 'package:RollaStrava/src/translate/en.dart';
import 'package:RollaStrava/src/utils/index.dart';
import 'package:RollaStrava/src/widget/bottombar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  double screenHeight = 0;
  double keyboardHeight = 0;
  final int _currentIndex = 0;

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
                        SizedBox(height: vhh(context, 10)),
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
                                width: vww(context, 5),
                              ),
                            ),
                            
                            const Text(edit_profile, style: TextStyle(color: kColorBlack, fontSize: 18, fontWeight: FontWeight.bold),),

                            Container(),
                          ],
                        ),

                        SizedBox(height: vhh(context, 1)),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: vhh(context, 15),
                              width: vww(context, 30),
                              decoration: BoxDecoration(
                                color: kColorGrey,
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(
                                    color: kColorHereButton, width: 2),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: vhh(context, 1)),
                        const Text(
                          change_profile_photo,
                          style: TextStyle(
                            color: kColorBlack,
                            fontSize: 18,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.w500),
                        ),

                        SizedBox(height: vhh(context, 2),),

                        const Divider(color: kColorGrey, thickness: 1),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  edit_profile_username,
                                  style: TextStyle(color: kColorGrey, fontSize: 14, fontWeight: FontWeight.w400),
                                ),
                                Text(
                                  '@smith',
                                  style: TextStyle(
                                    color: kColorBlack,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            
                            const Divider(color: kColorGrey, thickness: 1),
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  edit_profile_name,
                                  style: TextStyle(color: kColorGrey, fontSize: 14, fontWeight: FontWeight.w400),
                                ),
                                Text(
                                  'Brian Smith',
                                  style: TextStyle(
                                    color: kColorBlack,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(color: kColorGrey, thickness: 1),

                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  edit_profile_bio,
                                  style: TextStyle(color: kColorGrey, fontSize: 14, fontWeight: FontWeight.w400),
                                ),
                                Text(
                                  'Life is good!',
                                  style: TextStyle(
                                    color: kColorBlack,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: vhh(context, 7)),
                            const Divider(color: kColorGrey, thickness: 1),
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  edit_profile_garage,
                                  style: TextStyle(color: kColorGrey, fontSize: 14, fontWeight: FontWeight.w400),
                                ),
                                Text(
                                  'Lixus, BMW',
                                  style: TextStyle(
                                    color: kColorBlack,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(color: kColorGrey, thickness: 1),
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  edit_profile_happy_place,
                                  style: TextStyle(color: kColorGrey, fontSize: 14, fontWeight: FontWeight.w400),
                                ),
                                Text(
                                  'Lake Placid, NY',
                                  style: TextStyle(
                                    color: kColorBlack,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(color: kColorGrey, thickness: 1),
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
