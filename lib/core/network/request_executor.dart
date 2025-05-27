import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';
import 'network_exceptions.dart';
import 'auth_interceptor.dart';

// HTTP 요청 실행기 클래스
// HTTP 요청을 실행하고 예외 처리 담당.
class RequestExecutor {
  static const Duration timeoutDuration = Duration(seconds: 10);

  // 일반 HTTP 요청 실행.
  static Future<http.Response> executeRequest(
    Future<http.Response> Function() requestFunction,
    String method,
  ) async {
    try {
      final response = await requestFunction();

      if (response.statusCode >= 400) {
        NetworkExceptions.handleErrorResponse(response, method);
      }

      return response;
    } catch (e) {
      if (e is String) {
        rethrow;
      }
      throw NetworkExceptions.handleException(e, method);
    }
  }

  // 멀티파트 HTTP 요청 실행.
  static Future<http.Response> executeMultipartRequest(
    String method,
    String url, {
    Map<String, String>? fields,
    Map<String, http.MultipartFile>? files,
    AuthInterceptor? authInterceptor,
  }) async {
    try {
      final request = http.MultipartRequest(method, Uri.parse(url));

      if (fields != null) {
        for (final entry in fields.entries) {
          if (entry.key == 'request') {
            final multipartJson = http.MultipartFile.fromString(
              entry.key,
              entry.value,
              contentType: MediaType('application', 'json'),
            );
            request.files.add(multipartJson);
          } else {
            request.fields[entry.key] = entry.value;
          }
        }
      }

      if (files != null) {
        request.files.addAll(files.values);
      }

      if (authInterceptor != null) {
        final response = await authInterceptor.interceptMultipartRequest(
          request,
        );

        if (response.statusCode >= 400) {
          NetworkExceptions.handleErrorResponse(response, '$method Multipart');
        }

        return response;
      } else {
        final streamedResponse = await request.send().timeout(timeoutDuration);
        final response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode >= 400) {
          NetworkExceptions.handleErrorResponse(response, '$method Multipart');
        }

        return response;
      }
    } catch (e) {
      if (e is String) {
        rethrow;
      }
      throw NetworkExceptions.handleException(e, '$method Multipart');
    }
  }
}
