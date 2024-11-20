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
        body: jsonEncode({'email': email, 'password': password}),
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
}
