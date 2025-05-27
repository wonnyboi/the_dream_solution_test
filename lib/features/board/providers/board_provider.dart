import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_dream_solution/features/board/api/board_api.dart';
import 'package:the_dream_solution/features/board/model/board_model.dart';

final boardApiProvider = Provider<BoardApi>((ref) => BoardApi());

final boardProvider = StateNotifierProvider<BoardNotifier, BoardState>((ref) {
  return BoardNotifier(ref.read(boardApiProvider));
});

/// 게시판 상태
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
  final String selectedCategory;
  final String sortBy;
  final bool sortAscending;

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
    this.selectedCategory = 'ALL',
    this.sortBy = 'createdAt',
    this.sortAscending = false,
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
    String? selectedCategory,
    String? sortBy,
    bool? sortAscending,
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
      selectedCategory: selectedCategory ?? this.selectedCategory,
      sortBy: sortBy ?? this.sortBy,
      sortAscending: sortAscending ?? this.sortAscending,
    );
  }

  /// 필터링 및 정렬된 게시판 목록
  List<Board> get filteredAndSortedBoards {
    var filteredBoards = boards;

    if (selectedCategory != 'ALL') {
      filteredBoards =
          filteredBoards
              .where((board) => board.category == selectedCategory)
              .toList();
    }

    filteredBoards.sort((a, b) {
      if (sortBy == 'createdAt') {
        return sortAscending
            ? a.createdAt.compareTo(b.createdAt)
            : b.createdAt.compareTo(a.createdAt);
      } else {
        return sortAscending
            ? a.category.compareTo(b.category)
            : b.category.compareTo(a.category);
      }
    });

    return filteredBoards;
  }

  /// 필터링된 총 게시판 수
  int get totalFilteredElements {
    if (selectedCategory == 'ALL') {
      return totalElements;
    }
    return boards.where((board) => board.category == selectedCategory).length;
  }
}

/// 게시판 상태 관리
class BoardNotifier extends StateNotifier<BoardState> {
  final BoardApi _boardApi;

  BoardNotifier(this._boardApi) : super(const BoardState());

  /// 게시판 목록 조회
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
      rethrow;
    }
  }

  /// 카테고리 변경
  void changeCategory(String category) {
    state = state.copyWith(selectedCategory: category, currentPage: 0);
  }

  /// 정렬 변경
  void changeSort(String sortBy, bool ascending) {
    state = state.copyWith(sortBy: sortBy, sortAscending: ascending);
  }

  /// 페이지 변경
  Future<void> changePage(int page) async {
    await loadBoards(page: page);
  }

  /// 추가 게시판 로드
  Future<void> loadMoreBoards() async {
    if (state.hasMoreData && !state.isLoading) {
      await loadBoards(page: state.currentPage + 1);
    }
  }

  /// 게시판 상세 조회
  Future<void> loadBoardDetail(int id) async {
    state = state.copyWith(isLoadingDetail: true);

    try {
      final response = await _boardApi.getBoardDetail(id);
      state = state.copyWith(selectedBoard: response, isLoadingDetail: false);
    } catch (e) {
      state = state.copyWith(isLoadingDetail: false);
      rethrow;
    }
  }

  /// 카테고리 목록 조회
  Future<void> loadCategories() async {
    final categories = await _boardApi.getBoardCategories();
    state = state.copyWith(categories: categories);
  }

  /// 게시판 생성
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
      await loadBoards(isRefresh: true);

      return createdBoardId;
    } catch (e) {
      state = state.copyWith(isCreating: false);
      rethrow;
    }
  }

  /// 게시판 수정
  Future<void> updateBoard({
    required int id,
    required BoardRequest request,
    String? imagePath,
    bool keepExistingImage = false,
  }) async {
    state = state.copyWith(isUpdating: true);

    try {
      await _boardApi.updateBoard(
        id: id,
        request: request,
        imagePath: imagePath,
        keepExistingImage: keepExistingImage,
      );

      state = state.copyWith(isUpdating: false);
      await loadBoards(isRefresh: true);
      await loadBoardDetail(id);
    } catch (e) {
      state = state.copyWith(isUpdating: false);
      rethrow;
    }
  }

  /// 게시판 삭제
  Future<void> deleteBoard(int id) async {
    state = state.copyWith(isDeleting: true);

    try {
      await _boardApi.deleteBoard(id);
      state = state.copyWith(isDeleting: false);
      await loadBoards(isRefresh: true);
    } catch (e) {
      state = state.copyWith(isDeleting: false);
      rethrow;
    }
  }

  /// 선택된 게시판 초기화
  void clearSelectedBoard() {
    state = state.copyWith(selectedBoard: null);
  }

  /// 게시판 상세 상태 초기화
  void resetDetailState() {
    state = state.copyWith(selectedBoard: null, isLoadingDetail: false);
  }

  /// 모든 데이터 새로고침
  Future<void> refresh() async {
    await Future.wait([loadBoards(isRefresh: true), loadCategories()]);
  }
}
