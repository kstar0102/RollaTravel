import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:RollaTravel/src/utils/index.dart';
import 'package:RollaTravel/src/constants/app_styles.dart';
import 'package:RollaTravel/src/widget/bottombar.dart';

class HomeFollowScreen extends ConsumerStatefulWidget  {
  const HomeFollowScreen({super.key});

  @override
   ConsumerState<HomeFollowScreen> createState() => HomeFollowScreenState();
}

class HomeFollowScreenState extends ConsumerState<HomeFollowScreen> {
  final int _currentIndex = 0;
  Future<bool> _onWillPop() async {
    return false;
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: Center(
          child: Column(
            children: [
              SizedBox(height: vhh(context, 5),),
              Row(
                children: [
                  const SizedBox(width: 16),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Image.asset(
                      'assets/images/icons/allow-left.png',
                      width: vww(context, 5),
                      height: 20,
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Column(
                        children: [
                          Text(
                            'Followers',
                            style: TextStyle(
                              fontSize: 20,
                              fontFamily: 'KadawBold',
                            ),
                          ),
                          Text(
                            'List of the users who follow you',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey,
                              fontFamily: 'Kadaw',
                            ),
                          ),
                        ],
                      ),
                      
                    ),
                  ),
                  const SizedBox(width: 48), // To balance the space taken by the IconButton
                ],
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 20),
                      child: Row(
                        children: [
                          Container(
                            height: vhh(context, 6),
                            width: vhh(context, 6),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(
                                color: kColorHereButton,
                                width: 2,
                              ),
                              image: const DecorationImage(
                                image: AssetImage("assets/images/background/image1.png"),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Column(
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "@smith",
                                    style: TextStyle(
                                      fontFamily: 'KadawBold',
                                      fontSize: 15
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                  Icon(Icons.verified, color: Colors.blue, size: 16),
                                ],
                              ),
                              Text("Brain Smith", style: TextStyle(fontSize: 15, color: Colors.grey, fontFamily: 'Kadaw',),)
                            ],
                          ),
                          const Spacer(),
                          Image.asset("assets/images/icons/reference.png"),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavBar(currentIndex: _currentIndex),
      ),
    );
  }
}

