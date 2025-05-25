import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:async';

class ApiClient {
  static const String baseUrl = 'https://front-mission.bigs.or.kr';
  final http.Client _client;
  static const Duration timeoutDuration = Duration(seconds: 10);

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  Future<http.Response> get(String endpoint) async {
    debugPrint('🚀 GET Request to: $baseUrl$endpoint');
    try {
      final response = await _client
          .get(
            Uri.parse('$baseUrl$endpoint'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(timeoutDuration);

      if (response.statusCode >= 400) {
        debugPrint('❌ GET Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to get data: ${response.statusCode}');
      }

      debugPrint('✅ GET Success: ${response.statusCode}');
      return response;
    } on SocketException catch (e) {
      debugPrint('🌐 Network Error: No internet connection or DNS failure');
      debugPrint('💥 GET Exception: $e');
      throw Exception('Network error: Please check your internet connection');
    } on http.ClientException catch (e) {
      debugPrint('🔌 Connection Error: Failed to establish connection');
      debugPrint('💥 GET Exception: $e');
      throw Exception('Connection error: Server might be down or unreachable');
    } on TimeoutException catch (e) {
      debugPrint('⏰ Timeout Error: Request took too long to complete');
      debugPrint('💥 GET Exception: $e');
      throw Exception('Request timeout: Server took too long to respond');
    } catch (e) {
      debugPrint('💥 GET Exception: $e');
      throw Exception('Error during GET request: $e');
    }
  }

  Future<http.Response> post(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    debugPrint('🚀 POST Request to: $baseUrl$endpoint');
    if (body != null) {
      debugPrint('📦 POST Body: ${jsonEncode(body)}');
    }

    try {
      final response = await _client
          .post(
            Uri.parse('$baseUrl$endpoint'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(timeoutDuration);

      if (response.statusCode >= 400) {
        debugPrint('❌ POST Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to post data: ${response.statusCode}');
      }

      debugPrint('✅ POST Success: ${response.statusCode}');
      return response;
    } on SocketException catch (e) {
      debugPrint('🌐 Network Error: No internet connection or DNS failure');
      debugPrint('💥 POST Exception: $e');
      throw Exception('Network error: Please check your internet connection');
    } on http.ClientException catch (e) {
      debugPrint('🔌 Connection Error: Failed to establish connection');
      debugPrint('💥 POST Exception: $e');
      throw Exception('Connection error: Server might be down or unreachable');
    } on TimeoutException catch (e) {
      debugPrint('⏰ Timeout Error: Request took too long to complete');
      debugPrint('💥 POST Exception: $e');
      throw Exception('Request timeout: Server took too long to respond');
    } catch (e) {
      debugPrint('💥 POST Exception: $e');
      throw Exception('Error during POST request: $e');
    }
  }

  void dispose() {
    _client.close();
  }
}
