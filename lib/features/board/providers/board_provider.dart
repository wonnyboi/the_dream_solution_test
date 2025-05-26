import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_dream_solution/features/board/api/board_api.dart';
import 'package:the_dream_solution/features/board/repositories/board_repository.dart';
import 'package:the_dream_solution/features/board/model/board_model.dart';

final boardApiProvider = Provider<BoardApi>((ref) => BoardApi());

final boardRepositoryProvider = Provider<BoardRepository>((ref) {
  return BoardRepository(ref.read(boardApiProvider));
});

final boardProvider = StateNotifierProvider<BoardNotifier, BoardState>((ref) {
  return BoardNotifier(ref.read(boardRepositoryProvider));
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
  final String? errorMessage;
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
    this.errorMessage,
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
    String? errorMessage,
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
      errorMessage: errorMessage ?? this.errorMessage,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      totalElements: totalElements ?? this.totalElements,
    );
  }
}

class BoardNotifier extends StateNotifier<BoardState> {
  final BoardRepository _boardRepository;

  BoardNotifier(this._boardRepository) : super(const BoardState());

  // 보드 목록 페이지네이션
  Future<void> loadBoards({
    int? page,
    int? size,
    bool isRefresh = false,
  }) async {
    final currentPage = page ?? (isRefresh ? 0 : state.currentPage);
    final pageSize = size ?? state.pageSize;

    if (isRefresh) {
      state = state.copyWith(
        isLoading: true,
        errorMessage: null,
        boards: [],
        currentPage: 0,
      );
    } else {
      state = state.copyWith(isLoading: true, errorMessage: null);
    }

    try {
      final response = await _boardRepository.getBoardsList(
        page: currentPage,
        size: pageSize,
      );

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
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  // 보드 추가 로딩
  Future<void> loadMoreBoards() async {
    if (state.hasMoreData && !state.isLoading) {
      await loadBoards(page: state.currentPage + 1);
    }
  }

  // 보드 상세페이지
  Future<void> loadBoardDetail(int id) async {
    state = state.copyWith(isLoadingDetail: true, errorMessage: null);

    try {
      final response = await _boardRepository.getBoardDetail(id);
      state = state.copyWith(selectedBoard: response, isLoadingDetail: false);
    } catch (e) {
      state = state.copyWith(
        isLoadingDetail: false,
        errorMessage: e.toString(),
      );
    }
  }

  // 카테고리
  Future<void> loadCategories() async {
    try {
      final categories = await _boardRepository.getBoardCategories();
      state = state.copyWith(categories: categories);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  // 보드 생성
  Future<bool> createBoard({
    required String title,
    required String content,
    required String category,
    String? imagePath,
  }) async {
    state = state.copyWith(isCreating: true, errorMessage: null);

    try {
      await _boardRepository.createBoard(
        title: title,
        content: content,
        category: category,
        imagePath: imagePath,
      );

      state = state.copyWith(isCreating: false);

      // Refresh boards list after creation
      await loadBoards(isRefresh: true);

      return true;
    } catch (e) {
      state = state.copyWith(isCreating: false, errorMessage: e.toString());
      return false;
    }
  }

  // 보드 수정
  Future<bool> updateBoard({
    required int id,
    required String title,
    required String content,
    required String category,
    String? imagePath,
  }) async {
    state = state.copyWith(isUpdating: true, errorMessage: null);

    try {
      await _boardRepository.updateBoard(
        id: id,
        title: title,
        content: content,
        category: category,
        imagePath: imagePath,
      );

      state = state.copyWith(isUpdating: false);

      // Refresh boards list and detail after update
      await loadBoards(isRefresh: true);
      await loadBoardDetail(id);

      return true;
    } catch (e) {
      state = state.copyWith(isUpdating: false, errorMessage: e.toString());
      return false;
    }
  }

  // 보드 삭제
  Future<bool> deleteBoard(int id) async {
    state = state.copyWith(isDeleting: true, errorMessage: null);

    try {
      await _boardRepository.deleteBoard(id);

      state = state.copyWith(isDeleting: false, selectedBoard: null);

      // Refresh boards list after deletion
      await loadBoards(isRefresh: true);

      return true;
    } catch (e) {
      state = state.copyWith(isDeleting: false, errorMessage: e.toString());
      return false;
    }
  }

  // 에러 메시지 초기화
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  // 선택된 보드 초기화
  void clearSelectedBoard() {
    state = state.copyWith(selectedBoard: null);
  }

  // 모든 데이터 새로고침
  Future<void> refresh() async {
    await Future.wait([loadBoards(isRefresh: true), loadCategories()]);
  }
}
