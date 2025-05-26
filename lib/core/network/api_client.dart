import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'package:the_dream_solution/core/config/env.dart';
import 'package:the_dream_solution/core/storage/secure_storage.dart';
import 'request_executor.dart';
import 'auth_interceptor.dart';

class ApiClient {
  static const String baseUrl = Env.dreamServer;
  final http.Client _client;
  final AuthInterceptor _authInterceptor;

  ApiClient({http.Client? client, SecureStorage? secureStorage})
    : _client = client ?? http.Client(),
      _authInterceptor = AuthInterceptor(secureStorage ?? SecureStorage());

  Future<http.Response> get(String endpoint) async {
    debugPrint('🚀 GET Request to: $baseUrl$endpoint');
    final url = '$baseUrl$endpoint';

    return _authInterceptor.interceptRequest(
      () async {
        final headers = await _authInterceptor.getAuthenticatedHeaders(url, {
          'Content-Type': 'application/json',
        });

        return await _client
            .get(Uri.parse(url), headers: headers)
            .timeout(RequestExecutor.timeoutDuration);
      },
      url,
      {'Content-Type': 'application/json'},
    );
  }

  Future<http.Response> post(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    debugPrint('🚀 POST Request to: $baseUrl$endpoint');
    if (body != null) {
      debugPrint('📦 POST Body: ${jsonEncode(body)}');
    }
    final url = '$baseUrl$endpoint';

    return _authInterceptor.interceptRequest(
      () async {
        final headers = await _authInterceptor.getAuthenticatedHeaders(url, {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        });

        final response = await _client
            .post(
              Uri.parse(url),
              headers: headers,
              body: body != null ? jsonEncode(body) : null,
            )
            .timeout(RequestExecutor.timeoutDuration);

        debugPrint(
          '📨 POST Response: ${response.statusCode} - ${response.body}',
        );
        return response;
      },
      url,
      {'Content-Type': 'application/json', 'Accept': 'application/json'},
    );
  }

  Future<http.Response> patch(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    debugPrint('🚀 PATCH Request to: $baseUrl$endpoint');
    if (body != null) {
      debugPrint('📦 PATCH Body: ${jsonEncode(body)}');
    }
    final url = '$baseUrl$endpoint';

    return _authInterceptor.interceptRequest(
      () async {
        final headers = await _authInterceptor.getAuthenticatedHeaders(url, {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        });

        final response = await _client
            .patch(
              Uri.parse(url),
              headers: headers,
              body: body != null ? jsonEncode(body) : null,
            )
            .timeout(RequestExecutor.timeoutDuration);

        debugPrint(
          '📨 PATCH Response: ${response.statusCode} - ${response.body}',
        );
        return response;
      },
      url,
      {'Content-Type': 'application/json', 'Accept': 'application/json'},
    );
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
      authInterceptor: _authInterceptor,
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
      authInterceptor: _authInterceptor,
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
    final url = '$baseUrl$endpoint';

    return _authInterceptor.interceptRequest(
      () async {
        final headers = await _authInterceptor.getAuthenticatedHeaders(url, {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        });

        return await _client
            .delete(
              Uri.parse(url),
              headers: headers,
              body: body != null ? jsonEncode(body) : null,
            )
            .timeout(RequestExecutor.timeoutDuration);
      },
      url,
      {'Content-Type': 'application/json', 'Accept': 'application/json'},
    );
  }

  void dispose() {
    _client.close();
  }
}
