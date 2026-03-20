import 'package:hive/hive.dart';

part 'water_log_model.g.dart';

@HiveType(typeId: 3)
class WaterLog {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  int amount;
  
  @HiveField(2)
  DateTime date;

  WaterLog({
    required this.id,
    required this.amount,
    required this.date,
  });

  WaterLog copyWith({
    String? id,
    int? amount,
    DateTime? date,
  }) {
    return WaterLog(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      date: date ?? this.date,
    );
  }
}
