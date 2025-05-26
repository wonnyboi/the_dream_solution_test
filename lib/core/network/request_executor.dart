import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';
import 'network_exceptions.dart';
import 'auth_interceptor.dart';

class RequestExecutor {
  static const Duration timeoutDuration = Duration(seconds: 10);

  static Future<http.Response> executeRequest(
    Future<http.Response> Function() requestFunction,
    String method,
  ) async {
    try {
      final response = await requestFunction();

      if (response.statusCode >= 400) {
        NetworkExceptions.handleErrorResponse(response, method);
      }

      debugPrint('✅ $method Success: ${response.statusCode}');
      return response;
    } catch (e) {
      if (e is String) {
        rethrow;
      }
      throw NetworkExceptions.handleException(e, method);
    }
  }

  static Future<http.Response> executeMultipartRequest(
    String method,
    String url, {
    Map<String, String>? fields,
    Map<String, http.MultipartFile>? files,
    AuthInterceptor? authInterceptor,
  }) async {
    debugPrint('🚀 $method Multipart Request to: $url');
    if (fields != null) {
      debugPrint('📦 $method Fields: $fields');
    }
    if (files != null) {
      debugPrint('📁 $method Files: ${files.keys.toList()}');
    }

    try {
      final request = http.MultipartRequest(method, Uri.parse(url));

      // Convert fields to proper multipart files with JSON content-type
      if (fields != null) {
        for (final entry in fields.entries) {
          if (entry.key == 'request') {
            // Convert JSON request field to proper multipart file
            final multipartJson = http.MultipartFile.fromString(
              entry.key,
              entry.value,
              contentType: MediaType('application', 'json'),
            );
            request.files.add(multipartJson);
          } else {
            // Keep other fields as regular fields
            request.fields[entry.key] = entry.value;
          }
        }
      }

      if (files != null) {
        request.files.addAll(files.values);
      }

      // Explicitly set Content-Type for multipart requests
      // This ensures the server receives the correct Content-Type header
      if (!request.headers.containsKey('content-type') &&
          !request.headers.containsKey('Content-Type')) {
        // Let the MultipartRequest handle setting the boundary automatically
        // We don't set it manually to avoid boundary conflicts
      }

      debugPrint('🔍 Request fields: ${request.fields}');
      debugPrint(
        '🔍 Request files: ${request.files.map((f) => '${f.field}: ${f.filename}')}',
      );
      debugPrint('🔍 Request headers: ${request.headers}');

      // Use auth interceptor if provided (it now handles the full request/response cycle)
      if (authInterceptor != null) {
        final response = await authInterceptor.interceptMultipartRequest(
          request,
        );

        debugPrint(
          '📨 $method Multipart Response: ${response.statusCode} - ${response.body}',
        );

        if (response.statusCode >= 400) {
          NetworkExceptions.handleErrorResponse(response, '$method Multipart');
        }

        debugPrint('✅ $method Multipart Success: ${response.statusCode}');
        return response;
      } else {
        // Fallback for requests without auth interceptor
        final streamedResponse = await request.send().timeout(timeoutDuration);
        final response = await http.Response.fromStream(streamedResponse);

        debugPrint(
          '📨 $method Multipart Response: ${response.statusCode} - ${response.body}',
        );

        if (response.statusCode >= 400) {
          NetworkExceptions.handleErrorResponse(response, '$method Multipart');
        }

        debugPrint('✅ $method Multipart Success: ${response.statusCode}');
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
