import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'board_provider.dart';

// Example usage of BoardProvider in a widget
class BoardListExample extends ConsumerStatefulWidget {
  const BoardListExample({super.key});

  @override
  ConsumerState<BoardListExample> createState() => _BoardListExampleState();
}

class _BoardListExampleState extends ConsumerState<BoardListExample> {
  @override
  void initState() {
    super.initState();
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(boardProvider.notifier).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final boardState = ref.watch(boardProvider);
    final boardNotifier = ref.read(boardProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('게시판'),
        actions: [
          IconButton(
            onPressed: () => boardNotifier.refresh(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          // Error message
          if (boardState.errorMessage != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.red.shade100,
              child: Row(
                children: [
                  Icon(Icons.error, color: Colors.red.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      boardState.errorMessage!,
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ),
                  IconButton(
                    onPressed: () => boardNotifier.clearError(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

          // Loading indicator
          if (boardState.isLoading && boardState.boards.isEmpty)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else
            // Board list
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => boardNotifier.loadBoards(isRefresh: true),
                child: ListView.builder(
                  itemCount:
                      boardState.boards.length +
                      (boardState.hasMoreData ? 1 : 0),
                  itemBuilder: (context, index) {
                    // Load more indicator
                    if (index == boardState.boards.length) {
                      if (boardState.hasMoreData) {
                        // Trigger load more
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          boardNotifier.loadMoreBoards();
                        });
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      return const SizedBox.shrink();
                    }

                    final board = boardState.boards[index];
                    return ListTile(
                      title: Text(board.title),
                      subtitle: Text(
                        '${boardState.categories[board.category] ?? board.category} • ${board.createdAt.toString().split(' ')[0]}',
                      ),
                      onTap: () => boardNotifier.loadBoardDetail(board.id),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateBoardDialog(context, boardNotifier),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreateBoardDialog(BuildContext context, BoardNotifier notifier) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    String selectedCategory = 'FREE';

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('새 게시글 작성'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: '제목'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(labelText: '내용'),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                Consumer(
                  builder: (context, ref, child) {
                    final categories = ref.watch(boardProvider).categories;
                    return DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: const InputDecoration(labelText: '카테고리'),
                      items:
                          categories.entries
                              .map(
                                (entry) => DropdownMenuItem(
                                  value: entry.key,
                                  child: Text(entry.value),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        if (value != null) selectedCategory = value;
                      },
                    );
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소'),
              ),
              Consumer(
                builder: (context, ref, child) {
                  final isCreating = ref.watch(boardProvider).isCreating;
                  return ElevatedButton(
                    onPressed:
                        isCreating
                            ? null
                            : () async {
                              final success = await notifier.createBoard(
                                title: titleController.text,
                                content: contentController.text,
                                category: selectedCategory,
                              );
                              if (success && context.mounted) {
                                Navigator.pop(context);
                              }
                            },
                    child:
                        isCreating
                            ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Text('작성'),
                  );
                },
              ),
            ],
          ),
    );
  }
}
