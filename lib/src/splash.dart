import 'package:RollaStrava/src/constants/app_styles.dart';
import 'package:RollaStrava/src/screen/auth/signin_screen.dart';
// import 'package:RollaStrava/src/screen/auth/signup_step1_screen.dart';
import 'package:RollaStrava/src/translate/en.dart';
import 'package:RollaStrava/src/utils/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});
  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SigninScreen(),
        ),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: FocusScope(
          child: Container(
            decoration: const BoxDecoration(
              color: kColorWhite
            ),
            child:  Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: vh(context, 25)),
                Image.asset(
                  'assets/images/icons/logo.png',
                  width: 150.0,
                  height: 150.0,
                ),
                Container(
                  alignment: Alignment.bottomCenter,
                  height: vh(context, 5),
                  child: Text(
                    trave_share.toString(),
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color:kColorGrey),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
