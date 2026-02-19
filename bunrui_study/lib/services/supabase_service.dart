import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/kentei.dart';
import '../models/question.dart';
import '../models/column_model.dart';

/// Cloudflare Workers + D1 REST API クライアント
class ApiService {
  final String _baseUrl;

  ApiService(this._baseUrl);

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
      };

  // ==================== Kentei ====================

  Future<List<Kentei>> getAllKentei() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/kentei'),
      headers: _headers,
    );
    _checkStatus(response);
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((e) => Kentei.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Kentei> createKentei({
    required String name,
    String? description,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/kentei'),
      headers: _headers,
      body: jsonEncode({
        'name': name,
        'description': description,
      }),
    );
    _checkStatus(response, expectedStatus: 201);
    return Kentei.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<void> updateKentei({
    required String id,
    String? name,
    String? description,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (description != null) data['description'] = description;
    final response = await http.put(
      Uri.parse('$_baseUrl/api/kentei/$id'),
      headers: _headers,
      body: jsonEncode(data),
    );
    _checkStatus(response);
  }

  Future<void> deleteKentei(String id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/api/kentei/$id'),
      headers: _headers,
    );
    _checkStatus(response);
  }

  // ==================== Questions ====================

  Future<List<Question>> getQuestionsByKenteiId(String kenteiId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/kentei/$kenteiId/questions'),
      headers: _headers,
    );
    _checkStatus(response);
    final List<dynamic> data = jsonDecode(response.body);
    return data
        .map((e) => Question.fromJson(e as Map<String, dynamic>))
        .toList();
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
    final response = await http.post(
      Uri.parse('$_baseUrl/api/kentei/$kenteiId/questions'),
      headers: _headers,
      body: jsonEncode({
        'question_text': questionText,
        'question_type': questionType == QuestionType.multipleChoice
            ? 'multiple_choice'
            : 'text_input',
        'option_a': optionA,
        'option_b': optionB,
        'option_c': optionC,
        'option_d': optionD,
        'correct_answer': correctAnswer,
        'explanation': explanation,
        'order_index': orderIndex,
      }),
    );
    _checkStatus(response, expectedStatus: 201);
    return Question.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
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
    final response = await http.put(
      Uri.parse('$_baseUrl/api/questions/$id'),
      headers: _headers,
      body: jsonEncode(data),
    );
    _checkStatus(response);
  }

  Future<void> deleteQuestion(String id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/api/questions/$id'),
      headers: _headers,
    );
    _checkStatus(response);
  }

  // ==================== Columns ====================

  Future<List<ColumnModel>> getColumnsByKenteiId(String kenteiId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/kentei/$kenteiId/columns'),
      headers: _headers,
    );
    _checkStatus(response);
    final List<dynamic> data = jsonDecode(response.body);
    return data
        .map((e) => ColumnModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ColumnModel> createColumn({
    required String kenteiId,
    required String title,
    required String content,
    int orderIndex = 0,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/kentei/$kenteiId/columns'),
      headers: _headers,
      body: jsonEncode({
        'title': title,
        'content': content,
        'order_index': orderIndex,
      }),
    );
    _checkStatus(response, expectedStatus: 201);
    return ColumnModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<void> deleteColumn(String id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/api/columns/$id'),
      headers: _headers,
    );
    _checkStatus(response);
  }

  // ==================== Private ====================

  void _checkStatus(http.Response response, {int expectedStatus = 200}) {
    if (response.statusCode != expectedStatus) {
      String message = 'API error ${response.statusCode}';
      try {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        message = body['error'] as String? ?? message;
      } catch (_) {}
      throw Exception(message);
    }
  }
}
