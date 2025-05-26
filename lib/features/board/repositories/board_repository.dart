import 'package:the_dream_solution/features/board/api/board_api.dart';
import 'package:the_dream_solution/features/board/model/board_model.dart';

class BoardRepository {
  final BoardApi _boardApi;

  BoardRepository(this._boardApi);

  Future<BoardResponse> getBoardsList({int? page, int? size}) async {
    try {
      return await _boardApi.getBoardsList(page, size);
    } catch (e) {
      rethrow;
    }
  }

  Future<BoardDetailResponse> getBoardDetail(int id) async {
    try {
      return await _boardApi.getBoardDetail(id);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, String>> getBoardCategories() async {
    try {
      return await _boardApi.getBoardCategories();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createBoard({
    required String title,
    required String content,
    required String category,
    String? imagePath,
  }) async {
    try {
      await _boardApi.createBoard(
        title: title,
        content: content,
        category: category,
        imagePath: imagePath,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateBoard({
    required int id,
    required String title,
    required String content,
    required String category,
    String? imagePath,
  }) async {
    try {
      await _boardApi.updateBoard(
        id: id,
        title: title,
        content: content,
        category: category,
        imagePath: imagePath,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteBoard(int id) async {
    try {
      await _boardApi.deleteBoard(id);
    } catch (e) {
      rethrow;
    }
  }
}
