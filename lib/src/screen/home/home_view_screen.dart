import 'package:RollaTravel/src/services/api_service.dart';
import 'package:RollaTravel/src/utils/index.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class HomeViewScreen extends StatefulWidget {
  final String viewdList;
  final String imagePath;

  const HomeViewScreen(
      {super.key, required this.viewdList, required this.imagePath});

  @override
  HomeViewScreenState createState() => HomeViewScreenState();
}

class HomeViewScreenState extends State<HomeViewScreen> {
  List<dynamic> viewdUsers = [];
  bool isLoading = true;
  final logger = Logger();

  @override
  void initState() {
    super.initState();
    _fetchUsersFromViewlist(widget.viewdList);
    logger.i(widget.imagePath);
  }

  Future<void> _fetchUsersFromViewlist(String viewlist) async {
    final userIds = viewlist.split(',');
    final apiService = ApiService();

    try {
      final userData = await Future.wait(userIds.map((userId) async {
        try {
          final response = await apiService.fetchUserTrips(int.parse(userId));
          if (response.isNotEmpty && response[0]['user'] != null) {
            return response[0]['user'];
          } else {
            logger.e("User data not found for userId: $userId");
            return {}; // Return an empty map if no user data found
          }
        } catch (e) {
          logger.e("Error fetching user data for userId: $userId. Error: $e");
          return {}; // Return an empty map in case of an error
        }
      }));

      setState(() {
        viewdUsers = userData.where((user) => user.isNotEmpty).toList();
        isLoading = false; // Set loading to false after data is fetched
      });

      logger.i(viewdUsers);
    } catch (e) {
      setState(() {
        isLoading = false; // Set loading to false even if an error occurs
      });
      logger.e("Error fetching users: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(
                context); // This will pop the current screen and go back
          },
        ),
        // title is set to null to remove it
        title: null,
      ),
      body: Column(
        children: [
          Image.network(
            widget.imagePath,
            fit: BoxFit.cover,
            width: double.infinity,
            height: 300,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF933F10),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${viewdUsers.length} Views', // Display the number of views
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  letterSpacing: -0.1,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ),
          const Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16.0), // Set horizontal padding
            child: Divider(
              height: 1,
              color: Colors.grey,
            ),
          ),

          if (isLoading) const Center(child: CircularProgressIndicator()),

          // Display users in a list after data is loaded
          if (!isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16.0, vertical: 10), // Add horizontal padding
              child: LikedUsersList(likedUsers: viewdUsers),
            ),
        ],
      ),
    );
  }
}

class LikedUsersList extends StatelessWidget {
  final List<dynamic> likedUsers;

  const LikedUsersList({super.key, required this.likedUsers});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: likedUsers.map((user) {
        final photo = user['photo'] ?? '';
        final firstName = user['first_name'] ?? 'Unknown';
        final lastName = user['last_name'] ?? '';
        final username = user['rolla_username'] ?? '@unknown';

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: Colors.grey,
                    width: 2,
                  ),
                  image: photo.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(photo),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child:
                    photo.isEmpty ? const Icon(Icons.person, size: 20) : null,
              ),
              const SizedBox(width: 5),
              // Name and Username
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '@ $username',
                        style: const TextStyle(
                            fontSize: 13,
                            letterSpacing: -0.1,
                            color: Colors.black,
                            fontFamily: 'inter',
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Image.asset(
                        'assets/images/icons/verify.png',
                        width: vww(context, 5),
                        height: 20,
                      ),
                    ],
                  ),
                  Text(
                    '$firstName $lastName',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      letterSpacing: -0.1,
                      fontFamily: 'inter',
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
