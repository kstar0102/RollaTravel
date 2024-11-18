import 'package:flutter/material.dart';
import 'package:RollaStrava/src/utils/index.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:RollaStrava/src/widget/bottombar.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => SearchScreenState();
}

class SearchScreenState extends ConsumerState<SearchScreen> {
  double screenHeight = 0;
  double keyboardHeight = 0;
  final int _currentIndex = 1;
  final TextEditingController _searchAccount = TextEditingController();
  final TextEditingController _searchDestination = TextEditingController();

  @override
  void initState() {
    super.initState();
    // _soundController = TextEditingController(text: widget.initialSound);
  }

  @override
  void dispose() {
    super.dispose();
    _searchAccount.dispose();
    _searchDestination.dispose();
  }

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
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset('assets/images/icons/logo.png', height: vhh(context, 12)),
                    IconButton(
                      icon: const Icon(Icons.search, size: 35),
                      onPressed: () {
                        // Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: TextField(
                  controller: _searchAccount,
                  decoration: InputDecoration(
                    hintText: 'Search user accounts',
                    hintStyle: const TextStyle(fontSize: 16), // Set font size for hint text
                    contentPadding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0), // Reduce inner padding
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4.0),
                      borderSide: const BorderSide(color: Colors.black, width: 1.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4.0),
                      borderSide: const BorderSide(color: Colors.black, width: 1.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4.0),
                      borderSide: const BorderSide(color: Colors.black, width: 1.0),
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: TextField(
                  controller: _searchAccount,
                  decoration: InputDecoration(
                      hintText: 'Search Destinations',
                      hintStyle: const TextStyle(fontSize: 16), // Set font size for hint text
                      contentPadding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 16.0), // Set inner padding
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4.0),
                        borderSide: const BorderSide(color: Colors.black, width: 1.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4.0),
                        borderSide: const BorderSide(color: Colors.black, width: 1.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4.0),
                        borderSide: const BorderSide(color: Colors.black, width: 1.0),
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                    style: const TextStyle(fontSize: 16),
                ),
              ),
                  
              
            ]
          ),
        ),
        bottomNavigationBar: BottomNavBar(currentIndex: _currentIndex),
      ), 
    );
  }
}