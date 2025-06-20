import 'dart:async'; // Import for TimeoutException
import 'dart:convert'; // Import for utf8 and json
// Import for SocketException
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cropmgnt/utils/storage_service.dart'; // Import your StorageService here

class FarmAIService {
  static const String baseUrl = 'http://10.0.2.2:8080/api/assistant';
  static const Duration timeoutDuration = Duration(
    seconds: 30,
  ); // Increased timeout
  static const int maxRetries = 2;

  static Future<List<Map<String, dynamic>>> getConversation() async {
    try {
      final token = await StorageService.getToken();
      debugPrint('Retrieved token: $token'); // Debug token

      if (token == null) throw Exception('Authorization token is null');

      final response = await http
          .get(
            Uri.parse('$baseUrl/conversation'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['messages'] as List?)
                ?.map((msg) => Map<String, dynamic>.from(msg))
                .toList() ??
            [];
      }
      throw Exception('Failed to load conversation: ${response.statusCode}');
    } catch (e) {
      debugPrint('GetConversation Error: $e'); // Debug error
      return []; // Return empty list instead of throwing
    }
  }

  static Future<Map<String, dynamic>> sendMessage(String message) async {
    int attempts = 0;
    while (attempts < maxRetries) {
      try {
        final token = await StorageService.getToken();
        if (token == null) throw Exception('No auth token found');

        final response = await http
            .post(
              Uri.parse('$baseUrl/chat'),
              headers: {
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json',
              },
              body: json.encode({'message': message}),
            )
            .timeout(timeoutDuration);

        if (response.statusCode == 200) {
          return json.decode(response.body);
        }
        throw Exception('Server error: ${response.statusCode}');
      } catch (e) {
        attempts++;
        if (attempts >= maxRetries) {
          return {
            'success': false,
            'response': 'Request timed out. Please try again.',
          };
        }
        await Future.delayed(
          Duration(seconds: 2 * attempts),
        ); // Exponential backoff
      }
    }
    return {
      'success': false,
      'response': 'Failed to send message after multiple attempts.',
    };
  }
}
