import 'package:hive/hive.dart';

part 'water_log.g.dart';

@HiveType(typeId: 4)
class WaterLog {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final int amount;

  @HiveField(2)
  final DateTime timestamp;

  @HiveField(3)
  final String? notes;

  WaterLog({
    required this.id,
    required this.amount,
    required this.timestamp,
    this.notes,
  });

  WaterLog copyWith({
    String? id,
    int? amount,
    DateTime? timestamp,
    String? notes,
  }) {
    return WaterLog(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      timestamp: timestamp ?? this.timestamp,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'timestamp': timestamp.toIso8601String(),
      'notes': notes,
    };
  }

  factory WaterLog.fromJson(Map<String, dynamic> json) {
    return WaterLog(
      id: json['id'] as String,
      amount: json['amount'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
      notes: json['notes'] as String?,
    );
  }

  @override
  String toString() {
    return 'WaterLog(id: $id, amount: $amount, timestamp: $timestamp, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WaterLog && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
