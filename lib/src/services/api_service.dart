import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class ApiService {
  static const String baseUrl = 'http://16.171.153.11/api';
  // static const String baseUrl = 'http://192.168.141.105:8000/api';
  String apiKey = 'cfdb0e89363c14687341dbc25d1e1d43';
  final logger = Logger();

  Future<List<Map<String, dynamic>>> fetchAllTrips() async {
    final url = Uri.parse('$baseUrl/trip/data');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['message'] == 'All trips retrieved successfully') {
        return List<Map<String, dynamic>>.from(data['trips']);
      } else {
        throw Exception('Failed to fetch trips: ${data['message']}');
      }
    } else {
      throw Exception('Failed to fetch trips: ${response.statusCode}');
    }
  }

  Future<List<dynamic>> fetchCarData() async {
    final url = Uri.parse('$baseUrl/car_types');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      } else {
        throw Exception('Failed to load car data');
      }
    } catch (e) {
      throw Exception('Error fetching car data: $e');
    }
  }

  /// Function to login
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'identifier': email, 'password': password}),
      );
      final Map<String, dynamic> parsedResponse = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': parsedResponse['message'] ?? 'Unknown error occurred',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      logger.e('Error: $e');
      return {
        'success': false,
        'message': 'An error occurred. Please try again later.',
      };
    }
  }

  Future<String> getImageUrl(String base64) async {
    var url = Uri.parse('https://api.imgbb.com/1/upload');
    var response = await http.post(url, body: {
      'key': apiKey,
      'image': base64,
    });
    logger.i(jsonDecode(response.body)['data']['url']);
    return jsonDecode(response.body)['data']['url'];
  }

  Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String rollaUsername,
    required String hearRolla,
  }) async {
    final url = Uri.parse('$baseUrl/auth/register');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          'password': password,
          'rolla_username': rollaUsername,
          'hear_rolla': hearRolla,
        }),
      );

      // Debugging: Log the response
      logger.i('Response status: ${response.statusCode}');
      logger.i('Response body: ${response.body}');

      // Parse the response body
      final Map<String, dynamic> parsedResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Registration successful
        return {
          'success': true,
          'message': parsedResponse['message'],
          'token': parsedResponse['token'],
          'userData': parsedResponse['userData'],
        };
      } else if (response.statusCode == 422) {
        // Handle validation errors
        List<String> errors = [];

        // Check for email errors
        if (parsedResponse.containsKey('email')) {
          errors.addAll(parsedResponse['email'].cast<String>());
        }

        // Check for rolla_username errors
        if (parsedResponse.containsKey('rolla_username')) {
          errors.addAll(parsedResponse['rolla_username'].cast<String>());
        }

        return {
          'success': false,
          'message':
              errors.join('\n'), // Combine all errors into a single string
        };
      } else {
        // Handle error responses
        return {
          'success': false,
          'message': parsedResponse['message'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      // Handle unexpected errors
      logger.i('Error: $e');
      return {
        'success': false,
        'message': 'An unexpected error occurred. Please try again.',
      };
    }
  }

  Future<Map<String, dynamic>> updateUser(
      {required int userId,
      required String firstName,
      required String lastName,
      required String rollaUsername,
      String? happyPlace,
      String? photo,
      String? bio,
      String? garage}) async {
    final url = Uri.parse('$baseUrl/user/update');

    // Prepare the request body
    final Map<String, dynamic> body = {
      "user_id": userId,
      "first_name": firstName,
      "last_name": lastName,
      "rolla_username": rollaUsername,
      if (happyPlace != null) "happy_place": happyPlace,
      if (photo != null) "photo": photo,
      if (bio != null) "bio": bio,
      if (garage != null) "garage": garage,
    };

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );

      logger.i('Response status: ${response.statusCode}');
      logger.i('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        // Handle errors
        final errorResponse = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorResponse['message'] ?? 'Unknown error',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      // Handle exceptions
      logger.i('Error: $e');
      return {
        'success': false,
        'message': 'An error occurred. Please try again later.',
      };
    }
  }

  Future<List<Map<String, dynamic>>> fetchFollowers(int userId) async {
    // final url = Uri.parse('$baseUrl/user/following_users?user_id=$userId');
    final url = Uri.parse('$baseUrl/user/following_users?user_id=$userId');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      // Check if the response is successful.
      final data = json.decode(response.body);
      if (data['statusCode'] == true) {
        // Check API's response `statusCode`.
        return List<Map<String, dynamic>>.from(data['data']);
      } else {
        throw Exception('Failed to load followers: ${data['message']}');
      }
    } else {
      throw Exception('Failed to load followers: ${response.statusCode}');
    }
  }

  Future<bool> createTrip({
    required int userId,
    required String startAddress,
    required String stopAddresses,
    required String destinationAddress,
    required String tripStartDate,
    required String tripEndDate,
    required String tripMiles,
    required String tripSound,
    required List<Map<String, double>> tripCoordinates,
    required List<Map<String, dynamic>> droppins,
  }) async {
    final url = Uri.parse('$baseUrl/trip/create');
    final Map<String, dynamic> requestBody = {
      'user_id': userId,
      'start_address': startAddress,
      'stop_address': stopAddresses,
      'destination_address': destinationAddress,
      'trip_start_date': tripStartDate,
      'trip_end_date': tripEndDate,
      'trip_miles': tripMiles,
      'trip_sound': tripSound,
      'trip_coordinates': tripCoordinates,
      'droppins': droppins,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        logger.i("Trip created successfully: ${responseData['trip']}");
        return true; // Indicate success
      } else {
        logger.i(
            "Failed to create trip: ${response.statusCode} - ${response.body}");
        return false; // Indicate failure
      }
    } catch (e) {
      logger.i("Error creating trip: $e");
      return false; // Indicate failure
    }
  }
}
