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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeTabController();
      ref.read(boardProvider.notifier).loadBoards(isRefresh: true);
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
        length: categories.length + 1,
        vsync: this,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final boardState = ref.watch(boardProvider);

    if (_tabController == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFF7F9FB),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: _buildAppBar(boardState),
      body: _buildBody(boardState),
    );
  }

  AppBar _buildAppBar(BoardState boardState) {
    return AppBar(
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
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: _buildTabBar(boardState),
      ),
    );
  }

  TabBar _buildTabBar(BoardState boardState) {
    return TabBar(
      controller: _tabController,
      isScrollable: true,
      tabs: [
        const Tab(text: '전체'),
        ...boardState.categories.entries.map((entry) => Tab(text: entry.value)),
      ],
      onTap: (index) {
        final category =
            index == 0
                ? 'ALL'
                : boardState.categories.keys.elementAt(index - 1);
        ref.read(boardProvider.notifier).changeCategory(category);
      },
    );
  }

  Widget _buildBody(BoardState boardState) {
    return Column(
      children: [
        _buildBoardCount(boardState),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildBoardList(boardState),
              ...boardState.categories.keys.map(
                (_) => _buildBoardList(boardState),
              ),
            ],
          ),
        ),
        _buildPagination(boardState),
      ],
    );
  }

  Widget _buildBoardCount(BoardState boardState) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          Text(
            '총 ${boardState.totalFilteredElements}개의 게시글',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildSortButton() {
    final boardState = ref.watch(boardProvider);

    return PopupMenuButton<String>(
      icon: const Icon(Icons.sort),
      tooltip: '정렬',
      color: Colors.white,
      onSelected: (String value) {
        if (value == 'createdAt' || value == 'category') {
          ref
              .read(boardProvider.notifier)
              .changeSort(
                value,
                boardState.sortBy == value ? !boardState.sortAscending : false,
              );
        } else if (value == 'toggle') {
          ref
              .read(boardProvider.notifier)
              .changeSort(boardState.sortBy, !boardState.sortAscending);
        }
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
                    '작성일 ${boardState.sortBy == 'createdAt' ? (boardState.sortAscending ? '↑' : '↓') : ''}',
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
                    boardState.sortAscending
                        ? Icons.arrow_downward
                        : Icons.arrow_upward,
                  ),
                  const SizedBox(width: 8),
                  Text(boardState.sortAscending ? '내림차순' : '오름차순'),
                ],
              ),
            ),
          ],
    );
  }

  Widget _buildBoardList(BoardState boardState) {
    if (boardState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final boards = boardState.filteredAndSortedBoards;

    if (boards.isEmpty) {
      return const Center(child: Text('게시글이 없습니다.'));
    }

    return ListView.builder(
      itemCount: boards.length,
      itemBuilder: (context, index) {
        final board = boards[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(board.title),
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

  Widget _buildPagination(BoardState boardState) {
    final totalPages =
        (boardState.totalFilteredElements / boardState.pageSize).ceil();
    final pages = <Widget>[];

    pages.add(
      IconButton(
        icon: const Icon(Icons.chevron_left),
        onPressed:
            boardState.currentPage > 0 && !boardState.isLoading
                ? () async {
                  await ref
                      .read(boardProvider.notifier)
                      .changePage(boardState.currentPage - 1);
                }
                : null,
      ),
    );

    for (int i = 0; i < totalPages; i++) {
      if (i == boardState.currentPage) {
        pages.add(
          Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                '${i + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      } else if (i == 0 ||
          i == totalPages - 1 ||
          (i >= boardState.currentPage - 1 &&
              i <= boardState.currentPage + 1)) {
        pages.add(
          TextButton(
            onPressed:
                !boardState.isLoading
                    ? () async {
                      await ref.read(boardProvider.notifier).changePage(i);
                    }
                    : null,
            child: Text('${i + 1}'),
          ),
        );
      } else if (i == boardState.currentPage - 2 ||
          i == boardState.currentPage + 2) {
        pages.add(const Text('...'));
      }
    }

    pages.add(
      IconButton(
        icon: const Icon(Icons.chevron_right),
        onPressed:
            boardState.currentPage < totalPages - 1 && !boardState.isLoading
                ? () async {
                  await ref
                      .read(boardProvider.notifier)
                      .changePage(boardState.currentPage + 1);
                }
                : null,
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: pages),
    );
  }
}
