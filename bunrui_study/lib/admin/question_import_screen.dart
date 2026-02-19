import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/supabase_provider.dart';
import '../models/question.dart';

class QuestionImportScreen extends ConsumerStatefulWidget {
  final String kenteiId;

  const QuestionImportScreen({
    super.key,
    required this.kenteiId,
  });

  @override
  ConsumerState<QuestionImportScreen> createState() =>
      _QuestionImportScreenState();
}

class _QuestionImportScreenState extends ConsumerState<QuestionImportScreen> {
  final _jsonController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  int _importedCount = 0;

  @override
  void dispose() {
    _jsonController.dispose();
    super.dispose();
  }

  Future<void> _importQuestions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _importedCount = 0;
    });

    try {
      final jsonText = _jsonController.text.trim();
      if (jsonText.isEmpty) {
        throw Exception('JSONを入力してください');
      }

      final dynamic jsonData = jsonDecode(jsonText);
      final List<dynamic> questions;

      if (jsonData is List) {
        questions = jsonData;
      } else if (jsonData is Map && jsonData['questions'] is List) {
        questions = jsonData['questions'];
      } else {
        throw Exception('無効なJSON形式です。配列または{"questions": [...]}の形式で入力してください');
      }

      final service = ref.read(supabaseServiceProvider);

      for (var i = 0; i < questions.length; i++) {
        final q = questions[i];

        final String questionType = q['question_type'] ?? 'multiple_choice';
        final QuestionType type = questionType == 'text_input'
            ? QuestionType.textInput
            : QuestionType.multipleChoice;

        await service.createQuestion(
          kenteiId: widget.kenteiId,
          questionText: q['question_text'] ?? q['questionText'] ?? '',
          questionType: type,
          optionA: q['option_a'] ?? q['optionA'],
          optionB: q['option_b'] ?? q['optionB'],
          optionC: q['option_c'] ?? q['optionC'],
          optionD: q['option_d'] ?? q['optionD'],
          correctAnswer: q['correct_answer'] ?? q['correctAnswer'] ?? '',
          explanation: q['explanation'],
          orderIndex: q['order_index'] ?? q['orderIndex'] ?? i,
        );

        setState(() {
          _importedCount = i + 1;
        });
      }

      ref.invalidate(questionsProvider(widget.kenteiId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$_importedCount件の問題をインポートしました')),
        );
        context.go('/admin');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('JSONインポート'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'JSON形式の例',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const SelectableText(
'''[
  {
    "question_text": "問題文",
    "question_type": "multiple_choice",
    "option_a": "選択肢A",
    "option_b": "選択肢B",
    "option_c": "選択肢C",
    "option_d": "選択肢D",
    "correct_answer": "A",
    "explanation": "解説"
  },
  {
    "question_text": "問題文",
    "question_type": "text_input",
    "correct_answer": "ひらがな",
    "explanation": "解説"
  }
]''',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'JSON入力',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _jsonController,
              decoration: const InputDecoration(
                hintText: 'JSON形式で問題を入力してください',
                border: OutlineInputBorder(),
              ),
              maxLines: 15,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.red),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (_isLoading) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(width: 16),
                    Text('インポート中... ($_importedCount件完了)'),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.upload),
                label: const Text('インポート'),
                onPressed: _isLoading ? null : _importQuestions,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
