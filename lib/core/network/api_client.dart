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
        try {
          final Map<String, dynamic> errorJson = json.decode(response.body);
          final String message =
              errorJson['message'] ?? '요청에 실패했습니다. (${response.statusCode})';
          throw message;
        } catch (_) {
          throw '요청에 실패했습니다. (${response.statusCode})';
        }
      }

      debugPrint('✅ GET Success: ${response.statusCode}');
      return response;
    } on SocketException catch (e) {
      debugPrint('🌐 Network Error: No internet connection or DNS failure');
      debugPrint('💥 GET Exception: $e');
      throw Exception('네트워크 오류: 인터넷 연결을 확인해주세요.');
    } on http.ClientException catch (e) {
      debugPrint('🔌 Client Exception: $e');
      throw Exception('서버에 연결할 수 없습니다. 관리자에게 문의하세요.');
    } on TimeoutException catch (e) {
      debugPrint('⏰ Timeout Error: Request took too long to complete');
      debugPrint('💥 GET Exception: $e');
      throw Exception('요청 시간이 초과되었습니다. 서버가 응답하지 않습니다.');
    } catch (e) {
      debugPrint('💥 GET Exception: $e');
      throw Exception('알 수 없는 오류가 발생했습니다: $e');
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

      debugPrint('📨 POST Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode >= 400) {
        debugPrint('❌ POST Error: ${response.statusCode} - ${response.body}');
        try {
          final Map<String, dynamic> errorJson = json.decode(response.body);
          final String message =
              errorJson['message'] ?? '요청에 실패했습니다. (${response.statusCode})';
          throw message;
        } catch (_) {
          throw '요청에 실패했습니다. (${response.statusCode})';
        }
      }

      debugPrint('✅ POST Success: ${response.statusCode}');
      return response;
    } on SocketException catch (e) {
      debugPrint('🌐 Network Error: No internet connection or DNS failure');
      debugPrint('💥 POST Exception: $e');
      throw Exception('네트워크 오류: 인터넷 연결을 확인해주세요.');
    } on http.ClientException catch (e) {
      debugPrint('🔌 Client Exception: $e');
      throw Exception('서버에 연결할 수 없습니다. 관리자에게 문의하세요.');
    } on TimeoutException catch (e) {
      debugPrint('⏰ Timeout Error: Request took too long to complete');
      debugPrint('💥 POST Exception: $e');
      throw Exception('요청 시간이 초과되었습니다. 서버가 응답하지 않습니다.');
    } catch (e) {
      debugPrint('💥 POST Exception: $e');
      throw Exception('알 수 없는 오류가 발생했습니다: $e');
    }
  }

  Future<http.Response> patch(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    debugPrint('🚀 PATCH Request to: $baseUrl$endpoint');
    if (body != null) {
      debugPrint('📦 PATCH Body: ${jsonEncode(body)}');
    }

    try {
      final response = await _client
          .patch(
            Uri.parse('$baseUrl$endpoint'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(timeoutDuration);

      if (response.statusCode >= 400) {
        debugPrint('❌ PATCH Error: ${response.statusCode} - ${response.body}');
        try {
          final Map<String, dynamic> errorJson = json.decode(response.body);
          final String message =
              errorJson['message'] ?? '요청에 실패했습니다. (${response.statusCode})';
          throw message;
        } catch (_) {
          throw '요청에 실패했습니다. (${response.statusCode})';
        }
      }

      debugPrint('✅ PATCH Success: ${response.statusCode}');
      return response;
    } on SocketException catch (e) {
      debugPrint('🌐 Network Error: No internet connection or DNS failure');
      debugPrint('💥 PATCH Exception: $e');
      throw Exception('네트워크 오류: 인터넷 연결을 확인해주세요.');
    } on http.ClientException catch (e) {
      debugPrint('🔌 Client Exception: $e');
      throw Exception('서버에 연결할 수 없습니다. 관리자에게 문의하세요.');
    } on TimeoutException catch (e) {
      debugPrint('⏰ Timeout Error: Request took too long to complete');
      debugPrint('💥 PATCH Exception: $e');
      throw Exception('요청 시간이 초과되었습니다. 서버가 응답하지 않습니다.');
    } catch (e) {
      debugPrint('💥 PATCH Exception: $e');
      throw Exception('알 수 없는 오류가 발생했습니다: $e');
    }
  }

  Future<http.Response> delete(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    debugPrint('🚀 DELETE Request to: $baseUrl$endpoint');
    if (body != null) {
      debugPrint('📦 DELETE Body: ${jsonEncode(body)}');
    }

    try {
      final response = await _client
          .delete(
            Uri.parse('$baseUrl$endpoint'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(timeoutDuration);

      if (response.statusCode >= 400) {
        debugPrint('❌ DELETE Error: ${response.statusCode} - ${response.body}');
        try {
          final Map<String, dynamic> errorJson = json.decode(response.body);
          final String message =
              errorJson['message'] ?? '요청에 실패했습니다. (${response.statusCode})';
          throw message;
        } catch (_) {
          throw '요청에 실패했습니다. (${response.statusCode})';
        }
      }

      debugPrint('✅ DELETE Success: ${response.statusCode}');
      return response;
    } on SocketException catch (e) {
      debugPrint('🌐 Network Error: No internet connection or DNS failure');
      debugPrint('💥 DELETE Exception: $e');
      throw Exception('네트워크 오류: 인터넷 연결을 확인해주세요.');
    } on http.ClientException catch (e) {
      debugPrint('🔌 Client Exception: $e');
      throw Exception('서버에 연결할 수 없습니다. 관리자에게 문의하세요.');
    } on TimeoutException catch (e) {
      debugPrint('⏰ Timeout Error: Request took too long to complete');
      debugPrint('💥 DELETE Exception: $e');
      throw Exception('요청 시간이 초과되었습니다. 서버가 응답하지 않습니다.');
    } catch (e) {
      debugPrint('💥 DELETE Exception: $e');
      throw Exception('알 수 없는 오류가 발생했습니다: $e');
    }
  }

  void dispose() {
    _client.close();
  }
}
