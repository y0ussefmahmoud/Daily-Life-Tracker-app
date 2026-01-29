import 'package:json_annotation/json_annotation.dart';

part 'water_log_model.g.dart';

@JsonSerializable()
class WaterLog {
  final String? id;
  @JsonKey(name: 'user_id')
  final String? userId;
  @JsonKey(name: 'amount_ml')
  final int amountMl;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  const WaterLog({
    this.id,
    this.userId,
    required this.amountMl,
    this.createdAt,
  });

  WaterLog copyWith({
    String? id,
    String? userId,
    int? amountMl,
    DateTime? createdAt,
  }) {
    return WaterLog(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amountMl: amountMl ?? this.amountMl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory WaterLog.fromJson(Map<String, dynamic> json) => _$WaterLogFromJson(json);
  Map<String, dynamic> toJson() => _$WaterLogToJson(this);
}
