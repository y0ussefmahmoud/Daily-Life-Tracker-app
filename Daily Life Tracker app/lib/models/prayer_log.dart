import 'package:hive/hive.dart';

part 'prayer_log.g.dart';

enum PrayerType {
  @HiveField(0)
  fajr,
  @HiveField(1)
  dhuhr,
  @HiveField(2)
  asr,
  @HiveField(3)
  maghrib,
  @HiveField(4)
  isha,
}

@HiveType(typeId: 2)
class PrayerLog {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final PrayerType type;

  @HiveField(2)
  final DateTime date;

  @HiveField(3)
  final bool isCompleted;

  PrayerLog({
    required this.id,
    required this.type,
    required this.date,
    required this.isCompleted,
  });

  PrayerLog copyWith({
    String? id,
    PrayerType? type,
    DateTime? date,
    bool? isCompleted,
  }) {
    return PrayerLog(
      id: id ?? this.id,
      type: type ?? this.type,
      date: date ?? this.date,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
