import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/supabase_provider.dart';
import '../models/question.dart';

class QuestionScreen extends ConsumerStatefulWidget {
  const QuestionScreen({super.key});

  @override
  ConsumerState<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends ConsumerState<QuestionScreen> {
  int currentQuestionIndex = 0;
  String? selectedAnswer;
  bool showAnswer = false;
  int correctCount = 0;
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void selectAnswer(String answer) {
    setState(() {
      selectedAnswer = answer;
      showAnswer = true;
    });
  }

  void submitTextAnswer(String correctAnswer) {
    setState(() {
      selectedAnswer = _textController.text.trim();
      showAnswer = true;
    });
  }

  void nextQuestion(int totalQuestions) {
    if (currentQuestionIndex < totalQuestions - 1) {
      setState(() {
        if (selectedAnswer != null && showAnswer) {
          final questionsAsync = ref.read(biologyQuestionsProvider);
          questionsAsync.whenData((questions) {
            final currentQuestion = questions[currentQuestionIndex];
            bool isCorrect = false;
            if (currentQuestion.questionType == QuestionType.textInput) {
              isCorrect = selectedAnswer?.toLowerCase() ==
                         currentQuestion.correctAnswer.toLowerCase();
            } else {
              isCorrect = selectedAnswer == currentQuestion.correctAnswer;
            }
            if (isCorrect) {
              correctCount++;
            }
          });
        }
        currentQuestionIndex++;
        selectedAnswer = null;
        showAnswer = false;
        _textController.clear();
      });
    } else {
      if (selectedAnswer != null && showAnswer) {
        final questionsAsync = ref.read(biologyQuestionsProvider);
        questionsAsync.whenData((questions) {
          final currentQuestion = questions[currentQuestionIndex];
          bool isCorrect = false;
          if (currentQuestion.questionType == QuestionType.textInput) {
            isCorrect = selectedAnswer?.toLowerCase() ==
                       currentQuestion.correctAnswer.toLowerCase();
          } else {
            isCorrect = selectedAnswer == currentQuestion.correctAnswer;
          }
          if (isCorrect) {
            correctCount++;
          }
        });
      }
      showResultDialog(totalQuestions);
    }
  }

  void showResultDialog(int totalQuestions) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('結果'),
        content: Text('$totalQuestions問中$correctCount問正解しました！'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('戻る'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                currentQuestionIndex = 0;
                selectedAnswer = null;
                showAnswer = false;
                correctCount = 0;
              });
              Navigator.of(context).pop();
            },
            child: const Text('もう一度挑戦'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final questionsAsync = ref.watch(biologyQuestionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('問題'),
      ),
      body: questionsAsync.when(
        data: (questions) {
          if (questions.isEmpty) {
            return const Center(
              child: Text('問題がありません'),
            );
          }

          final question = questions[currentQuestionIndex];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '問題 ${currentQuestionIndex + 1} / ${questions.length}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                Text(
                  question.questionText,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 32),
                // 問題タイプに応じた表示
                if (question.questionType == QuestionType.multipleChoice) ...[
                  // 4択問題
                  ...(() {
                    final options = [
                      if (question.optionA != null) {'label': 'A', 'text': question.optionA!},
                      if (question.optionB != null) {'label': 'B', 'text': question.optionB!},
                      if (question.optionC != null) {'label': 'C', 'text': question.optionC!},
                      if (question.optionD != null) {'label': 'D', 'text': question.optionD!},
                    ];
                    return options.map((option) {
                      final label = option['label'] as String;
                      final text = option['text'] as String;
                      final isSelected = selectedAnswer == label;
                      final isCorrect = label == question.correctAnswer;

                      Color? backgroundColor;
                      if (showAnswer) {
                        if (isCorrect) {
                          backgroundColor = Colors.green[100];
                        } else if (isSelected && !isCorrect) {
                          backgroundColor = Colors.red[100];
                        }
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: backgroundColor,
                              padding: const EdgeInsets.all(16),
                              alignment: Alignment.centerLeft,
                            ),
                            onPressed: showAnswer ? null : () => selectAnswer(label),
                            child: Text('$label. $text'),
                          ),
                        ),
                      );
                    });
                  })(),
                ] else if (question.questionType == QuestionType.textInput) ...[
                  // ひらがな入力問題
                  TextField(
                    controller: _textController,
                    enabled: !showAnswer,
                    decoration: InputDecoration(
                      hintText: 'ひらがなで入力してください',
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: showAnswer
                          ? (selectedAnswer?.toLowerCase() == question.correctAnswer.toLowerCase()
                              ? Colors.green[100]
                              : Colors.red[100])
                          : null,
                    ),
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  if (!showAnswer)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _textController.text.trim().isEmpty
                            ? null
                            : () => submitTextAnswer(question.correctAnswer),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.all(16),
                        ),
                        child: const Text('回答する', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  if (showAnswer && selectedAnswer != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: selectedAnswer?.toLowerCase() == question.correctAnswer.toLowerCase()
                            ? Colors.green[50]
                            : Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: selectedAnswer?.toLowerCase() == question.correctAnswer.toLowerCase()
                              ? Colors.green
                              : Colors.red,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selectedAnswer?.toLowerCase() == question.correctAnswer.toLowerCase()
                                ? '正解！'
                                : '不正解',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: selectedAnswer?.toLowerCase() == question.correctAnswer.toLowerCase()
                                  ? Colors.green[900]
                                  : Colors.red[900],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('あなたの回答: $selectedAnswer'),
                          Text('正解: ${question.correctAnswer}'),
                        ],
                      ),
                    ),
                  ],
                ],
                if (showAnswer && question.explanation != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '解説',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(question.explanation!),
                      ],
                    ),
                  ),
                ],
                const Spacer(),
                if (showAnswer)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => nextQuestion(questions.length),
                      child: Text(
                        currentQuestionIndex < questions.length - 1
                            ? '次の問題へ'
                            : '結果を見る',
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('エラーが発生しました: $error'),
        ),
      ),
    );
  }
}
