import 'package:json_annotation/json_annotation.dart';

part 'question.g.dart';

@JsonSerializable()
class Question {
  final String id;
  @JsonKey(name: 'kentei_id')
  final String kenteiId;
  @JsonKey(name: 'question_text')
  final String questionText;
  @JsonKey(name: 'option_a')
  final String optionA;
  @JsonKey(name: 'option_b')
  final String optionB;
  @JsonKey(name: 'option_c')
  final String? optionC;
  @JsonKey(name: 'option_d')
  final String? optionD;
  @JsonKey(name: 'correct_answer')
  final String correctAnswer;
  final String? explanation;
  @JsonKey(name: 'order_index')
  final int orderIndex;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  Question({
    required this.id,
    required this.kenteiId,
    required this.questionText,
    required this.optionA,
    required this.optionB,
    this.optionC,
    this.optionD,
    required this.correctAnswer,
    this.explanation,
    this.orderIndex = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Question.fromJson(Map<String, dynamic> json) =>
      _$QuestionFromJson(json);
  Map<String, dynamic> toJson() => _$QuestionToJson(this);
}
