import 'package:RollaStrava/src/constants/app_button.dart';
import 'package:RollaStrava/src/constants/app_styles.dart';
import 'package:RollaStrava/src/screen/auth/signup_step2_screen.dart';
import 'package:RollaStrava/src/translate/en.dart';
import 'package:RollaStrava/src/utils/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignupStep1Screen extends ConsumerStatefulWidget {
  const SignupStep1Screen({Key? key}) : super(key: key);

  @override
  ConsumerState<SignupStep1Screen> createState() => _SignupStep1ScreenState();
}

class _SignupStep1ScreenState extends ConsumerState<SignupStep1Screen> {
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
                    SizedBox(
                      height: vhh(context, 10),
                    ),
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
                            width: vww(context, 15),
                          ),
                        ),
                        
                        Image.asset(
                          'assets/images/icons/logo.png',
                          width: vww(context, 25),
                        ),

                        Container(width: vww(context, 15),),
                      ],
                    ),
                    const Text(trave_share, style: TextStyle(color: kColorGrey, fontSize: 16),),

                    SizedBox(height: vhh(context, 5),),
                    SizedBox(
                      width: vw(context, 38),
                      height: vh(context, 8),
                      child: TextField(
                        controller: _useremailController,
                        keyboardType: TextInputType.name,
                        autocorrect: false,
                        cursorColor: kColorGrey,
                        style: const TextStyle(color: kColorBlack),
                        decoration: const InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: kColorGrey, width: 1),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: kColorBlack, width: 1.5),
                          ),
                          hintText: first_name,
                          hintStyle: TextStyle(color: kColorGrey),
                          contentPadding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 0),
                          counterText: '',
                        ),
                      ),
                    ),

                    SizedBox(
                      width: vw(context, 38),
                      height: vh(context, 8),
                      child: TextField(
                        controller: _passwordController,
                        keyboardType: TextInputType.name,
                        autocorrect: false,
                        cursorColor: kColorGrey,
                        style: const TextStyle(color: kColorBlack),
                        decoration: const InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: kColorGrey, width: 1),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: kColorBlack, width: 1.5),
                          ),
                          hintText: last_name,
                          hintStyle: TextStyle(color: kColorGrey),
                          contentPadding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 0),
                          counterText: '',
                        ),
                      ),
                    ),

                    SizedBox(
                      width: vw(context, 38),
                      height: vh(context, 8),
                      child: TextField(
                        controller: _passwordController,
                        keyboardType: TextInputType.visiblePassword,
                        autocorrect: false,
                        cursorColor: kColorGrey,
                        style: const TextStyle(color: kColorBlack),
                        decoration: const InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: kColorGrey, width: 1),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: kColorBlack, width: 1.5),
                          ),
                          hintText: email_address,
                          hintStyle: TextStyle(color: kColorGrey),
                          contentPadding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 0),
                          counterText: '',
                        ),
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.only(left: vww(context, 15), right: vww(context, 15), top: vhh(context, 5)),
                      child: ButtonWidget(
                        btnType: ButtonWidgetType.ContinueText,
                        borderColor: kColorButtonPrimary,
                        textColor: kColorWhite,
                        fullColor: kColorButtonPrimary,
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) => const SignupStep2Screen(),
                          )); 
                        },
                      ),
                    ),
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
