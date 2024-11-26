import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';


class ApiService {
  // static const String baseUrl = 'http://16.171.153.11/api/auth';
  static const String baseUrl = 'http://192.168.141.105:8000/api';
  String apiKey = 'cfdb0e89363c14687341dbc25d1e1d43';
  final logger = Logger();
  
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

  Future <String> getImageUrl(String base64) async {
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
    required String country,
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
          'country': country,
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
          'message': errors.join('\n'), // Combine all errors into a single string
        };
      }else {
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

  Future<Map<String, dynamic>> updateUser({
    required int userId, 
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
}
