import 'dart:convert';
import 'package:the_dream_solution/core/network/api_client.dart';
import 'package:the_dream_solution/features/board/model/board_model.dart';
import 'package:the_dream_solution/core/storage/secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:the_dream_solution/core/config/env.dart';

/// 게시판 API 처리
class BoardApi {
  /// 파일 확장자에 따른 컨텐츠 타입 결정
  MediaType _getContentType(String filePath) {
    final extension = filePath.toLowerCase().split('.').last;
    final MediaType contentType;

    switch (extension) {
      case 'jpg':
      case 'jpeg':
        contentType = MediaType('image', 'jpeg');
        break;
      case 'png':
        contentType = MediaType('image', 'png');
        break;
      case 'gif':
        contentType = MediaType('image', 'gif');
        break;
      case 'webp':
        contentType = MediaType('image', 'webp');
        break;
      default:
        contentType = MediaType('image', 'jpeg');
        break;
    }

    return contentType;
  }

  /// 게시판 목록 조회
  Future<BoardResponse> getBoardsList(
    int? page,
    int? size, {
    String? category,
  }) async {
    final pages = page ?? 0;
    final sizes = size ?? 10;

    String endpoint = '/boards?page=$pages&size=$sizes';
    if (category != null) {
      endpoint += '&category=$category';
    }

    final response = await ApiClient().get(endpoint);
    if (response.statusCode == 200) {
      final String decodedBody = utf8.decode(response.bodyBytes);
      final Map<String, dynamic> jsonResponse = json.decode(decodedBody);
      return BoardResponse.fromJson(jsonResponse);
    } else {
      throw Exception('게시판 목록 조회 실패');
    }
  }

  /// 게시판 상세 조회
  Future<BoardDetailResponse> getBoardDetail(int id) async {
    final response = await ApiClient().get('/boards/$id');

    if (response.statusCode == 200) {
      final String decodedBody = utf8.decode(response.bodyBytes);
      final Map<String, dynamic> jsonResponse = json.decode(decodedBody);
      return BoardDetailResponse.fromJson(jsonResponse);
    } else {
      throw Exception('게시판 상세 조회 실패: ${response.statusCode}');
    }
  }

  /// 게시판 카테고리 조회
  Future<Map<String, String>> getBoardCategories() async {
    final response = await ApiClient().get('/boards/categories');
    if (response.statusCode == 200) {
      final String decodedBody = utf8.decode(response.bodyBytes);
      final Map<String, dynamic> jsonResponse = json.decode(decodedBody);
      return BoardCategoryResponse.fromJson(jsonResponse).categories;
    } else {
      throw Exception('카테고리 조회 실패');
    }
  }

  /// 게시판 생성
  Future<int> createBoard({
    required BoardRequest request,
    String? imagePath,
  }) async {
    if (!request.isValid()) {
      throw Exception('잘못된 게시판 데이터입니다');
    }

    final multipartRequest = http.MultipartRequest(
      'POST',
      Uri.parse('${Env.dreamServer}/boards'),
    );

    final multipartJson = http.MultipartFile.fromString(
      'request',
      request.toJsonString(),
      contentType: MediaType('application', 'json'),
    );
    multipartRequest.files.add(multipartJson);

    if (imagePath != null && imagePath.isNotEmpty) {
      multipartRequest.files.add(
        await http.MultipartFile.fromPath('file', imagePath),
      );
    }

    final accessToken = await _getAccessToken();
    if (accessToken != null) {
      multipartRequest.headers['Authorization'] = 'Bearer $accessToken';
    }

    try {
      final streamedResponse = await multipartRequest.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final String decodedBody = utf8.decode(response.bodyBytes);
        final Map<String, dynamic> jsonResponse = json.decode(decodedBody);
        return jsonResponse['id'] as int;
      } else {
        throw Exception('게시판 생성 실패: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// 액세스 토큰 조회
  Future<String?> _getAccessToken() async {
    try {
      final secureStorage = SecureStorage();
      return await secureStorage.getAccessToken();
    } catch (e) {
      return null;
    }
  }

  /// 게시판 수정
  Future<void> updateBoard({
    required int id,
    required BoardRequest request,
    String? imagePath,
    bool keepExistingImage = false,
  }) async {
    if (!request.isValid()) {
      throw Exception('잘못된 게시판 데이터입니다');
    }

    final http.Response response;
    final Map<String, String> fields = {
      'request': request.toJsonString(),
      'keepExistingImage': keepExistingImage.toString(),
    };

    if (imagePath != null && imagePath.isNotEmpty) {
      final contentType = _getContentType(imagePath);
      final multipartFile = await http.MultipartFile.fromPath(
        'file',
        imagePath,
        contentType: contentType,
      );
      final files = {'file': multipartFile};

      response = await ApiClient().patchMultipart(
        '/boards/$id',
        fields: fields,
        files: files,
      );
    } else {
      response = await ApiClient().patchMultipart(
        '/boards/$id',
        fields: fields,
        files: null,
      );
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      return;
    } else {
      throw Exception('게시판 수정 실패');
    }
  }

  /// 게시판 삭제
  Future<void> deleteBoard(int id) async {
    final response = await ApiClient().delete('/boards/$id');
    if (response.statusCode == 200 || response.statusCode == 201) {
      return;
    }
    throw Exception('게시판 삭제 실패');
  }
}
