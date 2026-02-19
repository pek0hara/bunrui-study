// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Question _$QuestionFromJson(Map<String, dynamic> json) => Question(
  id: json['id'] as String,
  kenteiId: json['kentei_id'] as String,
  questionText: json['question_text'] as String,
  questionType:
      $enumDecodeNullable(_$QuestionTypeEnumMap, json['question_type']) ??
      QuestionType.multipleChoice,
  optionA: json['option_a'] as String?,
  optionB: json['option_b'] as String?,
  optionC: json['option_c'] as String?,
  optionD: json['option_d'] as String?,
  correctAnswer: json['correct_answer'] as String,
  explanation: json['explanation'] as String?,
  orderIndex: (json['order_index'] as num?)?.toInt() ?? 0,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$QuestionToJson(Question instance) => <String, dynamic>{
  'id': instance.id,
  'kentei_id': instance.kenteiId,
  'question_text': instance.questionText,
  'question_type': _$QuestionTypeEnumMap[instance.questionType]!,
  'option_a': instance.optionA,
  'option_b': instance.optionB,
  'option_c': instance.optionC,
  'option_d': instance.optionD,
  'correct_answer': instance.correctAnswer,
  'explanation': instance.explanation,
  'order_index': instance.orderIndex,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};

const _$QuestionTypeEnumMap = {
  QuestionType.multipleChoice: 'multiple_choice',
  QuestionType.textInput: 'text_input',
};
