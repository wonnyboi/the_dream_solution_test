import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:the_dream_solution/features/board/model/board_model.dart';
import 'dart:io';
import 'package:the_dream_solution/features/board/providers/board_provider.dart';
import 'package:the_dream_solution/core/config/env.dart';

class BoardCreateScreen extends ConsumerStatefulWidget {
  final int? boardId;
  const BoardCreateScreen({super.key, this.boardId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _BoardCreateScreenState();
}

class _BoardCreateScreenState extends ConsumerState<BoardCreateScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _selectedCategory = '';
  File? _selectedImage;
  String? _existingImageUrl;
  final ImagePicker _imagePicker = ImagePicker();

  String? _titleError;
  String? _contentError;
  String? _categoryError;

  bool get _isEditMode => widget.boardId != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(boardProvider.notifier).loadCategories();
      if (_isEditMode) {
        _loadBoardForEdit();
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _loadBoardForEdit() async {
    try {
      await ref.read(boardProvider.notifier).loadBoardDetail(widget.boardId!);
      final board = ref.read(boardProvider).selectedBoard;
      if (board != null) {
        setState(() {
          _titleController.text = board.title;
          _contentController.text = board.content;
          _selectedCategory = board.boardCategory;
          if (board.imageUrl != null) {
            _existingImageUrl = '${Env.dreamServer}${board.imageUrl}';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('게시글을 불러오는 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitleField(),
            const SizedBox(height: 16),
            _buildCategoryField(),
            const SizedBox(height: 16),
            _buildImageField(),
            const SizedBox(height: 16),
            _buildContentField(),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFF7F9FB),
      title: Text(_isEditMode ? '게시글 수정' : '게시글 작성'),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      actions: [
        TextButton(
          onPressed: _isFormValid() ? _createBoard : null,
          child: Text(
            _isEditMode ? '수정' : '작성',
            style: TextStyle(
              color: _isFormValid() ? Colors.blue : Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('제목', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _titleController,
          onChanged: _validateTitle,
          decoration: InputDecoration(
            hintText: '게시글 제목을 입력해주세요',
            filled: true,
            fillColor: const Color(0xFFF1F5F9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            errorText: _titleError,
            suffixIcon: _buildCheckIcon(
              _titleError == null && _titleController.text.isNotEmpty,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryField() {
    final categories = ref.watch(boardProvider).categories;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('카테고리', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCategory.isEmpty ? null : _selectedCategory,
              isExpanded: true,
              hint: const Text('카테고리를 선택해주세요'),
              items:
                  categories.entries.map((entry) {
                    return DropdownMenuItem<String>(
                      value: entry.key,
                      child: Text(entry.value),
                    );
                  }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedCategory = value;
                    _validateCategory(value);
                  });
                }
              },
            ),
          ),
        ),
        if (_categoryError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _categoryError!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildImageField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('이미지', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8),
          ),
          child:
              _selectedImage != null
                  ? Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          _selectedImage!,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: _removeImage,
                        ),
                      ),
                    ],
                  )
                  : _existingImageUrl != null
                  ? Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          _existingImageUrl!,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: _removeImage,
                        ),
                      ),
                    ],
                  )
                  : Center(
                    child: TextButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.add_photo_alternate),
                      label: const Text('이미지 추가'),
                    ),
                  ),
        ),
      ],
    );
  }

  Widget _buildContentField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('내용', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _contentController,
          onChanged: _validateContent,
          maxLines: 10,
          decoration: InputDecoration(
            hintText: '게시글 내용을 입력해주세요',
            filled: true,
            fillColor: const Color(0xFFF1F5F9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            errorText: _contentError,
            suffixIcon: _buildCheckIcon(
              _contentError == null && _contentController.text.isNotEmpty,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckIcon(bool isValid) {
    return isValid
        ? const Icon(Icons.check_circle, color: Colors.green, size: 20)
        : const SizedBox.shrink();
  }

  void _validateTitle(String value) {
    setState(() {
      if (value.trim().isEmpty) {
        _titleError = '제목을 입력해주세요';
      } else if (value.trim().length < 2) {
        _titleError = '제목은 2자 이상 입력해주세요';
      } else if (value.trim().length > 100) {
        _titleError = '제목은 100자 이하로 입력해주세요';
      } else {
        _titleError = null;
      }
    });
  }

  void _validateContent(String value) {
    setState(() {
      if (value.trim().isEmpty) {
        _contentError = '내용을 입력해주세요';
      } else if (value.trim().length < 10) {
        _contentError = '내용은 10자 이상 입력해주세요';
      } else if (value.trim().length > 5000) {
        _contentError = '내용은 5000자 이하로 입력해주세요';
      } else {
        _contentError = null;
      }
    });
  }

  void _validateCategory(String value) {
    setState(() {
      if (value.isEmpty) {
        _categoryError = '카테고리를 선택해주세요';
      } else {
        _categoryError = null;
      }
    });
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('이미지 선택 중 오류가 발생했습니다: $e')));
      }
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
      _existingImageUrl = null;
    });
  }

  bool _isFormValid() {
    return _titleError == null &&
        _contentError == null &&
        _categoryError == null &&
        _titleController.text.trim().isNotEmpty &&
        _contentController.text.trim().isNotEmpty &&
        _selectedCategory.isNotEmpty;
  }

  Future<void> _createBoard() async {
    _validateTitle(_titleController.text);
    _validateContent(_contentController.text);
    _validateCategory(_selectedCategory);

    if (!_isFormValid()) {
      return;
    }

    final boardRequest = BoardRequest(
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      category: _selectedCategory,
    );

    try {
      if (_isEditMode) {
        await ref
            .read(boardProvider.notifier)
            .updateBoard(
              id: widget.boardId!,
              request: boardRequest,
              imagePath: _selectedImage?.path,
              keepExistingImage:
                  _existingImageUrl != null && _selectedImage == null,
            );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('게시글이 성공적으로 수정되었습니다!'),
              backgroundColor: Colors.green,
            ),
          );
          context.pushReplacement('/board/${widget.boardId}');
        }
      } else {
        final createdBoardId = await ref
            .read(boardProvider.notifier)
            .createBoard(
              request: boardRequest,
              imagePath: _selectedImage?.path,
            );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('게시글이 성공적으로 작성되었습니다!'),
              backgroundColor: Colors.green,
            ),
          );
          context.pushReplacement('/board/$createdBoardId');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('게시글 ${_isEditMode ? '수정' : '작성'} 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
