import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:async';

class NetworkExceptions {
  static Exception handleException(Object exception, String method) {
    if (exception is SocketException) {
      debugPrint('🌐 Network Error: No internet connection or DNS failure');
      debugPrint('💥 $method Exception: $exception');
      return Exception('네트워크 오류: 인터넷 연결을 확인해주세요.');
    } else if (exception is http.ClientException) {
      debugPrint('🔌 Client Exception: $exception');
      return Exception('서버에 연결할 수 없습니다. 관리자에게 문의하세요.');
    } else if (exception is TimeoutException) {
      debugPrint('⏰ Timeout Error: Request took too long to complete');
      debugPrint('💥 $method Exception: $exception');
      return Exception('요청 시간이 초과되었습니다. 서버가 응답하지 않습니다.');
    } else {
      debugPrint('💥 $method Exception: $exception');
      return Exception('알 수 없는 오류가 발생했습니다: $exception');
    }
  }

  static void handleErrorResponse(http.Response response, String method) {
    debugPrint('❌ $method Error: ${response.statusCode} - ${response.body}');
    try {
      final Map<String, dynamic> errorJson = json.decode(response.body);
      final String message =
          errorJson['message'] ?? '요청에 실패했습니다. (${response.statusCode})';
      throw message;
    } catch (_) {
      throw '요청에 실패했습니다. (${response.statusCode})';
    }
  }
}
