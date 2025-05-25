import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_dream_solution/features/auth/presentation/providers/auth_provider.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:the_dream_solution/core/storage/secure_storage.dart';
import 'package:go_router/go_router.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  String _content = '';
  bool _isLoading = true;
  String? _userName;
  final _secureStorage = SecureStorage();

  @override
  void initState() {
    super.initState();
    _loadReadme();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final name = await _secureStorage.getName();
    setState(() {
      _userName = name;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F9FB),
        title: const Text('더드림솔루션'),
        actions: [
          if (_userName != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                child: Text(
                  '안녕하세요! $_userName 님!',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                context.pushReplacement('/login');
              }
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Center(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        width: 900,
                        height: 900,
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
                      Container(
                        width: 900,
                        height: 900,
                        padding: const EdgeInsets.all(24.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(children: [Text('안녕하세요! $_userName 님!')]),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
