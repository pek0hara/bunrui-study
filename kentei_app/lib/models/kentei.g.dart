// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kentei.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Kentei _$KenteiFromJson(Map<String, dynamic> json) => Kentei(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$KenteiToJson(Kentei instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};
