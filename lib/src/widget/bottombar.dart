import 'package:RollaStrava/src/constants/app_styles.dart';
import 'package:RollaStrava/src/screen/droppin/drop_pin.dart';
import 'package:RollaStrava/src/screen/droppin/photo_select_screen.dart';
import 'package:RollaStrava/src/screen/home/home_screen.dart';
import 'package:RollaStrava/src/screen/profile/profile_screen.dart';
import 'package:RollaStrava/src/screen/search/search_%20screen.dart';
import 'package:RollaStrava/src/screen/trip/start_trip.dart';
import 'package:RollaStrava/src/translate/en.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:RollaStrava/src/utils/global_variable.dart';

class BottomNavBar extends ConsumerWidget {
  final int currentIndex;

  const BottomNavBar({required this.currentIndex, super.key});

  void onTabTapped(BuildContext context, WidgetRef ref, int index) {
    final isTripStarted = ref.watch(isTripStartedProvider);
    if (index == currentIndex) return;
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => const HomeScreen(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => const SearchScreen(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => const StartTripScreen(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
        break;
      case 3:
        if (!isTripStarted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DropPinScreen()),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PhotoSelectScreen()),
          );
        }
        break;
      case 4:
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => const ProfileScreen(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: BottomAppBar(
        color: Colors.white,
        child: Container(
          height: 100,
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
                  onTap: () => onTabTapped(context, ref, 0),
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
                  onTap: () => onTabTapped(context, ref, 1),
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
                  onTap: () => onTabTapped(context, ref, 2),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 50,
                        height: 50,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: const Image(
                            fit: BoxFit.cover,
                            image: AssetImage("assets/images/icons/home.png"),
                            width: 50,
                            height: 50,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () => onTabTapped(context, ref, 3),
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
                  onTap: () => onTabTapped(context, ref, 4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
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
                            image: AssetImage("assets/images/background/image2.png"),
                            width: 45,
                            height: 45,
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
      ),
    );
  }
}