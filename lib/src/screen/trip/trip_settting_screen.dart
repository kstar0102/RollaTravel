import 'package:RollaTravel/src/constants/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:RollaTravel/src/utils/index.dart';
import 'package:RollaTravel/src/widget/bottombar.dart';

class TripSetttingScreen extends StatefulWidget {
  const TripSetttingScreen({super.key});

  @override
  TripSetttingScreenState createState() => TripSetttingScreenState();
}

class TripSetttingScreenState extends State<TripSetttingScreen> {
  int _privacySelected = 0;
  int _mapStyleSelected = 2;
  int _selectedUnit = 1;
  final int _currentIndex = 5;

  Widget _buildRadioOption(
      String label, int value, int groupValue, Function(int) onChanged) {
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13, 
                fontWeight: FontWeight.w500,
                letterSpacing: -0.1,
                fontFamily: "inter"),
            ),
            Radio<int>(
              value: value,
              groupValue: groupValue,
              activeColor: kColorHereButton,
              onChanged: (int? newValue) => onChanged(newValue!),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildunitsOption(
      String label, int value, int groupValue, Function(int) onChanged) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, letterSpacing: -0.1, fontFamily: "inter"),
        ),
        Radio<int>(
          value: value,
          groupValue: groupValue,
          activeColor: Colors.blue, // Blue for selected state
          onChanged: (int? newValue) => onChanged(newValue!),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kColorWhite,
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            return; // Prevent pop action
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
             Padding(
              padding: const EdgeInsets.only(top: 30.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start, // Keep the close button aligned to the left
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, size: 25),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  // Center the icon and text together
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center, // Center the icon and text
                      children: [
                        Image.asset(
                          'assets/images/icons/setting.png',
                          height: vhh(context, 2.5),
                        ),
                        const SizedBox(width: 5), // Spacing between icon and text
                        const Text(
                          'Trip Settings',
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.1,
                            fontFamily: "inter",
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20,)
                ],
              ),
            ),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: Divider(
                  thickness: 1.2,
                  color: kColorStrongGrey,
                ),
              ),

              const Text(
                'Privacy',
                style: TextStyle(
                  fontSize: 17, 
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.1,
                  fontFamily: "inter"),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 6),
              const Padding(
                padding: EdgeInsets.only(left: 5),
                child: Text(
                  'Delay display of dropped pins on my map for:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    letterSpacing: -0.1,
                    fontFamily: "inter",
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Privacy radio buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildRadioOption('0 mins', 0, _privacySelected, (value) {
                    setState(() => _privacySelected = value);
                  }),
                  _buildRadioOption('30 mins', 1, _privacySelected, (value) {
                    setState(() => _privacySelected = value);
                  }),
                  _buildRadioOption('2 hrs', 2, _privacySelected, (value) {
                    setState(() => _privacySelected = value);
                  }),
                  _buildRadioOption('12 hrs', 3, _privacySelected, (value) {
                    setState(() => _privacySelected = value);
                  }),
                ],
              ),

              const SizedBox(height: 30),

              // Map Style Section
              const Text(
                'Map Style',
                style: TextStyle(
                  fontSize: 17, 
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.1,
                  fontFamily: "inter"),
              ),

              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(4, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      children: [
                        Container(
                          height: vhh(context, 10),
                          width: vww(context, 18),
                          color:
                              Colors.grey[300], // Placeholder for the map image
                        ),
                        Radio<int>(
                          value: index,
                          groupValue: _mapStyleSelected,
                          activeColor: kColorHereButton,
                          onChanged: (value) {
                            setState(() {
                              _mapStyleSelected = value!;
                            });
                          },
                        ),
                      ],
                    ),
                  );
                }),
              ),

              const SizedBox(height: 30),
              const Text(
                'Units of distance',
                style: TextStyle(
                  fontSize: 17, 
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.1,
                  fontFamily: "inter"),
              ),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceAround, // Distribute items evenly
                  children: [
                    _buildunitsOption("Miles", 0, _selectedUnit, (value) {
                      setState(() => _selectedUnit = value);
                    }),
                    _buildunitsOption("Kilometers", 1, _selectedUnit, (value) {
                      setState(() => _selectedUnit = value);
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: _currentIndex),
    );
  }
}
