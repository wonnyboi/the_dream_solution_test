import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'network_exceptions.dart';

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

      if (fields != null) {
        request.fields.addAll(fields);
      }

      if (files != null) {
        request.files.addAll(files.values);
      }

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
    } catch (e) {
      if (e is String) {
        rethrow;
      }
      throw NetworkExceptions.handleException(e, '$method Multipart');
    }
  }
}
