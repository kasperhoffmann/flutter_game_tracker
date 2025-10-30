import 'package:intl/intl.dart';
import '../models/enums.dart';

class Game {
  final String id;
  final String title;
  final String platform;
  final GameStatus status;
  final int? rating; // 0-10
  final double? hours;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  final String? notes;
  final String? coverUrl;

  Game({
    required this.id,
    required this.title,
    required this.platform,
    required this.status,
    this.rating,
    this.hours,
    this.startedAt,
    this.finishedAt,
    this.notes,
    this.coverUrl,
  });

  Game copyWith({
    String? id,
    String? title,
    String? platform,
    GameStatus? status,
    int? rating,
    double? hours,
    DateTime? startedAt,
    DateTime? finishedAt,
    String? notes,
    String? coverUrl,
  }) {
    return Game(
      id: id ?? this.id,
      title: title ?? this.title,
      platform: platform ?? this.platform,
      status: status ?? this.status,
      rating: rating ?? this.rating,
      hours: hours ?? this.hours,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      notes: notes ?? this.notes,
      coverUrl: coverUrl ?? this.coverUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'platform': platform,
      'status': status.name,
      'rating': rating,
      'hours': hours,
      'startedAt': startedAt?.toIso8601String(),
      'finishedAt': finishedAt?.toIso8601String(),
      'notes': notes,
      'coverUrl': coverUrl,
      'updatedAt': DateTime.now().toIso8601String(),
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  factory Game.fromMap(Map<String, dynamic> map) {
    return Game(
      id: map['id'] as String,
      title: map['title'] as String,
      platform: map['platform'] as String,
      status: GameStatusX.fromString(map['status'] as String),
      rating: map['rating'] as int?,
      hours: (map['hours'] as num?)?.toDouble(),
      startedAt: map['startedAt'] != null ? DateTime.tryParse(map['startedAt']) : null,
      finishedAt: map['finishedAt'] != null ? DateTime.tryParse(map['finishedAt']) : null,
      notes: map['notes'] as String?,
      coverUrl: map['coverUrl'] as String?,
    );
  }

  static String formatDate(DateTime? dt) {
    if (dt == null) return '-';
    return DateFormat.yMMMd().format(dt);
  }
}
