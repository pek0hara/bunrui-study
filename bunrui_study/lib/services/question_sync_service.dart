import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/question.dart';
import 'supabase_service.dart';

class QuestionSyncService {
  final SupabaseService _supabaseService;

  QuestionSyncService(this._supabaseService);

  /// Load questions from JSON asset file
  Future<List<Map<String, dynamic>>> loadQuestionsFromAsset(
      String assetPath) async {
    try {
      final jsonString = await rootBundle.loadString(assetPath);
      final List<dynamic> jsonData = jsonDecode(jsonString);
      return jsonData.cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error loading questions from asset: $e');
      return [];
    }
  }

  /// Sync questions from JSON to database
  /// Only adds questions that don't already exist in the database
  Future<int> syncQuestionsToDatabase({
    required String kenteiId,
    required String assetPath,
  }) async {
    try {
      // Load questions from asset
      final jsonQuestions = await loadQuestionsFromAsset(assetPath);
      if (jsonQuestions.isEmpty) {
        return 0;
      }

      // Get existing questions from database
      final existingQuestions =
          await _supabaseService.getQuestionsByKenteiId(kenteiId);

      int importedCount = 0;

      for (var i = 0; i < jsonQuestions.length; i++) {
        final q = jsonQuestions[i];

        // Check if question already exists (by question_text)
        final questionText = q['question_text'] ?? q['questionText'] ?? '';
        final exists = existingQuestions.any(
          (existing) => existing.questionText == questionText,
        );

        if (exists) {
          continue; // Skip if already exists
        }

        // Parse question type
        final String questionType = q['question_type'] ?? 'multiple_choice';
        final QuestionType type = questionType == 'text_input'
            ? QuestionType.textInput
            : QuestionType.multipleChoice;

        // Create question in database
        await _supabaseService.createQuestion(
          kenteiId: kenteiId,
          questionText: questionText,
          questionType: type,
          optionA: q['option_a'] ?? q['optionA'],
          optionB: q['option_b'] ?? q['optionB'],
          optionC: q['option_c'] ?? q['optionC'],
          optionD: q['option_d'] ?? q['optionD'],
          correctAnswer: q['correct_answer'] ?? q['correctAnswer'] ?? '',
          explanation: q['explanation'],
          orderIndex: q['order_index'] ?? q['orderIndex'] ?? i,
        );

        importedCount++;
      }

      return importedCount;
    } catch (e) {
      print('Error syncing questions to database: $e');
      return 0;
    }
  }

  /// Export questions from database to JSON format
  Future<String> exportQuestionsToJson({
    required String kenteiId,
  }) async {
    try {
      final questions =
          await _supabaseService.getQuestionsByKenteiId(kenteiId);

      final List<Map<String, dynamic>> jsonQuestions = questions.map((q) {
        final Map<String, dynamic> json = {
          'question_text': q.questionText,
          'question_type': q.questionType == QuestionType.multipleChoice
              ? 'multiple_choice'
              : 'text_input',
          'correct_answer': q.correctAnswer,
          'order_index': q.orderIndex,
        };

        if (q.questionType == QuestionType.multipleChoice) {
          if (q.optionA != null) json['option_a'] = q.optionA;
          if (q.optionB != null) json['option_b'] = q.optionB;
          if (q.optionC != null) json['option_c'] = q.optionC;
          if (q.optionD != null) json['option_d'] = q.optionD;
        }

        if (q.explanation != null && q.explanation!.isNotEmpty) {
          json['explanation'] = q.explanation;
        }

        return json;
      }).toList();

      // Format JSON with indentation
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(jsonQuestions);
    } catch (e) {
      print('Error exporting questions to JSON: $e');
      rethrow;
    }
  }
}
