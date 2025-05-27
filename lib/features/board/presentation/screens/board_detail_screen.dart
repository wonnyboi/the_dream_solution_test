import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:the_dream_solution/core/config/env.dart';
import 'package:the_dream_solution/features/board/model/board_model.dart';
import 'package:the_dream_solution/features/board/providers/board_provider.dart';

class BoardDetailScreen extends ConsumerStatefulWidget {
  const BoardDetailScreen({super.key, required this.boardId});
  final int boardId;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _BoardDetailScreenState();
}

class _BoardDetailScreenState extends ConsumerState<BoardDetailScreen> {
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Load board detail when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBoardDetail();
    });
  }

  Future<void> _loadBoardDetail() async {
    debugPrint(
      '🔍 BoardDetailScreen: Loading board detail for ID: ${widget.boardId}',
    );

    final boardNotifier = ref.read(boardProvider.notifier);
    // Reset all detail state before loading new detail
    boardNotifier.resetDetailState();

    try {
      setState(() {
        _errorMessage = null;
      });
      await boardNotifier.loadBoardDetail(widget.boardId);
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final boardState = ref.watch(boardProvider);
    final boardNotifier = ref.read(boardProvider.notifier);

    debugPrint(
      '🔍 BoardDetailScreen build: isLoadingDetail=${boardState.isLoadingDetail}, localError=$_errorMessage, selectedBoard=${boardState.selectedBoard?.id}',
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF1F5F9),
        title: const Text('게시글 상세'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (boardState.selectedBoard != null) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                context.push('/board/${widget.boardId}/edit');
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _showDeleteConfirmation(context, boardNotifier),
            ),
          ],
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        child: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: _buildBody(boardState, boardNotifier),
        ),
      ),
    );
  }

  Widget _buildBody(BoardState boardState, BoardNotifier boardNotifier) {
    // Priority 1: Show loading state
    if (boardState.isLoadingDetail) {
      return const Center(child: CircularProgressIndicator());
    }

    // Priority 2: Show content if available
    if (boardState.selectedBoard != null) {
      debugPrint(
        '🔍 BoardDetailScreen: Showing board data (ID: ${boardState.selectedBoard!.id})',
      );
      return _buildBoardContent(boardState.selectedBoard!);
    }

    // Priority 3: Show error only if no content is available
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(
              '오류가 발생했습니다',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadBoardDetail,
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    // Priority 4: Default state
    return const Center(child: Text('게시글을 찾을 수 없습니다.'));
  }

  Widget _buildBoardContent(BoardDetailResponse board) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            board.title,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  board.boardCategory,
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _formatDate(board.createdAt),
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Image if available
          if (board.imageUrl != null && board.imageUrl!.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                '${Env.dreamServer}${board.imageUrl!}',
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.broken_image,
                        size: 48,
                        color: Colors.grey,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 12),
          const Divider(color: Colors.grey),
          const SizedBox(height: 12),

          // Content
          Text(board.content, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    BoardNotifier boardNotifier,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('게시글 삭제'),
          content: const Text('게시글을 삭제하시겠습니까?\n삭제된 게시글은 복구할 수 없습니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true && mounted) {
      try {
        await boardNotifier.deleteBoard(widget.boardId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('게시글이 삭제되었습니다.'),
              backgroundColor: Colors.green,
            ),
          );
          context.pop(); // Go back to previous screen
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('삭제 중 오류가 발생했습니다: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
