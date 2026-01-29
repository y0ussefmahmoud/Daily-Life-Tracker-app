import 'package:flutter/material.dart';

class WeeklyStats {
  final String dayName;
  final double percentage;
  final bool isToday;

  WeeklyStats({
    required this.dayName,
    required this.percentage,
    required this.isToday,
  });
}

class TimeDistribution {
  final String category;
  final double hours;
  final double percentage;
  final IconData icon;
  final Color color;

  TimeDistribution({
    required this.category,
    required this.hours,
    required this.percentage,
    required this.icon,
    required this.color,
  });
}

class Achievement {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;

  Achievement({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
  });
}
