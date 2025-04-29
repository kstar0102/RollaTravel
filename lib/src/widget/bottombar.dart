// import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:RollaTravel/src/constants/app_styles.dart';
import 'package:RollaTravel/src/screen/droppin/drop_pin.dart';
import 'package:RollaTravel/src/screen/droppin/photo_select_screen.dart';
import 'package:RollaTravel/src/screen/home/home_screen.dart';
import 'package:RollaTravel/src/screen/profile/profile_screen.dart';
import 'package:RollaTravel/src/screen/search/search_%20screen.dart';
import 'package:RollaTravel/src/screen/trip/start_trip.dart';
import 'package:RollaTravel/src/translate/en.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:RollaTravel/src/utils/global_variable.dart';

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
            pageBuilder: (context, animation1, animation2) =>
                const HomeScreen(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) =>
                const SearchScreen(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) =>
                const StartTripScreen(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
        break;
      case 3:
        if (!isTripStarted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DropPinScreen()),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PhotoSelectScreen()),
          );
        }
        break;
      case 4:
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) =>
                const ProfileScreen(),
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
     return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          height: 1,
          color: kColorStrongGrey,
        ),
        SafeArea(
          top: false,
          bottom: false,
          child: BottomAppBar(
             height: 81,
            color: Colors.white,
            elevation: 1,
            child: SizedBox(
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  buildTab(context, ref, bottom_home, 0),
                  buildTab(context, ref, bottom_search, 1),
                  buildCarTab(context, ref, 2),
                  buildTab(context, ref, bottom_drop_pin, 3),
                  buildProfileTab(context, ref, 4),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildCarTab(BuildContext context, WidgetRef ref, int index) {
    return Expanded(
      child: InkWell(
        onTap: () => onTabTapped(context, ref, index),
        child: Center(
          child: SizedBox(
            width: 65,
            height: 65,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22.5),
              child: const Image(
                fit: BoxFit.cover,
                image: AssetImage("assets/images/icons/car_bottom_icon.png"),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTab(BuildContext context, WidgetRef ref, String text, int index) {
    return Expanded(
      child: InkWell(
        onTap: () => onTabTapped(context, ref, index),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 17,
              fontFamily: 'inter',
              fontWeight: FontWeight.bold,
              color: currentIndex == index ? kColorHereButton : kColorBlack,
            ),
          ),
        ),
      ),
    );
  }
  Widget buildProfileTab(BuildContext context, WidgetRef ref, int index) {
    return Expanded(
      child: InkWell(
        onTap: () => onTabTapped(context, ref, index),
        child: Center(
          child: Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              border: Border.all(
                color: currentIndex == index ? kColorHereButton : Colors.grey,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(50),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: GlobalVariables.userImageUrl != null
                  ? Image.network(
                      GlobalVariables.userImageUrl!,
                      width: 45,
                      height: 45,
                      fit: BoxFit.cover,
                    )
                  : const Icon(Icons.person),
            ),
          ),
        ),
      ),
    );
  }
}
