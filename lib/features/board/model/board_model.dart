class Board {
  final int id;
  final String title;
  final String category;
  final DateTime createdAt;

  Board({
    required this.id,
    required this.title,
    required this.category,
    required this.createdAt,
  });

  factory Board.fromJson(Map<String, dynamic> json) {
    return Board(
      id: json['id'] as int,
      title: json['title'] as String,
      category: json['category'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class Pageable {
  final int pageNumber;
  final int pageSize;
  final Sort sort;
  final int offset;
  final bool unpaged;
  final bool paged;

  Pageable({
    required this.pageNumber,
    required this.pageSize,
    required this.sort,
    required this.offset,
    required this.unpaged,
    required this.paged,
  });

  factory Pageable.fromJson(Map<String, dynamic> json) {
    return Pageable(
      pageNumber: json['pageNumber'] as int,
      pageSize: json['pageSize'] as int,
      sort: Sort.fromJson(json['sort'] as Map<String, dynamic>),
      offset: json['offset'] as int,
      unpaged: json['unpaged'] as bool,
      paged: json['paged'] as bool,
    );
  }
}

class Sort {
  final bool unsorted;
  final bool sorted;
  final bool empty;

  Sort({required this.unsorted, required this.sorted, required this.empty});

  factory Sort.fromJson(Map<String, dynamic> json) {
    return Sort(
      unsorted: json['unsorted'] as bool,
      sorted: json['sorted'] as bool,
      empty: json['empty'] as bool,
    );
  }
}

class BoardResponse {
  final List<Board> content;
  final Pageable pageable;
  final int totalPages;
  final int totalElements;
  final bool last;
  final int numberOfElements;
  final int size;
  final int number;
  final Sort sort;
  final bool first;
  final bool empty;

  BoardResponse({
    required this.content,
    required this.pageable,
    required this.totalPages,
    required this.totalElements,
    required this.last,
    required this.numberOfElements,
    required this.size,
    required this.number,
    required this.sort,
    required this.first,
    required this.empty,
  });

  factory BoardResponse.fromJson(Map<String, dynamic> json) {
    return BoardResponse(
      content:
          (json['content'] as List)
              .map((board) => Board.fromJson(board as Map<String, dynamic>))
              .toList(),
      pageable: Pageable.fromJson(json['pageable'] as Map<String, dynamic>),
      totalPages: json['totalPages'] as int,
      totalElements: json['totalElements'] as int,
      last: json['last'] as bool,
      numberOfElements: json['numberOfElements'] as int,
      size: json['size'] as int,
      number: json['number'] as int,
      sort: Sort.fromJson(json['sort'] as Map<String, dynamic>),
      first: json['first'] as bool,
      empty: json['empty'] as bool,
    );
  }
}

class BoardDetailResponse {
  final int id;
  final String title;
  final String content;
  final String boardCategory;
  final String? imageUrl;
  final DateTime createdAt;

  BoardDetailResponse({
    required this.id,
    required this.title,
    required this.content,
    required this.boardCategory,
    this.imageUrl,
    required this.createdAt,
  });

  factory BoardDetailResponse.fromJson(Map<String, dynamic> json) {
    return BoardDetailResponse(
      id: json['id'] as int,
      title: json['title'] as String,
      content: json['content'] as String,
      boardCategory: json['boardCategory'] as String,
      imageUrl: json['imageUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class BoardCategoryResponse {
  final Map<String, String> categories;

  BoardCategoryResponse({required this.categories});

  factory BoardCategoryResponse.fromJson(Map<String, dynamic> json) {
    return BoardCategoryResponse(categories: Map<String, String>.from(json));
  }
}
