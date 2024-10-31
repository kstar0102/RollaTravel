import 'package:RollaStrava/src/constants/app_button.dart';
import 'package:RollaStrava/src/constants/app_styles.dart';
import 'package:RollaStrava/src/screen/auth/signup_step1_screen.dart';
import 'package:RollaStrava/src/translate/en.dart';
import 'package:RollaStrava/src/utils/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/gestures.dart';

class SigninScreen extends ConsumerStatefulWidget {
  const SigninScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends ConsumerState<SigninScreen> {
  final _usernameController = TextEditingController();
  final _useremailController= TextEditingController();
  final _passwordController = TextEditingController();
  String get username => _usernameController.text;
  String get email => _useremailController.text;
  String get password => _passwordController.text;
  double screenHeight = 0;
  double keyboardHeight = 0;
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
                child: Padding(padding: EdgeInsets.only(left: vww(context, 7), right: vww(context, 7)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        height: vhh(context, 15),
                      ),
                      Image.asset(
                        'assets/images/icons/logo.png',
                        width: vww(context, 25),
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
                            hintText: user_name,
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
                            hintText: password_title,
                            hintStyle: TextStyle(color: kColorGrey),
                            contentPadding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 0),
                            counterText: '',
                          ),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.only(left: vww(context, 15), right: vww(context, 15), top: vhh(context, 3)),
                        child: ButtonWidget(
                          btnType: ButtonWidgetType.LoginText,
                          borderColor: kColorButtonPrimary,
                          textColor: kColorWhite,
                          fullColor: kColorButtonPrimary,
                          onPressed: () {
                            
                          },
                        ),
                      ),

                      SizedBox(
                        height: vhh(context, 3),
                      ),

                      const Text(country_residence, style: TextStyle(color: kColorBlack, fontSize: 16, fontWeight: FontWeight.bold),),

                      SizedBox(
                        height: vhh(context, 1),
                      ),

                      Padding(
                        padding: EdgeInsets.only(
                          left: vww(context, 10), 
                          right: vww(context, 10),
                        ),
                        child: Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(
                                text: dont_have_account,
                                style: TextStyle(
                                  color: kColorGrey,
                                  fontSize: 16,
                                ),
                              ),
                              TextSpan(
                                text: here_title,
                                style: const TextStyle(
                                  color: kColorHereButton,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                  decorationColor: kColorHereButton,
                                ),
                                recognizer: TapGestureRecognizer()..onTap = () {
                                  Navigator.push(context, MaterialPageRoute(
                                    builder: (context) => const SignupStep1Screen(),
                                  )); 
                                },
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      SizedBox(
                        height: vhh(context, 15),
                      ),

                      Padding(
                        padding: EdgeInsets.only(
                          left: vww(context, 15), 
                          right: vww(context, 15),
                        ),
                        child: Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(
                                text: forgot_passwod,
                                style: TextStyle(
                                  color: kColorGrey,
                                  fontSize: 16,
                                ),
                              ),
                              TextSpan(
                                text: here_title,
                                style: const TextStyle(
                                  color: kColorHereButton,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                  decorationColor: kColorHereButton,
                                ),
                                recognizer: TapGestureRecognizer()..onTap = () {
                                },
                              ),
                              const TextSpan(
                                text: to_reset,
                                style: TextStyle(
                                  color: kColorGrey,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                )
              ),
            ),
          )
        ),
      )
    );
  }
}
