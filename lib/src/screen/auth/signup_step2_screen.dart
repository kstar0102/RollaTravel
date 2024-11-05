import 'package:RollaStrava/src/constants/app_button.dart';
import 'package:RollaStrava/src/constants/app_styles.dart';
import 'package:RollaStrava/src/screen/auth/login_userflow.dart';
import 'package:RollaStrava/src/translate/en.dart';
import 'package:RollaStrava/src/utils/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignupStep2Screen extends ConsumerStatefulWidget {
  const SignupStep2Screen({super.key});

  @override
  ConsumerState<SignupStep2Screen> createState() => _SignupStep2ScreenState();
}

class _SignupStep2ScreenState extends ConsumerState<SignupStep2Screen> {
  final _usernameController = TextEditingController();
  final _passwordController= TextEditingController();
  final _rePasswordController = TextEditingController();
  String get userName => _usernameController.text;
  String get password => _passwordController.text;
  String get rePassword => _rePasswordController.text;
  bool isPasswordVisible = false;
  double screenHeight = 0;
  double keyboardHeight = 0;
  final bool _isKeyboardVisible = false;
  bool isChecked = false;
  String? _selectedOption;

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
    _usernameController.dispose();
    _passwordController.dispose();
    _rePasswordController.dispose();
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
    return WillPopScope (
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
                      height: vhh(context, 8),
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
                            height: 20,
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
                    SizedBox(height: vhh(context, 3),),
                    SizedBox(
                      width: vw(context, 38),
                      height: vh(context, 6.5),
                      child: TextField(
                        controller: _usernameController,
                        keyboardType: TextInputType.name,
                        autocorrect: false,
                        cursorColor: kColorGrey,
                        style: const TextStyle(color: kColorBlack, fontSize: 14),
                        decoration: const InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: kColorGrey, width: 1),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: kColorBlack, width: 1.5),
                          ),
                          hintText: rolla_username,
                          hintStyle: TextStyle(color: kColorGrey),
                          contentPadding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 0),
                          counterText: '',
                        ),
                      ),
                    ),

                    SizedBox(
                      width: vw(context, 38),
                      height: vh(context, 6.5),
                      child: TextField(
                        controller: _passwordController,
                        keyboardType: TextInputType.name,
                        autocorrect: false,
                        cursorColor: kColorGrey,
                        style: const TextStyle(color: kColorBlack, fontSize: 14),
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

                    SizedBox(
                      width: vw(context, 38),
                      height: vh(context, 6.5),
                      child: TextField(
                        controller: _rePasswordController,
                        keyboardType: TextInputType.visiblePassword,
                        autocorrect: false,
                        cursorColor: kColorGrey,
                        style: const TextStyle(color: kColorBlack, fontSize: 14),
                        decoration: const InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: kColorGrey, width: 1),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: kColorBlack, width: 1.5),
                          ),
                          hintText: re_enter_password,
                          hintStyle: TextStyle(color: kColorGrey),
                          contentPadding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 0),
                          counterText: '',
                        ),
                      ),
                    ),

                    SizedBox(
                      height: vhh(context, 5),
                    ),
                    
                    Padding(
                      padding: EdgeInsets.only(top: vhh(context, 1), left: vww(context, 10), right: vww(context, 10)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            how_did_you_hear,
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: vhh(context, 1)),
                          RadioListTile<String>(
                            controlAffinity: ListTileControlAffinity.trailing,
                            contentPadding: EdgeInsets.zero, // Remove extra padding
                            visualDensity: const VisualDensity(horizontal: -4, vertical: -4), // Adjust density to reduce spacing
                            title: const Padding(
                              padding: EdgeInsets.only(left: 20), // Indent the text by approximately 10 inches
                              child: Text(i_saw_ad),
                            ),
                            value: i_saw_ad,
                            groupValue: _selectedOption,
                            onChanged: (value) {
                              setState(() {
                                _selectedOption = value;
                              });
                            },
                          ),
                          RadioListTile<String>(
                            controlAffinity: ListTileControlAffinity.trailing,
                            contentPadding: EdgeInsets.zero,
                            visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                            title: const Padding(
                              padding: EdgeInsets.only(left: 20), // Indent the text by approximately 10 inches
                              child: Text(recommendation),
                            ),
                            value: recommendation,
                            groupValue: _selectedOption,
                            onChanged: (value) {
                              setState(() {
                                _selectedOption = value;
                              });
                            },
                          ),
                          RadioListTile<String>(
                            controlAffinity: ListTileControlAffinity.trailing,
                            contentPadding: EdgeInsets.zero,
                            visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                            title: const Padding(
                              padding: EdgeInsets.only(left: 20), // Indent the text by approximately 10 inches
                              child: Text(other),
                            ),
                            value: other,
                            groupValue: _selectedOption,
                            onChanged: (value) {
                              setState(() {
                                _selectedOption = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.only(left: vww(context, 15), right: vww(context, 15), top: vhh(context, 2)),
                      child: ButtonWidget(
                        btnType: ButtonWidgetType.CreateAccountTitle,
                        borderColor: kColorCreateButton,
                        textColor: kColorWhite,
                        fullColor: kColorCreateButton,
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) => const LoginUserFlowScreen(),
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
