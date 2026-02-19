import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/kentei.dart';
import '../models/question.dart';
import '../models/column_model.dart';

class SupabaseService {
  final SupabaseClient _client;

  SupabaseService(this._client);

  static SupabaseClient get client => Supabase.instance.client;

  Future<List<Kentei>> getAllKentei() async {
    final response = await _client
        .from('kentei')
        .select()
        .order('created_at', ascending: true);

    if (response == null) return [];
    return (response as List).map((e) => Kentei.fromJson(e)).toList();
  }

  Future<List<Question>> getQuestionsByKenteiId(String kenteiId) async {
    final response = await _client
        .from('questions')
        .select()
        .eq('kentei_id', kenteiId)
        .order('order_index', ascending: true);

    if (response == null) return [];
    return (response as List).map((e) => Question.fromJson(e)).toList();
  }

  Future<List<ColumnModel>> getColumnsByKenteiId(String kenteiId) async {
    final response = await _client
        .from('columns')
        .select()
        .eq('kentei_id', kenteiId)
        .order('order_index', ascending: true);

    if (response == null) return [];
    return (response as List).map((e) => ColumnModel.fromJson(e)).toList();
  }

  Future<Kentei> createKentei({
    required String name,
    String? description,
  }) async {
    final response = await _client.from('kentei').insert({
      'name': name,
      'description': description,
    }).select().single();

    return Kentei.fromJson(response);
  }

  Future<Question> createQuestion({
    required String kenteiId,
    required String questionText,
    QuestionType questionType = QuestionType.multipleChoice,
    String? optionA,
    String? optionB,
    String? optionC,
    String? optionD,
    required String correctAnswer,
    String? explanation,
    int orderIndex = 0,
  }) async {
    final response = await _client.from('questions').insert({
      'kentei_id': kenteiId,
      'question_text': questionText,
      'question_type': questionType == QuestionType.multipleChoice ? 'multiple_choice' : 'text_input',
      'option_a': optionA,
      'option_b': optionB,
      'option_c': optionC,
      'option_d': optionD,
      'correct_answer': correctAnswer,
      'explanation': explanation,
      'order_index': orderIndex,
    }).select().single();

    return Question.fromJson(response);
  }

  Future<ColumnModel> createColumn({
    required String kenteiId,
    required String title,
    required String content,
    int orderIndex = 0,
  }) async {
    final response = await _client.from('columns').insert({
      'kentei_id': kenteiId,
      'title': title,
      'content': content,
      'order_index': orderIndex,
    }).select().single();

    return ColumnModel.fromJson(response);
  }

  Future<void> updateKentei({
    required String id,
    String? name,
    String? description,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (description != null) data['description'] = description;

    await _client.from('kentei').update(data).eq('id', id);
  }

  Future<void> updateQuestion({
    required String id,
    String? questionText,
    String? optionA,
    String? optionB,
    String? optionC,
    String? optionD,
    String? correctAnswer,
    String? explanation,
    int? orderIndex,
  }) async {
    final data = <String, dynamic>{};
    if (questionText != null) data['question_text'] = questionText;
    if (optionA != null) data['option_a'] = optionA;
    if (optionB != null) data['option_b'] = optionB;
    if (optionC != null) data['option_c'] = optionC;
    if (optionD != null) data['option_d'] = optionD;
    if (correctAnswer != null) data['correct_answer'] = correctAnswer;
    if (explanation != null) data['explanation'] = explanation;
    if (orderIndex != null) data['order_index'] = orderIndex;

    await _client.from('questions').update(data).eq('id', id);
  }

  Future<void> deleteKentei(String id) async {
    await _client.from('kentei').delete().eq('id', id);
  }

  Future<void> deleteQuestion(String id) async {
    await _client.from('questions').delete().eq('id', id);
  }

  Future<void> deleteColumn(String id) async {
    await _client.from('columns').delete().eq('id', id);
  }
}
