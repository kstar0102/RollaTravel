import 'package:RollaStrava/src/constants/app_button.dart';
import 'package:RollaStrava/src/constants/app_styles.dart';
import 'package:RollaStrava/src/screen/auth/login_userflow.dart';
import 'package:RollaStrava/src/translate/en.dart';
import 'package:RollaStrava/src/utils/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignupStep2Screen extends ConsumerStatefulWidget {
  final String firstName;
  final String lastName;
  final String emailAddress;
  final String countryResidence;
  const SignupStep2Screen({
    super.key, 
    required this.firstName,
    required this.lastName,
    required this.emailAddress,
    required this.countryResidence
  });

  @override
  ConsumerState<SignupStep2Screen> createState() => _SignupStep2ScreenState();
}

class _SignupStep2ScreenState extends ConsumerState<SignupStep2Screen> {
  final _usernameController = TextEditingController();
  final _passwordController= TextEditingController();
  final _rePasswordController = TextEditingController();
  // String get userName => _usernameController.text;
  // String get password => _passwordController.text;
  // String get rePassword => _rePasswordController.text;
  bool isPasswordVisible = false;
  double screenHeight = 0;
  double keyboardHeight = 0;
  final bool _isKeyboardVisible = false;
  bool isChecked = false;
  String? _selectedOption;
  String? userNameError;
  String? passwordError;
  String? rePasswordError;

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
                        decoration: InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: kColorGrey, width: 1),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: kColorBlack, width: 1.5),
                          ),
                          errorText: userNameError,
                          hintText: "Rolla Username",
                          hintStyle: const TextStyle(color: kColorGrey, fontSize: 14),
                          contentPadding: const EdgeInsets.only(
                            top: -8, // Push hint closer to the top
                            bottom: -5, // Reduce space between text and underline
                          ),
                          errorStyle: const TextStyle(
                            color: Colors.red, // Customize error message color
                            fontSize: 12, // Reduce font size of the error message
                            height: 0.5, // Adjust line height for tighter spacing
                          ),
                          counterText: '',
                        ),
                        onChanged: (value) {
                          setState(() {
                            if (value.length < 4) {
                              userNameError = 'Username must be at least 6 characters.';
                            } else if(value.isEmpty){
                              userNameError = "username is required";
                            }
                            else {
                              userNameError = null; // No error
                            }
                          });
                        },
                      ),
                    ),

                    SizedBox(
                      width: vw(context, 38),
                      height: vh(context, 6.5),
                      child: TextField(
                        controller: _passwordController,
                        keyboardType: TextInputType.visiblePassword,
                        autocorrect: false,
                        obscureText: true,
                        cursorColor: kColorGrey,
                        style: const TextStyle(color: kColorBlack, fontSize: 14),
                        decoration: InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: kColorGrey, width: 1),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: kColorBlack, width: 1.5),
                          ),
                          errorText: passwordError,
                          hintText: password_title,
                          hintStyle: const TextStyle(color: kColorGrey, fontSize: 14),
                          contentPadding: const EdgeInsets.only(
                            top: -8, // Push hint closer to the top
                            bottom: -5, // Reduce space between text and underline
                          ),
                          errorStyle: const TextStyle(
                            color: Colors.red, // Customize error message color
                            fontSize: 12, // Reduce font size of the error message
                            height: 0.5, // Adjust line height for tighter spacing
                          ),
                          counterText: '',
                        ),
                        onChanged: (value) {
                          setState(() {
                            if (value.length < 6) {
                              passwordError = 'Password must be at least 6 characters.';
                            } else if(value.isEmpty){
                              passwordError = "Password is required";
                            }
                            else {
                              passwordError = null; // No error
                            }
                          });
                        },
                      ),
                    ),

                    SizedBox(
                      width: vw(context, 38),
                      height: vh(context, 6.5),
                      child: TextField(
                        controller: _rePasswordController,
                        keyboardType: TextInputType.visiblePassword,
                        autocorrect: false,
                        obscureText: true,
                        cursorColor: kColorGrey,
                        style: const TextStyle(color: kColorBlack, fontSize: 14),
                        decoration: InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: kColorGrey, width: 1),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: kColorBlack, width: 1.5),
                          ),
                          errorText: rePasswordError, 
                          hintText: re_enter_password,
                          hintStyle: const TextStyle(color: kColorGrey, fontSize: 14),
                          contentPadding: const EdgeInsets.only(
                            top: -8, // Push hint closer to the top
                            bottom: -5, // Reduce space between text and underline
                          ),
                          errorStyle: const TextStyle(
                            color: Colors.red, // Customize error message color
                            fontSize: 12, // Reduce font size of the error message
                            height: 0.5, // Adjust line height for tighter spacing
                          ),
                          counterText: '',
                        ),
                        onChanged: (value) {
                        setState(() {
                          if (value != _passwordController.text) {
                            rePasswordError = 'Passwords do not match.';
                          } else if (value.length < 6) {
                            rePasswordError = 'Password must be at least 6 characters.';
                          } else if(value.isEmpty){
                            rePasswordError = 'Re-enter password is required.';
                          } 
                          else {
                            rePasswordError = null; // No error
                          }
                        });
                      },
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
