import 'package:RollaStrava/src/constants/app_styles.dart';
import 'package:RollaStrava/src/translate/en.dart';
import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  BottomNavBar({required this.currentIndex});

  void onTabTapped(BuildContext context, int index) {
    if (index == currentIndex) return;
    switch (index) {
      case 0:
        // Navigation logic for HomePage
        break;
      case 1:
        // Navigation logic for SearchPage
        break;
      case 2:
        // Navigation logic for the central button
        break;
      case 3:
        // Navigation logic for DroppingPage
        break;
      case 4:
        // Navigation logic for ProfilePage
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.white,
      child: Container(
        height: 80,
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: kColorBlack, width: 2), // Black line at the very top
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: InkWell(
                onTap: () => onTabTapped(context, 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      bottom_home,
                      style: TextStyle(
                        color: currentIndex == 0 ? kColorBlack : kColorButtonPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () => onTabTapped(context, 1),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      bottom_search,
                      style: TextStyle(
                        color: currentIndex == 1 ? kColorBlack : kColorButtonPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () => onTabTapped(context, 2),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.blue,
                          width: 2.0,
                        ),
                      ),
                      child: const Icon(
                        Icons.directions_car,
                        color: kColorBlack,
                        size: 30,
                      ),
                    ),
                    if (currentIndex == 2)
                      Container(
                        margin: EdgeInsets.only(top: 5),
                        height: 3,
                        width: 40,
                        color: kColorBlack,
                      ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () => onTabTapped(context, 3),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      bottom_drop_pin,
                      style: TextStyle(
                        color: currentIndex == 3 ? kColorBlack : kColorButtonPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () => onTabTapped(context, 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: currentIndex == 4 ? Colors.blue : Colors.grey,
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: const Image(
                          fit: BoxFit.cover,
                          image: AssetImage("assets/images/background/2.png"),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
