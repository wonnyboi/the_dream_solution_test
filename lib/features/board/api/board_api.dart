import 'dart:convert';
import 'package:the_dream_solution/core/network/api_client.dart';
import 'package:the_dream_solution/features/board/model/board_model.dart';
import 'package:the_dream_solution/core/storage/secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart';

class BoardApi {
  // Helper method to determine content type based on file extension
  MediaType _getContentType(String filePath) {
    final extension = filePath.toLowerCase().split('.').last;
    debugPrint('🔍 File extension detected: $extension from path: $filePath');

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
        debugPrint(
          '⚠️ Unknown extension: $extension, using default image/jpeg',
        );
        contentType = MediaType('image', 'jpeg'); // Default fallback
        break;
    }

    debugPrint('🔍 Determined content type: ${contentType.mimeType}');
    return contentType;
  }

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
    required BoardRequest request,
    String? imagePath,
  }) async {
    // Validate request
    if (!request.isValid()) {
      throw Exception('Invalid board data provided');
    }

    debugPrint('📝 Creating board with data: ${request.toJsonString()}');

    // Create multipart request directly like the sample code
    final multipartRequest = http.MultipartRequest(
      'POST',
      Uri.parse('https://front-mission.bigs.or.kr/boards'),
    );

    // Add JSON request as a proper multipart file with content-type
    final multipartJson = http.MultipartFile.fromString(
      'request',
      request.toJsonString(),
      contentType: MediaType('application', 'json'),
    );
    multipartRequest.files.add(multipartJson);

    // Add file if provided
    if (imagePath != null && imagePath.isNotEmpty) {
      debugPrint('📸 Adding image file: $imagePath');
      multipartRequest.files.add(
        await http.MultipartFile.fromPath('file', imagePath),
      );
    }

    // Add authorization header
    final accessToken = await _getAccessToken();
    if (accessToken != null) {
      multipartRequest.headers['Authorization'] = 'Bearer $accessToken';
    }

    debugPrint('🔍 Request fields: ${multipartRequest.fields}');
    debugPrint(
      '🔍 Request files: ${multipartRequest.files.map((f) => f.filename)}',
    );
    debugPrint('🔍 Request headers: ${multipartRequest.headers}');

    try {
      final streamedResponse = await multipartRequest.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('📨 Response status: ${response.statusCode}');
      debugPrint('📨 Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ Board created successfully');
        return;
      } else {
        debugPrint('❌ Failed to create board: ${response.statusCode}');
        throw Exception('Failed to create board: ${response.body}');
      }
    } catch (e) {
      debugPrint('💥 Error creating board: $e');
      rethrow;
    }
  }

  // Helper method to get access token
  Future<String?> _getAccessToken() async {
    try {
      // You'll need to import SecureStorage or get it from your DI
      final secureStorage = SecureStorage();
      return await secureStorage.getAccessToken();
    } catch (e) {
      debugPrint('⚠️ Could not get access token: $e');
      return null;
    }
  }

  Future<void> updateBoard({
    required int id,
    required BoardRequest request,
    String? imagePath,
  }) async {
    // Validate request
    if (!request.isValid()) {
      throw Exception('Invalid board data provided');
    }

    final http.Response response;

    // Always use multipart request as the server expects it
    final Map<String, String> fields = {'request': request.toJsonString()};

    debugPrint('📝 Updating board $id with data: ${request.toJsonString()}');

    if (imagePath != null && imagePath.isNotEmpty) {
      // Update board WITH image
      debugPrint('📸 Updating board WITH image: $imagePath');
      final contentType = _getContentType(imagePath);
      debugPrint('🔍 Setting content type: $contentType for file: $imagePath');
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
      // Update board WITHOUT image (still use multipart but no file)
      debugPrint('📝 Updating board WITHOUT image - using multipart PATCH');
      response = await ApiClient().patchMultipart(
        '/boards/$id',
        fields: fields,
        files: null, // No files, just the form data
      );
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      debugPrint('✅ Board updated successfully');
      return;
    } else {
      debugPrint('❌ Failed to update board: ${response.statusCode}');
      debugPrint('📨 Response body: ${response.body}');
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
