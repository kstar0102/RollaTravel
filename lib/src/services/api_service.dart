import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';


class ApiService {
  static const String baseUrl = 'http://16.171.153.11/api/auth';
  final logger = Logger();
  /// Function to login
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');
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

  Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String country,
    required String password,
    required String rollaUsername,
    required String hearRolla,
  }) async {
    final url = Uri.parse('$baseUrl/register');

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
}
