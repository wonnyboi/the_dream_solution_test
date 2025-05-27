import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_dream_solution/features/auth/presentation/providers/auth_provider.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:the_dream_solution/core/storage/secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:the_dream_solution/features/board/providers/board_provider.dart';
import 'package:the_dream_solution/features/main/presentation/widgets/drawer.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  String _content = '';
  bool _isLoading = true;
  String? _userName;
  String? _userEmail;
  final _secureStorage = SecureStorage();

  @override
  void initState() {
    super.initState();
    _loadReadme();
    _loadUserInfo();
    _loadBoardData();
  }

  Future<void> _loadUserInfo() async {
    final name = await _secureStorage.getName();
    final email = await _secureStorage.getUsername();

    setState(() {
      _userName = name;
      _userEmail = email;
    });
  }

  Future<void> _loadBoardData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await ref.read(boardProvider.notifier).refresh();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('데이터 로딩 중 오류가 발생했습니다: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    });
  }

  Future<void> _loadReadme() async {
    try {
      final String content = await rootBundle.loadString(
        'assets/docs/README.md',
      );
      setState(() {
        _content = content;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _content = 'Error loading content: $e';
        _isLoading = false;
      });
    }
  }

  Widget _buildBoardListSection() {
    final boardState = ref.watch(boardProvider);
    final boardNotifier = ref.read(boardProvider.notifier);

    return Container(
      width: 900,
      height: 600,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '게시판 목록',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () async {
                      try {
                        await boardNotifier.refresh();
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('새로고침 중 오류가 발생했습니다: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.refresh),
                  ),
                  IconButton(
                    onPressed: () => context.push('/board/create'),
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          Expanded(
            child:
                boardState.isLoading && boardState.boards.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : boardState.boards.isEmpty
                    ? const Center(
                      child: Text(
                        '게시글이 없습니다.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                    : ListView.builder(
                      itemCount: boardState.boards.length,
                      itemBuilder: (context, index) {
                        final board = boardState.boards[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            tileColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            title: Text(
                              board.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              '${boardState.categories[board.category] ?? board.category} • ${board.createdAt.toString().split(' ')[0]}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                            ),
                            onTap: () => context.push('/board/${board.id}'),
                          ),
                        );
                      },
                    ),
          ),

          if (boardState.hasMoreData)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Center(
                child: ElevatedButton(
                  onPressed:
                      boardState.isLoading
                          ? null
                          : () async {
                            try {
                              await boardNotifier.loadMoreBoards();
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('더 보기 중 오류가 발생했습니다: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                  child:
                      boardState.isLoading
                          ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Text('더 보기'),
                ),
              ),
            ),
          const SizedBox(height: 16),
          Center(
            child: TextButton.icon(
              onPressed: () => context.push('/board/list'),
              icon: const Icon(Icons.list_alt),
              label: const Text('게시글 전체보기'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      endDrawer: const DrawerWidget(),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F9FB),

        title: const Text('지원자_정휘원'),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Center(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildBoardListSection(),
                      const SizedBox(height: 24),
                      Container(
                        width: 900,
                        height: 600,
                        padding: const EdgeInsets.all(24.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 16,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: MarkdownWidget(
                          data: _content,
                          config: MarkdownConfig.defaultConfig,
                          shrinkWrap: true,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
    );
  }
}
