import 'dart:convert';
import 'package:the_dream_solution/core/network/api_client.dart';
import 'package:the_dream_solution/features/board/model/board_model.dart';
import 'package:http/http.dart' as http;

class BoardApi {
  Future<BoardResponse> getBoardsList(int? page, int? size) async {
    final pages = page ?? 0;
    final sizes = size ?? 10;

    final response = await ApiClient().get('/boards?page=$pages&size=$sizes');
    if (response.statusCode == 200) {
      final String decodedBody = utf8.decode(response.bodyBytes);
      final Map<String, dynamic> jsonResponse = json.decode(decodedBody);
      return BoardResponse.fromJson(jsonResponse);
    } else {
      throw Exception('Failed to get boards');
    }
  }

  Future<BoardDetailResponse> getBoardDetail(int id) async {
    final response = await ApiClient().get('/boards/$id');
    if (response.statusCode == 200) {
      final String decodedBody = utf8.decode(response.bodyBytes);
      final Map<String, dynamic> jsonResponse = json.decode(decodedBody);
      return BoardDetailResponse.fromJson(jsonResponse);
    } else {
      throw Exception('Failed to get board detail');
    }
  }

  Future<Map<String, String>> getBoardCategories() async {
    final response = await ApiClient().get('/boards/categories');
    if (response.statusCode == 200) {
      final String decodedBody = utf8.decode(response.bodyBytes);
      final Map<String, dynamic> jsonResponse = json.decode(decodedBody);
      return BoardCategoryResponse.fromJson(jsonResponse).categories;
    } else {
      throw Exception('Failed to get board categories');
    }
  }

  Future<void> createBoard({
    required String title,
    required String content,
    required String category,
    String? imagePath,
  }) async {
    final Map<String, String> fields = {
      'request': json.encode({
        'title': title,
        'content': content,
        'category': category,
      }),
    };

    Map<String, http.MultipartFile>? files;
    if (imagePath != null) {
      final multipartFile = await http.MultipartFile.fromPath(
        'file',
        imagePath,
      );
      files = {'file': multipartFile};
    }

    final response = await ApiClient().postMultipart(
      '/boards',
      fields: fields,
      files: files,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return;
    } else {
      throw Exception('Failed to create board');
    }
  }

  Future<void> updateBoard({
    required int id,
    required String title,
    required String content,
    required String category,
    String? imagePath,
  }) async {
    final Map<String, String> fields = {
      'request': json.encode({
        'title': title,
        'content': content,
        'category': category,
      }),
    };

    Map<String, http.MultipartFile>? files;
    if (imagePath != null) {
      final multipartFile = await http.MultipartFile.fromPath(
        'file',
        imagePath,
      );
      files = {'file': multipartFile};
    }

    final response = await ApiClient().patchMultipart(
      '/boards/$id',
      fields: fields,
      files: files,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return;
    } else {
      throw Exception('Failed to update board');
    }
  }

  Future<void> deleteBoard(int id) async {
    final response = await ApiClient().delete('/boards/$id');
    if (response.statusCode == 200 || response.statusCode == 201) {
      return;
    }
  }
}
