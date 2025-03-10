import 'package:RollaTravel/src/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:RollaTravel/src/utils/index.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:RollaTravel/src/widget/bottombar.dart';
import 'package:intl/intl.dart';
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
  List<dynamic> filteredDropPinData = []; // List to store filtered results
  bool isLoading = false; // ✅ Add loading state
  final TextEditingController _searchDropPin = TextEditingController();
  final logger = Logger();

  @override
  void initState() {
    super.initState();
    getAllData();
    _searchDropPin.addListener(_filterResults); // Add listener for search input
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
          filteredDropPinData = fetchedResults; // Initialize with all data
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

  // Function to filter results based on search query
  void _filterResults() {
    String query = _searchDropPin.text.toLowerCase();

    setState(() {
      filteredDropPinData = allDropPinData.where((dropPin) {
        final user = dropPin['user'];
        final imageCaption = dropPin['image_caption'] ?? '';
        final userName = '${user['first_name']} ${user['last_name']}';

        // Check if any of the fields match the search query
        return userName.toLowerCase().contains(query) ||
            imageCaption.toLowerCase().contains(query);
      }).toList();
    });
  }

  // Function to show image in a dialog
  void _showImageDialog(String imagePath) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 30),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Image in the dialog
              Image.network(
                imagePath,
                fit: BoxFit.cover,
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.5,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image, size: 100),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    // Image has finished loading
                    return child;
                  } else {
                    // Show a loading indicator while the image loads
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                (loadingProgress.expectedTotalBytes ?? 1)
                            : null,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
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
                      hintText: 'Search DropPins...',
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
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredDropPinData.length,
                    itemBuilder: (context, index) {
                      final dropPin = filteredDropPinData[index];
                      final user = dropPin['user'];
                      final imagePath = dropPin['image_path'];
                      final imageCaption = dropPin['image_caption'];
                      final createdAt = DateTime.parse(dropPin['created_at']);
                      final formattedDate =
                          DateFormat('yyyy-MM-dd HH:mm').format(createdAt);

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4.0, horizontal: 17.0),
                        child: GestureDetector(
                          onTap: () {
                            // Show the image in a dialog when tapped
                            _showImageDialog(imagePath);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[100], // Gray background
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey, width: 1),
                            ),
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                // Image
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.network(
                                    imagePath,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(Icons.broken_image,
                                                size: 60),
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) {
                                        // Image has finished loading
                                        return child;
                                      } else {
                                        // Show a loading indicator while the image loads
                                        return Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    (loadingProgress
                                                            .expectedTotalBytes ??
                                                        1)
                                                : null,
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ),

                                const SizedBox(width: 12),
                                // User Info and Caption
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // User Name
                                      Text(
                                        '${user['first_name']} ${user['last_name']}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      // Caption
                                      Text(
                                        imageCaption,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      const SizedBox(height: 4),
                                      // Created At
                                      Text(
                                        formattedDate,
                                        style: const TextStyle(
                                            fontSize: 12, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
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
