import 'package:RollaTravel/src/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:RollaTravel/src/utils/index.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:RollaTravel/src/widget/bottombar.dart';
import 'package:logger/logger.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => SearchScreenState();
}

class SearchScreenState extends ConsumerState<SearchScreen> {
  double screenHeight = 0;
  double keyboardHeight = 0;
  final int _currentIndex = 1;
  List<dynamic> allDropPinData = [];
  bool isLoading = false; // ✅ Add loading state
  final TextEditingController _searchDropPin = TextEditingController();
  final logger = Logger();

  @override
  void initState() {
    super.initState();
    getAllData();
  }

  @override
  void dispose() {
    super.dispose();
    _searchDropPin.dispose();
  }

  void getAllData() async {
    setState(() {
      isLoading = true; // ✅ Show loading before fetching data
    });

    final authService = ApiService();
    try {
      final response = await authService.fetchAllDropPinData();

      if (response["status"] == "success" && response.containsKey("data")) {
        List<dynamic> fetchedResults = response["data"];
        setState(() {
          allDropPinData = fetchedResults;
          isLoading = false; // ✅ Hide loading after fetching data
        });
        logger.i(allDropPinData);
      } else {
        logger.e("Failed to fetch search results.");
        setState(() {
          isLoading = false; // ✅ Ensure loading is hidden on failure
        });
      }
    } catch (e) {
      logger.e("Error fetching search data: $e");
      setState(() {
        isLoading = false; // ✅ Ensure loading is hidden if an error occurs
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevents default back navigation
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          return; // Prevent pop action
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
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
                    Image.asset('assets/images/icons/logo.png',
                        height: vhh(context, 12)),
                    IconButton(
                      icon: const Icon(Icons.search, size: 35),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              // ✅ Show Loading Indicator
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                )
              else ...[
                SizedBox(
                  height: 30,
                  width: vww(context, 90),
                  child: TextField(
                    controller: _searchDropPin,
                    decoration: InputDecoration(
                      hintText: 'Search user accounts',
                      hintStyle: const TextStyle(
                        fontSize: 15,
                        fontFamily: 'Kadaw',
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 0.0, horizontal: 16.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4.0),
                        borderSide:
                            const BorderSide(color: Colors.black, width: 1.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4.0),
                        borderSide:
                            const BorderSide(color: Colors.black, width: 1.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4.0),
                        borderSide:
                            const BorderSide(color: Colors.black, width: 1.0),
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                    style: const TextStyle(
                      fontSize: 15,
                      fontFamily: 'Kadaw',
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        bottomNavigationBar: BottomNavBar(currentIndex: _currentIndex),
      ),
    );
  }
}
