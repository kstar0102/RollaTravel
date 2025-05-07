import 'package:RollaTravel/src/constants/app_styles.dart';
// import 'package:RollaTravel/src/screen/trip/start_trip.dart';
import 'package:RollaTravel/src/utils/global_variable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:RollaTravel/src/widget/bottombar.dart';
import 'package:RollaTravel/src/utils/index.dart';

class SoundScreen extends ConsumerStatefulWidget {
  const SoundScreen({super.key});

  @override
  ConsumerState<SoundScreen> createState() => SoundScreenState();
}

class SoundScreenState extends ConsumerState<SoundScreen> {
  final int _currentIndex = 2;
  final TextEditingController _soundController1 = TextEditingController();
  final TextEditingController _soundController2 = TextEditingController();
  final TextEditingController _soundController3 = TextEditingController();
  final TextEditingController _soundController4 = TextEditingController();

  @override
  void initState() {
    super.initState();
    if(GlobalVariables.song1 != null) {
      _soundController1.text = GlobalVariables.song1!;
    }
    if(GlobalVariables.song2 != null) {
      _soundController2.text = GlobalVariables.song1!;
    }
    if(GlobalVariables.song3 != null) {
      _soundController3.text = GlobalVariables.song1!;
    }
    if(GlobalVariables.song4 != null) {
      _soundController4.text = GlobalVariables.song1!;
    }
  }

  @override
  void dispose() {
    _soundController1.dispose();
    _soundController2.dispose();
    _soundController3.dispose();
    _soundController4.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          return;
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Row(
                children: [
                  const SizedBox(width: 16),
                  InkWell(
                    onTap: () {
                      if (_soundController1.text.isNotEmpty) {
                        GlobalVariables.song1 = _soundController1.text;
                      }

                      if (_soundController2.text.isNotEmpty) {
                        GlobalVariables.song2 = _soundController2.text;
                      }

                      if (_soundController3.text.isNotEmpty) {
                        GlobalVariables.song3 = _soundController3.text;
                      }

                      if (_soundController4.text.isNotEmpty) {
                        GlobalVariables.song4 = _soundController4.text;
                      }
                      Navigator.pop(context);
                    },
                    child: Image.asset(
                      'assets/images/icons/allow-left.png',
                      width: vww(context, 7),
                      height: 23,
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'My Soundtrack',
                        style: TextStyle(
                          fontSize: 22,
                          fontFamily: 'inter',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    _buildSongTextField(_soundController1, 1),
                    const SizedBox(height: 20),
                    _buildSongTextField(_soundController2, 2),
                    const SizedBox(height: 20),
                    _buildSongTextField(_soundController3, 3),
                    const SizedBox(height: 20),
                    _buildSongTextField(_soundController4, 4),
                    const SizedBox(height: 40),
                    const Text(
                      "Write the song title, or paste the link to the track you want to share. Limit of 4 songs/post on Rolla.",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontFamily: 'inter',
                        letterSpacing: -0.1
                      ),
                      textAlign: TextAlign.center
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavBar(currentIndex: _currentIndex),
      ),
    );
  }

  Widget _buildSongTextField(TextEditingController controller, int index) {
    Color borderColor = (index % 2 == 0) ? kColorHereButton : kColorButtonPrimary;

    return SizedBox(
      height: 35.0,  // Set the desired height for the TextField
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: 'Song $index',
          hintText: 'Write song title or paste the link',
          hintStyle: const TextStyle(fontSize: 13, fontFamily: 'inter'),
          contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide(color: borderColor, width: 2.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide(color: borderColor, width: 2.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide(color: borderColor, width: 2.0),
          ),
          filled: true,
          fillColor: Colors.white,  // White background
        ),
        style: const TextStyle(fontSize: 13, fontFamily: 'inter', letterSpacing: -0.1),
      ),
    );
  }

}
