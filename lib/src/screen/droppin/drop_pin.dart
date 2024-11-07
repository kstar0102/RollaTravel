import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:RollaStrava/src/widget/bottombar.dart';
import 'package:RollaStrava/src/utils/index.dart';

class DropPinScreen extends ConsumerStatefulWidget {
  const DropPinScreen({super.key});
  @override
  ConsumerState<DropPinScreen> createState() => DropPinScreenState();
}

class DropPinScreenState extends ConsumerState<DropPinScreen> {
  double screenHeight = 0;
  double keyboardHeight = 0;
  final int _currentIndex = 3;

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
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    return false;
  }

  Widget buildInstructionItem(int number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$number. ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: WillPopScope(
        onWillPop: _onWillPop,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: vhh(context, 3),),
              // Logo at the top
              Align(
                alignment: Alignment.topLeft,
                child: Image.asset(
                  'assets/images/icons/logo.png',
                  width: vww(context, 20),
                ),
              ),
              SizedBox(height: vhh(context, 10)),
              
              // Note text
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0), // Adjust the value as needed
                child: Text(
                  'Note: You must start trip under the \u{1F698} button before you can drop a pin and post your map.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: vhh(context, 10)),
              
              // Instructions list
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildInstructionItem(1, 'Navigate to \u{1F698} button.'),
                  buildInstructionItem(2, 'Tap "Start Trip".'),
                  buildInstructionItem(3, 'Navigate back here, to the "Drop Pin" tab.'),
                  buildInstructionItem(4, 'Upload photo and drop it on your map.'),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: _currentIndex),
    );
  }

}