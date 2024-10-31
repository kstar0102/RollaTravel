import 'package:RollaStrava/src/constants/app_button.dart';
import 'package:RollaStrava/src/constants/app_styles.dart';
import 'package:RollaStrava/src/translate/en.dart';
import 'package:RollaStrava/src/utils/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginUserFlowScreen extends ConsumerStatefulWidget {
  const LoginUserFlowScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginUserFlowScreen> createState() => _LoginUserFlowScreenState();
}

class _LoginUserFlowScreenState extends ConsumerState<LoginUserFlowScreen> {
  final _usernameController = TextEditingController();
  final _useremailController= TextEditingController();
  final _passwordController = TextEditingController();
  String get username => _usernameController.text;
  String get email => _useremailController.text;
  String get password => _passwordController.text;
  double screenHeight = 0;
  double keyboardHeight = 0;
  final bool _isKeyboardVisible = false;
  int _carouselIndex = 0;

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
                        height: vhh(context, 10),
                      ),
                      Image.asset(
                        'assets/images/icons/logo.png',
                        width: vww(context, 25),
                      ),
                      SizedBox(height: vhh(context, 2),),
                      const Text(how_to_create_post, style: TextStyle(color: kColorGrey, fontSize: 16),),
                      SizedBox(height: vhh(context, 2),),
                      SizedBox(
                        height: vhh(context, 50),
                        child: PageView(
                          onPageChanged: (index) {
                            setState(() {
                              _carouselIndex = index;
                            });
                          },
                          children: [
                            Image.asset('assets/images/icons/rolla_logo.png',), 
                            Image.asset('assets/images/icons/rolla_logo.png'),
                            Image.asset('assets/images/icons/rolla_logo.png'),
                          ],
                        ),
                      ),
                      
                      // Carousel Indicators
                      SizedBox(height: vhh(context, 2),),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            width: _carouselIndex == index ? 8 : 6,
                            height: _carouselIndex == index ? 8 : 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _carouselIndex == index
                                  ? Colors.brown
                                  : Colors.grey,
                            ),
                          );
                        }),
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
