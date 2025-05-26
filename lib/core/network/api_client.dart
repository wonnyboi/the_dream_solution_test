import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'package:the_dream_solution/core/config/env.dart';
import 'request_executor.dart';

class ApiClient {
  static const String baseUrl = Env.dreamServer;
  final http.Client _client;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  Future<http.Response> get(String endpoint) async {
    debugPrint('🚀 GET Request to: $baseUrl$endpoint');

    return RequestExecutor.executeRequest(() async {
      return await _client
          .get(
            Uri.parse('$baseUrl$endpoint'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(RequestExecutor.timeoutDuration);
    }, 'GET');
  }

  Future<http.Response> post(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    debugPrint('🚀 POST Request to: $baseUrl$endpoint');
    if (body != null) {
      debugPrint('📦 POST Body: ${jsonEncode(body)}');
    }

    return RequestExecutor.executeRequest(() async {
      final response = await _client
          .post(
            Uri.parse('$baseUrl$endpoint'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(RequestExecutor.timeoutDuration);

      debugPrint('📨 POST Response: ${response.statusCode} - ${response.body}');
      return response;
    }, 'POST');
  }

  Future<http.Response> patchMultipart(
    String endpoint, {
    Map<String, String>? fields,
    Map<String, http.MultipartFile>? files,
  }) async {
    return RequestExecutor.executeMultipartRequest(
      'PATCH',
      '$baseUrl$endpoint',
      fields: fields,
      files: files,
    );
  }

  Future<http.Response> postMultipart(
    String endpoint, {
    Map<String, String>? fields,
    Map<String, http.MultipartFile>? files,
  }) async {
    return RequestExecutor.executeMultipartRequest(
      'POST',
      '$baseUrl$endpoint',
      fields: fields,
      files: files,
    );
  }

  Future<http.Response> delete(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    debugPrint('🚀 DELETE Request to: $baseUrl$endpoint');
    if (body != null) {
      debugPrint('📦 DELETE Body: ${jsonEncode(body)}');
    }

    return RequestExecutor.executeRequest(() async {
      return await _client
          .delete(
            Uri.parse('$baseUrl$endpoint'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(RequestExecutor.timeoutDuration);
    }, 'DELETE');
  }

  void dispose() {
    _client.close();
  }
}
