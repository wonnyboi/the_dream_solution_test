import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BoardListScreen extends ConsumerStatefulWidget {
  const BoardListScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _BoardListScreenState();
}

class _BoardListScreenState extends ConsumerState<BoardListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('게시판 목록')),
      body: const Center(child: Text('게시판 목록')),
    );
  }
}
