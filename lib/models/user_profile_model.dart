import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_profile_model.g.dart';

@JsonSerializable()
class UserProfileModel {
  final String id;
  final String name;
  final String subtitle;
  final String? avatarUrl;
  final int badgeCount;
  final int streakDays;
  final int points;

  const UserProfileModel({
    required this.id,
    required this.name,
    required this.subtitle,
    this.avatarUrl,
    required this.badgeCount,
    required this.streakDays,
    required this.points,
  });

  UserProfileModel copyWith({
    String? id,
    String? name,
    String? subtitle,
    String? avatarUrl,
    int? badgeCount,
    int? streakDays,
    int? points,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      subtitle: subtitle ?? this.subtitle,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      badgeCount: badgeCount ?? this.badgeCount,
      streakDays: streakDays ?? this.streakDays,
      points: points ?? this.points,
    );
  }

  factory UserProfileModel.fromJson(Map<String, dynamic> json) => _$UserProfileModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserProfileModelToJson(this);
}
