// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'column_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ColumnModel _$ColumnModelFromJson(Map<String, dynamic> json) => ColumnModel(
  id: json['id'] as String,
  kenteiId: json['kentei_id'] as String,
  title: json['title'] as String,
  content: json['content'] as String,
  orderIndex: (json['order_index'] as num?)?.toInt() ?? 0,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$ColumnModelToJson(ColumnModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'kentei_id': instance.kenteiId,
      'title': instance.title,
      'content': instance.content,
      'order_index': instance.orderIndex,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
