import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:cropmgnt/utils/storage_service.dart';

class AuthService {
  static const String baseUrl = 'http://10.0.2.2:8080/api/users';
  static const Duration timeoutDuration = Duration(seconds: 10);

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/signin'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'username': username, 'password': password}),
          )
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['accessToken'] == null ||
            responseData['user']?['_id'] == null) {
          return {
            'success': false,
            'error': 'Invalid server response: Missing required fields',
          };
        }

        await StorageService.saveToken(responseData['accessToken']);
        await StorageService.saveUserId(responseData['user']['_id']);
        final expiresIn = responseData['expiresIn'] ?? 3600; // Default 1 hour
        await StorageService.saveTokenExpiry(
          DateTime.now()
              .add(Duration(seconds: expiresIn))
              .millisecondsSinceEpoch,
        );

        return {
          'success': true,
          'user': {'id': responseData['user']['_id'], 'username': username},
        };
      } else {
        return _handleError(response);
      }
    } on TimeoutException {
      return {'success': false, 'error': 'Connection timeout'};
    } on SocketException {
      return {'success': false, 'error': 'No internet connection'};
    } catch (e) {
      return {'success': false, 'error': 'An unexpected error occurred'};
    }
  }

  Future<Map<String, dynamic>> register(
    String username,
    String email,
    String password,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/signup'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'username': username,
              'email': email,
              'password': password,
            }),
          )
          .timeout(timeoutDuration);

      if (response.statusCode == 201) {
        return {'success': true};
      } else {
        return _handleError(response);
      }
    } on TimeoutException {
      return {'success': false, 'error': 'Connection timeout'};
    } on SocketException {
      return {'success': false, 'error': 'No internet connection'};
    } catch (e) {
      return {
        'success': false,
        'error': 'An error occurred during registration',
      };
    }
  }

  Future<Map<String, dynamic>> refreshToken() async {
    try {
      final refreshToken = await StorageService.getRefreshToken();
      if (refreshToken == null) {
        return {'success': false, 'error': 'No refresh token available'};
      }

      final response = await http
          .post(
            Uri.parse('$baseUrl/refresh'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'refreshToken': refreshToken}),
          )
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        await StorageService.saveToken(responseData['accessToken']);
        final expiresIn = responseData['expiresIn'] ?? 3600;
        await StorageService.saveTokenExpiry(
          DateTime.now()
              .add(Duration(seconds: expiresIn))
              .millisecondsSinceEpoch,
        );
        return {'success': true, 'token': responseData['accessToken']};
      } else {
        await StorageService.clearAuthData();
        return {'success': false, 'error': 'Session expired'};
      }
    } on TimeoutException {
      return {'success': false, 'error': 'Connection timeout'};
    } on SocketException {
      return {'success': false, 'error': 'No internet connection'};
    } catch (e) {
      return {'success': false, 'error': 'Failed to refresh token'};
    }
  }

  static Future<bool> logout() async {
    try {
      final token = await StorageService.getToken();
      await http
          .post(
            Uri.parse('$baseUrl/logout'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(timeoutDuration);

      await StorageService.clearAuthData();
      return true;
    } catch (e) {
      await StorageService.clearAuthData();
      return false;
    }
  }

  // Helper method to handle errors
  static Map<String, dynamic> _handleError(http.Response response) {
    String errorMessage = 'Request failed';
    try {
      final errorData = jsonDecode(response.body);
      errorMessage = errorData['message'] ?? errorData['error'] ?? errorMessage;
    } catch (_) {}

    return {
      'success': false,
      'error': errorMessage,
      'statusCode': response.statusCode,
    };
  }
}
