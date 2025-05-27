import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'package:the_dream_solution/core/config/env.dart';
import 'package:the_dream_solution/core/storage/secure_storage.dart';
import 'request_executor.dart';
import 'auth_interceptor.dart';

// API 클라이언트 클래스
// HTTP 요청 처리 및 인증 인터셉터를 통해 요청 가로채기.
class ApiClient {
  static const String baseUrl = Env.dreamServer;
  final http.Client _client;
  final AuthInterceptor _authInterceptor;

  ApiClient({http.Client? client, SecureStorage? secureStorage})
    : _client = client ?? http.Client(),
      _authInterceptor = AuthInterceptor(secureStorage ?? SecureStorage());

  // GET 요청 수행.
  Future<http.Response> get(String endpoint) async {
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

  // POST 요청 수행.
  Future<http.Response> post(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final url = '$baseUrl$endpoint';

    return _authInterceptor.interceptRequest(
      () async {
        final headers = await _authInterceptor.getAuthenticatedHeaders(url, {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        });

        return await _client
            .post(
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

  // PATCH 요청 수행.
  Future<http.Response> patch(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final url = '$baseUrl$endpoint';

    return _authInterceptor.interceptRequest(
      () async {
        final headers = await _authInterceptor.getAuthenticatedHeaders(url, {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        });

        return await _client
            .patch(
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

  // 멀티파트 PATCH 요청 수행.
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

  // 멀티파트 POST 요청 수행.
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

  // DELETE 요청 수행.
  Future<http.Response> delete(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
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

  // HTTP 클라이언트 종료.
  void dispose() {
    _client.close();
  }
}
