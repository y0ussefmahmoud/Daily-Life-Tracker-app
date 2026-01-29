// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'water_log_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WaterLog _$WaterLogFromJson(Map<String, dynamic> json) => WaterLog(
      id: json['id'] as String?,
      userId: json['user_id'] as String?,
      amountMl: (json['amount_ml'] as num).toInt(),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$WaterLogToJson(WaterLog instance) => <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'amount_ml': instance.amountMl,
      'created_at': instance.createdAt?.toIso8601String(),
    };
