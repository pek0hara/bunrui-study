import 'package:json_annotation/json_annotation.dart';

part 'kentei.g.dart';

@JsonSerializable()
class Kentei {
  final String id;
  final String name;
  final String? description;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  Kentei({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Kentei.fromJson(Map<String, dynamic> json) => _$KenteiFromJson(json);
  Map<String, dynamic> toJson() => _$KenteiToJson(this);
}
