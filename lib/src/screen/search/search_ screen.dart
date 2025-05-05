import 'package:RollaTravel/src/constants/app_styles.dart';
import 'package:RollaTravel/src/screen/home/home_user_screen.dart';
import 'package:RollaTravel/src/services/api_service.dart';
import 'package:RollaTravel/src/utils/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:RollaTravel/src/widget/bottombar.dart';
import 'package:logger/logger.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> with SingleTickerProviderStateMixin {
  final int _currentIndex = 1;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final logger = Logger();
  
  bool isLoading = false;
  List<dynamic> allDropPinData = [];
  List<dynamic> filteredDropPinData = [];
  List<dynamic> allUserData = [];
  List<dynamic> filteredUserData = [];
  bool isUserDataFetched = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterResults);
    getAllUserData();
  }

  @override
  void dispose() {
    // _tabController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  // void _handleTabChange() {
  //   if (_tabController.index == 1 && !isUserDataFetched) {
  //     getAllUserData();
  //   } else {
  //     _filterResults();
  //   }
  // }

  // Future<void> getAllDropPinData() async {
  //   setState(() => isLoading = true);
  //   final authService = ApiService();

  //   try {
  //     final response = await authService.fetchAllDropPinData();
  //     if (response["status"] == "success" && response.containsKey("data")) {
  //       setState(() {
  //         allDropPinData = response["data"];
  //         filteredDropPinData = response["data"];
  //         isLoading = false;
  //       });
  //     } else {
  //       logger.e("Failed to fetch DropPin data.");
  //       setState(() => isLoading = false);
  //     }
  //   } catch (e) {
  //     logger.e("Error fetching DropPin data: $e");
  //     setState(() => isLoading = false);
  //   }
  // }

  Future<void> getAllUserData() async {
    setState(() => isLoading = true);
    final authService = ApiService();

    try {
      final response = await authService.fetchAllUserData();
      if (response.containsKey("status") && response.containsKey("data")) {
        setState(() {
          allUserData = response["data"];
          filteredUserData = response["data"];
          isUserDataFetched = true;
          isLoading = false;
        });
      } else {
        logger.e("Failed to fetch user data.");
        setState(() => isLoading = false);
      }
    } catch (e) {
      logger.e("Error fetching user data: $e");
      setState(() => isLoading = false);
    }
  }

  void _filterResults() {
    String query = _searchController.text.toLowerCase();

    setState(() {
      // if (_tabController.index == 0) {
      //   filteredDropPinData = allDropPinData.where((dropPin) {
      //     final user = dropPin['user'];
      //     final imageCaption = dropPin['image_caption'] ?? '';
      //     final userName = '${user['first_name']} ${user['last_name']}';

      //     return userName.toLowerCase().contains(query) ||
      //         imageCaption.toLowerCase().contains(query);
      //   }).toList();
      // } else {
        filteredUserData = allUserData.where((user) {
          final fullName = '${user['first_name']} ${user['last_name']}';
          final email = user['email'] ?? '';
          return fullName.toLowerCase().contains(query) ||
              email.toLowerCase().contains(query);
        }).toList();
      // }
    });
  }

  // void _showImageDialog(String imagePath) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return Dialog(
  //         insetPadding: const EdgeInsets.symmetric(horizontal: 30),
  //         shape:
  //             RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           crossAxisAlignment: CrossAxisAlignment.center,
  //           children: [
  //             Image.network(
  //               imagePath,
  //               fit: BoxFit.cover,
  //               width: MediaQuery.of(context).size.width * 0.9,
  //               height: MediaQuery.of(context).size.height * 0.5,
  //               errorBuilder: (context, error, stackTrace) =>
  //                   const Icon(Icons.broken_image, size: 100),
  //               loadingBuilder: (context, child, loadingProgress) {
  //                 if (loadingProgress == null) {
  //                   return child;
  //                 } else {
  //                   return Center(
  //                     child: CircularProgressIndicator(
  //                       value: loadingProgress.expectedTotalBytes != null
  //                           ? loadingProgress.cumulativeBytesLoaded /
  //                               (loadingProgress.expectedTotalBytes ?? 1)
  //                           : null,
  //                     ),
  //                   );
  //                 }
  //               },
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset('assets/images/icons/logo.png',
                    height: vhh(context, 12)),
                IconButton(
                    icon: const Icon(Icons.search, size: 37), onPressed: () {}),
              ],
            ),
          ),
          // TabBar(
          //   controller: _tabController,
          //   labelColor: Colors.black,
          //   unselectedLabelColor: Colors.grey,
          //   labelStyle: const TextStyle(
          //     fontFamily: 'inter',
          //     fontSize: 16,
          //     letterSpacing: -0.1,
          //     fontWeight: FontWeight.bold,
          //   ),
          //   indicator: const UnderlineTabIndicator(
          //     borderSide: BorderSide(
          //       width: 3, // Thickness of the underline
          //       color: kColorHereButton, // Green underline color
          //     ),
          //   ),
          //   tabs: const [
          //     Tab(text: ' DropPins '),
          //     Tab(text: ' Users '),
          //   ],
          // ),
          // const SizedBox(
          //   height: 15,
          // ),
          SizedBox(
            height: 40,
            width: vww(context, 90),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode, 
              decoration: InputDecoration(
                hintText: 'Search ...',
                hintStyle: const TextStyle(
                  fontSize: 15,
                  fontFamily: 'inter',
                  letterSpacing: -0.1,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
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
              style: const TextStyle(
                fontSize: 15,
                fontFamily: 'inter',
                letterSpacing: -0.1,
              ),
              textInputAction: TextInputAction.done,
              onEditingComplete: () {
                _searchFocusNode.unfocus();
              },
            ),
          ),
          isLoading
              ? const Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                )
              : Expanded(
                 child: _buildUserList(),
                  // child: TabBarView(
                  //   // controller: _tabController,
                  //   children: [
                  //     // _buildDropPinList(),
                  //     _buildUserList(),
                  //   ],
                  // ),
                ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: _currentIndex),
    );
  }

  // Widget _buildDropPinList() {
  //   return ListView.builder(
  //     itemCount: filteredDropPinData.length,
  //     itemBuilder: (context, index) {
  //       final dropPin = filteredDropPinData[index];
  //       final user = dropPin['user'];
  //       final imagePath = dropPin['image_path'];
  //       final imageCaption = dropPin['image_caption'];
  //       final createdAt = DateTime.parse(dropPin['created_at']);
  //       final formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(createdAt);
  //       return Padding(
  //         padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 20.0),
  //         child: GestureDetector(
  //           onTap: () {
  //             _showImageDialog(imagePath);
  //           },
  //           child: Container(
  //             decoration: BoxDecoration(
  //               color: Colors.grey[100],
  //               borderRadius: BorderRadius.circular(10),
  //               border: Border.all(color: kColorGrey, width: 0.5),
  //             ),
  //             padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
  //             child: Row(
  //               children: [
  //                 // Image
  //                 ClipRRect(
  //                   borderRadius: BorderRadius.circular(8.0),
  //                   child: Image.network(
  //                     imagePath,
  //                     width: 60,
  //                     height: 60,
  //                     fit: BoxFit.cover,
  //                     errorBuilder: (context, error, stackTrace) =>
  //                         const Icon(Icons.broken_image, size: 60),
  //                     loadingBuilder: (context, child, loadingProgress) {
  //                       if (loadingProgress == null) {
  //                         return child;
  //                       } else {
  //                         return Center(
  //                           child: CircularProgressIndicator(
  //                             value: loadingProgress.expectedTotalBytes != null
  //                                 ? loadingProgress.cumulativeBytesLoaded /
  //                                     (loadingProgress.expectedTotalBytes ?? 1)
  //                                 : null,
  //                           ),
  //                         );
  //                       }
  //                     },
  //                   ),
  //                 ),

  //                 const SizedBox(width: 12),
  //                 Expanded(
  //                   child: Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       // User Name
  //                       Text(
  //                         '${user?['first_name'] ?? ''} ${user?['last_name'] ?? ''}',
  //                         style: const TextStyle(
  //                           fontSize: 16,
  //                           fontWeight: FontWeight.bold,
  //                           fontFamily: 'inter',
  //                           letterSpacing: -0.1,
  //                         ),
  //                       ),

  //                       const SizedBox(height: 4),
  //                       Text(
  //                         imageCaption,
  //                         style: const TextStyle(
  //                           fontSize: 14,
  //                           fontFamily: 'inter',
  //                           letterSpacing: -0.1,
  //                         ),
  //                       ),
  //                       const SizedBox(height: 4),
  //                       Text(
  //                         formattedDate,
  //                         style: const TextStyle(
  //                           fontSize: 12,
  //                           color: Colors.grey,
  //                           fontFamily: 'inter',
  //                           letterSpacing: -0.1,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  Widget _buildUserList() {
    return ListView.builder(
      itemCount: filteredUserData.length,
      itemBuilder: (context, index) {
        final user = filteredUserData[index];
        final fullName = '${user['first_name']} ${user['last_name']}';
        // final email = user['email'];
        final userImageUrl = user['photo'];
        // final createdAt = DateTime.parse(user['created_at']);
        // final formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(createdAt);
        final userid = user['id'];
        final rollaUsername = user['rolla_username'];

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 20.0),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => HomeUserScreen(
                          userId: userid,
                        )),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: kColorGrey, width: 0.6),
              ),
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              child: Row(
                children: [
                  // Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: userImageUrl != null && userImageUrl.isNotEmpty
                        ? Image.network(
                            userImageUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.broken_image,
                                    size: 60, color: Colors.grey),
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              } else {
                                return SizedBox(
                                  width: 60,
                                  height: 60,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  (loadingProgress
                                                          .expectedTotalBytes ??
                                                      1)
                                              : null,
                                    ),
                                  ),
                                );
                              }
                            },
                          )
                        : const Icon(Icons.person,
                            size: 60, color: Colors.grey),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          fullName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.1,
                            fontFamily: 'inter',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "@$rollaUsername",
                          style: const TextStyle(
                            fontSize: 14,
                            letterSpacing: -0.1,
                            fontFamily: 'inter',
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Text(
                        //   formattedDate,
                        //   style: const TextStyle(
                        //     fontSize: 12,
                        //     color: Colors.grey,
                        //     letterSpacing: -0.1,
                        //     fontFamily: 'inter',
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
