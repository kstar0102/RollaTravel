import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:RollaStrava/src/constants/app_button.dart';
import 'package:RollaStrava/src/constants/app_styles.dart';
import 'package:RollaStrava/src/translate/en.dart';
import 'package:RollaStrava/src/utils/common.dart';
import 'package:RollaStrava/src/utils/index.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _usernameController = TextEditingController();
  final _useremailController= TextEditingController();
  final _passwordController = TextEditingController();
  String get username => _usernameController.text;
  String get email => _useremailController.text;
  String get password => _passwordController.text;
  bool isPasswordVisible = false;
  double screenHeight = 0;
  double keyboardHeight = 0;
  final bool _isKeyboardVisible = false;
  bool isChecked = false;

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
    _usernameController.dispose();
    _passwordController.dispose();
    _useremailController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    return false;
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<void> _signUp() async {
    if (username.isEmpty) {
      Common.showErrorMessage("Please enter your full name.", context);
      return;
    } else if (email.isEmpty) {
      Common.showErrorMessage("Please enter your email address.", context);
      return;
    } else if (password.isEmpty) {
      Common.showErrorMessage("Please enter your password.", context);
      return;
    } else if (isChecked != true) {
      Common.showErrorMessage("Do you agree to the Terms & Conditions?", context);
      return;
    }

    Common.showLoadingDialog(context);

    try {
      // Create user with Firebase Authentication
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      String uid = credential.user?.uid ?? "";
      String? fcmToken = await FirebaseMessaging.instance.getToken();

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'uid': uid, 
        'username': username,
        'email': email, 
        'fcmToken': fcmToken,
        'createdAt': Timestamp.now(), 
      });

      Navigator.of(context).pop();

      Common.showSuccessMessage("Sign up successful!", context);
      
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        Navigator.of(context).pop();
        Common.showErrorMessage('The password provided is too weak.', context);
      } else if (e.code == 'email-already-in-use') {
        Navigator.of(context).pop();
        Common.showErrorMessage('The account already exists for that email.', context);
      }
    } catch (e) {
      Navigator.of(context).pop();
      print(e);
      Common.showErrorMessage("An error occurred. Please try again.", context);
    }
  }


  @override
  Widget build(BuildContext context) {
    if (_isKeyboardVisible == true) {
      screenHeight = MediaQuery.of(context).size.height;
    } else {
      screenHeight = 800;
      keyboardHeight = 0;
    }
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: SizedBox.expand(
          child: SingleChildScrollView(
            child: FocusScope(
              child: Container(
                decoration: const BoxDecoration(
                  color: kColorWhite
                ),
                height: vhh(context, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    
                  ],
                ),
              ),
            ),
          )
        ),
      )
    );
  }
}
