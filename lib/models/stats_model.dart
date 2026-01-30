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

  factory WeeklyStats.empty() => WeeklyStats(
    dayName: '',
    percentage: 0.0,
    isToday: false,
  );
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

  factory TimeDistribution.empty() => TimeDistribution(
    category: '',
    hours: 0.0,
    percentage: 0.0,
    icon: Icons.help_outline,
    color: Colors.grey,
  );
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

  factory Achievement.empty() => Achievement(
    title: '',
    subtitle: '',
    icon: Icons.hourglass_empty,
    iconColor: Colors.grey,
    backgroundColor: Colors.grey.withOpacity(0.1),
  );
}
