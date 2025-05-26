import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_dream_solution/features/board/api/board_api.dart';
import 'package:the_dream_solution/features/board/model/board_model.dart';

final boardApiProvider = Provider<BoardApi>((ref) => BoardApi());

final boardProvider = StateNotifierProvider<BoardNotifier, BoardState>((ref) {
  return BoardNotifier(ref.read(boardApiProvider));
});

class BoardState {
  final List<Board> boards;
  final Map<String, String> categories;
  final BoardDetailResponse? selectedBoard;
  final bool isLoading;
  final bool isLoadingDetail;
  final bool isCreating;
  final bool isUpdating;
  final bool isDeleting;
  final int currentPage;
  final int pageSize;
  final bool hasMoreData;
  final int totalElements;

  const BoardState({
    this.boards = const [],
    this.categories = const {},
    this.selectedBoard,
    this.isLoading = false,
    this.isLoadingDetail = false,
    this.isCreating = false,
    this.isUpdating = false,
    this.isDeleting = false,
    this.currentPage = 0,
    this.pageSize = 10,
    this.hasMoreData = false,
    this.totalElements = 0,
  });

  BoardState copyWith({
    List<Board>? boards,
    Map<String, String>? categories,
    BoardDetailResponse? selectedBoard,
    bool? isLoading,
    bool? isLoadingDetail,
    bool? isCreating,
    bool? isUpdating,
    bool? isDeleting,
    int? currentPage,
    int? pageSize,
    bool? hasMoreData,
    int? totalElements,
  }) {
    return BoardState(
      boards: boards ?? this.boards,
      categories: categories ?? this.categories,
      selectedBoard: selectedBoard ?? this.selectedBoard,
      isLoading: isLoading ?? this.isLoading,
      isLoadingDetail: isLoadingDetail ?? this.isLoadingDetail,
      isCreating: isCreating ?? this.isCreating,
      isUpdating: isUpdating ?? this.isUpdating,
      isDeleting: isDeleting ?? this.isDeleting,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      totalElements: totalElements ?? this.totalElements,
    );
  }
}

class BoardNotifier extends StateNotifier<BoardState> {
  final BoardApi _boardApi;

  BoardNotifier(this._boardApi) : super(const BoardState());

  // 보드 목록 페이지네이션 - throws exception on error
  Future<void> loadBoards({
    int? page,
    int? size,
    bool isRefresh = false,
  }) async {
    final currentPage = page ?? (isRefresh ? 0 : state.currentPage);
    final pageSize = size ?? state.pageSize;

    if (isRefresh) {
      state = state.copyWith(isLoading: true, boards: [], currentPage: 0);
    } else {
      state = state.copyWith(isLoading: true);
    }

    try {
      final response = await _boardApi.getBoardsList(currentPage, pageSize);

      final newBoards =
          isRefresh || currentPage == 0
              ? response.content
              : [...state.boards, ...response.content];

      state = state.copyWith(
        boards: newBoards,
        isLoading: false,
        currentPage: currentPage,
        hasMoreData: !response.last,
        totalElements: response.totalElements,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow; // Let the UI handle the error locally
    }
  }

  // 보드 추가 로딩
  Future<void> loadMoreBoards() async {
    if (state.hasMoreData && !state.isLoading) {
      await loadBoards(page: state.currentPage + 1);
    }
  }

  // 보드 상세페이지 - throws exception on error
  Future<void> loadBoardDetail(int id) async {
    debugPrint('🔍 BoardNotifier.loadBoardDetail called for ID: $id');
    state = state.copyWith(isLoadingDetail: true);

    try {
      final response = await _boardApi.getBoardDetail(id);
      debugPrint('✅ BoardNotifier: Board detail loaded successfully');
      state = state.copyWith(selectedBoard: response, isLoadingDetail: false);
    } catch (e) {
      debugPrint('❌ BoardNotifier: Error loading board detail: $e');
      state = state.copyWith(isLoadingDetail: false);
      rethrow; // Let the UI handle the error locally
    }
  }

  // 카테고리 - throws exception on error
  Future<void> loadCategories() async {
    final categories = await _boardApi.getBoardCategories();
    state = state.copyWith(categories: categories);
  }

  // 보드 생성 - returns null on error
  Future<int?> createBoard({
    required BoardRequest request,
    String? imagePath,
  }) async {
    state = state.copyWith(isCreating: true);

    try {
      final createdBoardId = await _boardApi.createBoard(
        request: request,
        imagePath: imagePath,
      );

      state = state.copyWith(isCreating: false);

      // 생성 후 보드 리스트 새로고침
      await loadBoards(isRefresh: true);

      return createdBoardId;
    } catch (e) {
      state = state.copyWith(isCreating: false);
      rethrow; // Let the UI handle the error locally
    }
  }

  // 보드 수정 - throws exception on error
  Future<void> updateBoard({
    required int id,
    required BoardRequest request,
    String? imagePath,
  }) async {
    state = state.copyWith(isUpdating: true);

    try {
      await _boardApi.updateBoard(
        id: id,
        request: request,
        imagePath: imagePath,
      );

      state = state.copyWith(isUpdating: false);

      // Refresh boards list and detail after update
      await loadBoards(isRefresh: true);
      await loadBoardDetail(id);
    } catch (e) {
      state = state.copyWith(isUpdating: false);
      rethrow; // Let the UI handle the error locally
    }
  }

  // 보드 삭제 - throws exception on error
  Future<void> deleteBoard(int id) async {
    state = state.copyWith(isDeleting: true);

    try {
      await _boardApi.deleteBoard(id);

      state = state.copyWith(isDeleting: false, selectedBoard: null);

      // Refresh boards list after deletion
      await loadBoards(isRefresh: true);
    } catch (e) {
      state = state.copyWith(isDeleting: false);
      rethrow; // Let the UI handle the error locally
    }
  }

  // 선택된 보드 초기화
  void clearSelectedBoard() {
    state = state.copyWith(selectedBoard: null);
  }

  // 보드 상세 상태 완전 초기화 (새로운 상세 페이지 진입 시 사용)
  void resetDetailState() {
    state = state.copyWith(selectedBoard: null, isLoadingDetail: false);
  }

  // 모든 데이터 새로고침
  Future<void> refresh() async {
    await Future.wait([loadBoards(isRefresh: true), loadCategories()]);
  }
}
