import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/supabase_provider.dart';

class QuestionCreateScreen extends ConsumerStatefulWidget {
  final String kenteiId;

  const QuestionCreateScreen({
    super.key,
    required this.kenteiId,
  });

  @override
  ConsumerState<QuestionCreateScreen> createState() =>
      _QuestionCreateScreenState();
}

class _QuestionCreateScreenState extends ConsumerState<QuestionCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final _optionAController = TextEditingController();
  final _optionBController = TextEditingController();
  final _optionCController = TextEditingController();
  final _optionDController = TextEditingController();
  final _explanationController = TextEditingController();
  String _correctAnswer = 'A';
  bool _isLoading = false;

  @override
  void dispose() {
    _questionController.dispose();
    _optionAController.dispose();
    _optionBController.dispose();
    _optionCController.dispose();
    _optionDController.dispose();
    _explanationController.dispose();
    super.dispose();
  }

  Future<void> _createQuestion() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final service = ref.read(supabaseServiceProvider);
      await service.createQuestion(
        kenteiId: widget.kenteiId,
        questionText: _questionController.text,
        optionA: _optionAController.text,
        optionB: _optionBController.text,
        optionC: _optionCController.text.isEmpty
            ? null
            : _optionCController.text,
        optionD: _optionDController.text.isEmpty
            ? null
            : _optionDController.text,
        correctAnswer: _correctAnswer,
        explanation: _explanationController.text.isEmpty
            ? null
            : _explanationController.text,
      );

      ref.invalidate(questionsProvider(widget.kenteiId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('問題を作成しました')),
        );
        context.go('/admin');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('エラー: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('問題の作成'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _questionController,
                decoration: const InputDecoration(
                  labelText: '問題文',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '問題文を入力してください';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _optionAController,
                decoration: const InputDecoration(
                  labelText: '選択肢 A',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '選択肢Aを入力してください';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _optionBController,
                decoration: const InputDecoration(
                  labelText: '選択肢 B',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '選択肢Bを入力してください';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _optionCController,
                decoration: const InputDecoration(
                  labelText: '選択肢 C（任意）',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _optionDController,
                decoration: const InputDecoration(
                  labelText: '選択肢 D（任意）',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _correctAnswer,
                decoration: const InputDecoration(
                  labelText: '正解',
                  border: OutlineInputBorder(),
                ),
                items: ['A', 'B', 'C', 'D'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _correctAnswer = newValue!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _explanationController,
                decoration: const InputDecoration(
                  labelText: '解説（任意）',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createQuestion,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('作成'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
