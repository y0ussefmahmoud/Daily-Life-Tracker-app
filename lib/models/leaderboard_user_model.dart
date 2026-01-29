import 'package:json_annotation/json_annotation.dart';

part 'leaderboard_user_model.g.dart';

@JsonSerializable()
class LeaderboardUserModel {
  final int rank;
  final String name;
  final String? avatarUrl;
  final int xp;
  final bool isCurrentUser;
  final String? badge;

  const LeaderboardUserModel({
    required this.rank,
    required this.name,
    this.avatarUrl,
    required this.xp,
    required this.isCurrentUser,
    this.badge,
  });

  LeaderboardUserModel copyWith({
    int? rank,
    String? name,
    String? avatarUrl,
    int? xp,
    bool? isCurrentUser,
    String? badge,
  }) {
    return LeaderboardUserModel(
      rank: rank ?? this.rank,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      xp: xp ?? this.xp,
      isCurrentUser: isCurrentUser ?? this.isCurrentUser,
      badge: badge ?? this.badge,
    );
  }

  factory LeaderboardUserModel.fromJson(Map<String, dynamic> json) => _$LeaderboardUserModelFromJson(json);
  Map<String, dynamic> toJson() => _$LeaderboardUserModelToJson(this);

  String get rankDisplay {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return rank.toString();
    }
  }

  bool get hasMedal {
    return rank <= 3;
  }
}
