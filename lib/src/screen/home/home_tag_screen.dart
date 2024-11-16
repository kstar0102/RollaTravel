import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeTagScreen extends ConsumerStatefulWidget  {
  const HomeTagScreen({super.key});

  @override
   ConsumerState<HomeTagScreen> createState() => HomeTagScreenState();
}

class HomeTagScreenState extends ConsumerState<HomeTagScreen> {
  Future<bool> _onWillPop() async {
    return false;
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: Stack(
          children: [
            Positioned(
              top: 50,
              left: 20,
              child: Text(
                'Rolla',
                style: TextStyle(
                  fontFamily: 'Cursive',
                  fontSize: 24,
                ),
              ),
            ),
            Positioned.fill(
              child: Align(
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Users tagged in this post',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    Icon(
                      Icons.directions_car, // You can replace this with your car icon
                      size: 50,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 50,
              right: 20,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context); // Handle close button logic
                },
                child: Icon(
                  Icons.close,
                  size: 24,
                ),
              ),
            ),
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Divider(
                color: Colors.black,
                thickness: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

