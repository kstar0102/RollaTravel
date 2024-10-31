import 'package:RollaStrava/src/constants/app_button.dart';
import 'package:RollaStrava/src/constants/app_styles.dart';
import 'package:RollaStrava/src/screen/auth/login_userflow.dart';
import 'package:RollaStrava/src/translate/en.dart';
import 'package:RollaStrava/src/utils/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignupStep2Screen extends ConsumerStatefulWidget {
  const SignupStep2Screen({Key? key}) : super(key: key);

  @override
  ConsumerState<SignupStep2Screen> createState() => _SignupStep2ScreenState();
}

class _SignupStep2ScreenState extends ConsumerState<SignupStep2Screen> {
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
  String? _selectedOption;

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
                          hintText: rolla_username,
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
                          hintText: password_title,
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
                            title: const Text(i_saw_ad),
                            value: i_saw_ad,
                            groupValue: _selectedOption,
                            onChanged: (value) {
                              setState(() {
                                _selectedOption = value;
                              });
                            },
                          ),
                          RadioListTile<String>(
                            title: const Text(recommendation),
                            value: recommendation,
                            groupValue: _selectedOption,
                            onChanged: (value) {
                              setState(() {
                                _selectedOption = value;
                              });
                            },
                          ),
                          RadioListTile<String>(
                            title: const Text(other),
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
                      padding: EdgeInsets.only(left: vww(context, 15), right: vww(context, 15), top: vhh(context, 3)),
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
