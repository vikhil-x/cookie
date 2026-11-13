import 'cooking_step.dart';

class Dish {
  final String id;
  String title;
  DateTime createdAt;
  List<CookingStep> steps;

  Dish({
    required this.id,
    required this.title,
    DateTime? createdAt,
    List<CookingStep>? steps,
  })  : createdAt = createdAt ?? DateTime.now(),
        steps = steps ?? [];

  int get totalDurationSeconds {
    return steps.fold<int>(0, (sum, step) => sum + step.totalSeconds);
  }

  String get totalEstimatedTimeFormatted {
    final totalSec = totalDurationSeconds;
    if (totalSec == 0) return '0 MIN';
    final hours = totalSec ~/ 3600;
    final mins = (totalSec % 3600) ~/ 60;
    final secs = totalSec % 60;

    if (hours > 0) {
      if (mins > 0) {
        return '${hours}H ${mins}M';
      }
      return '${hours}H';
    }
    if (mins > 0 && secs > 0) {
      return '${mins}M ${secs}S';
    } else if (mins > 0) {
      return '$mins MIN';
    } else {
      return '$secs SEC';
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title.trim(),
        'createdAt': createdAt.toIso8601String(),
        'steps': steps.map((s) => s.toJson()).toList(),
      };

  factory Dish.fromJson(Map<String, dynamic> json) => Dish(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
            : DateTime.now(),
        steps: (json['steps'] as List<dynamic>? ?? [])
            .map((s) => CookingStep.fromJson(s as Map<String, dynamic>))
            .toList(),
      );

  Dish copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    List<CookingStep>? steps,
  }) {
    return Dish(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      steps: steps ?? this.steps.map((s) => s.copyWith()).toList(),
    );
  }
}
