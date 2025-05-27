import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:the_dream_solution/features/board/providers/board_provider.dart';

class BoardListScreen extends ConsumerStatefulWidget {
  const BoardListScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _BoardListScreenState();
}

class _BoardListScreenState extends ConsumerState<BoardListScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  String _selectedCategory = 'ALL';
  String _sortBy = 'createdAt'; // 'createdAt' or 'category'
  bool _sortAscending = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeTabController();
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void _initializeTabController() {
    final categories = ref.read(boardProvider).categories;
    setState(() {
      _tabController?.dispose();
      _tabController = TabController(
        length: categories.length + 1, // +1 for 'ALL' tab
        vsync: this,
      );
    });
  }

  List<dynamic> _getSortedBoards(List<dynamic> boards) {
    final sortedBoards = List<dynamic>.from(boards);

    if (_selectedCategory != 'ALL') {
      sortedBoards.removeWhere((board) => board.category != _selectedCategory);
    }

    sortedBoards.sort((a, b) {
      if (_sortBy == 'createdAt') {
        return _sortAscending
            ? a.createdAt.compareTo(b.createdAt)
            : b.createdAt.compareTo(a.createdAt);
      } else {
        return _sortAscending
            ? a.category.compareTo(b.category)
            : b.category.compareTo(a.category);
      }
    });

    return sortedBoards;
  }

  Widget _buildSortButton() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.sort),
      tooltip: '정렬',
      color: Colors.white,
      onSelected: (String value) {
        setState(() {
          if (value == 'createdAt' || value == 'category') {
            _sortBy = value;
          } else if (value == 'toggle') {
            _sortAscending = !_sortAscending;
          }
        });
      },
      itemBuilder:
          (BuildContext context) => [
            PopupMenuItem(
              value: 'createdAt',
              child: Row(
                children: [
                  const Icon(Icons.access_time),
                  const SizedBox(width: 8),
                  Text(
                    '작성일 ${_sortBy == 'createdAt' ? (_sortAscending ? '↑' : '↓') : ''}',
                  ),
                ],
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              value: 'toggle',
              child: Row(
                children: [
                  Icon(
                    _sortAscending ? Icons.arrow_downward : Icons.arrow_upward,
                  ),
                  const SizedBox(width: 8),
                  Text(_sortAscending ? '내림차순' : '오름차순'),
                ],
              ),
            ),
          ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final boardState = ref.watch(boardProvider);
    final categories = boardState.categories;

    if (_tabController == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFF7F9FB),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F9FB),
        title: const Text('게시글 목록'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          _buildSortButton(),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/board/create'),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            const Tab(text: '전체'),
            ...categories.entries.map((entry) => Tab(text: entry.value)),
          ],
          onTap: (index) {
            setState(() {
              _selectedCategory =
                  index == 0 ? 'ALL' : categories.keys.elementAt(index - 1);
            });
          },
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBoardList(boardState),
          ...categories.keys.map((_) => _buildBoardList(boardState)),
        ],
      ),
    );
  }

  Widget _buildBoardList(BoardState boardState) {
    final sortedBoards = _getSortedBoards(boardState.boards);

    if (boardState.isLoading && boardState.boards.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (sortedBoards.isEmpty) {
      return const Center(
        child: Text(
          '게시글이 없습니다.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedBoards.length,
      itemBuilder: (context, index) {
        final board = sortedBoards[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            tileColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              board.title,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              '${boardState.categories[board.category] ?? board.category} • ${board.createdAt.toString().split(' ')[0]}',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => context.push('/board/${board.id}'),
          ),
        );
      },
    );
  }
}
