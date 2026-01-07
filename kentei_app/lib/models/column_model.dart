import 'package:json_annotation/json_annotation.dart';

part 'column_model.g.dart';

@JsonSerializable()
class ColumnModel {
  final String id;
  @JsonKey(name: 'kentei_id')
  final String kenteiId;
  final String title;
  final String content;
  @JsonKey(name: 'order_index')
  final int orderIndex;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  ColumnModel({
    required this.id,
    required this.kenteiId,
    required this.title,
    required this.content,
    this.orderIndex = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ColumnModel.fromJson(Map<String, dynamic> json) =>
      _$ColumnModelFromJson(json);
  Map<String, dynamic> toJson() => _$ColumnModelToJson(this);
}
