import 'ingredient.dart';

enum FlameLevel {
  off,
  low,
  medium,
  high,
}

extension FlameLevelExtension on FlameLevel {
  String get label {
    switch (this) {
      case FlameLevel.off:
        return 'OFF';
      case FlameLevel.low:
        return 'LOW';
      case FlameLevel.medium:
        return 'MED';
      case FlameLevel.high:
        return 'HIGH';
    }
  }

  String get fullLabel {
    switch (this) {
      case FlameLevel.off:
        return 'FLAME OFF';
      case FlameLevel.low:
        return 'LOW FLAME';
      case FlameLevel.medium:
        return 'MEDIUM FLAME';
      case FlameLevel.high:
        return 'HIGH FLAME';
    }
  }

  static FlameLevel fromString(String? val) {
    switch (val?.toLowerCase()) {
      case 'low':
        return FlameLevel.low;
      case 'medium':
      case 'med':
        return FlameLevel.medium;
      case 'high':
        return FlameLevel.high;
      case 'off':
      default:
        return FlameLevel.off;
    }
  }
}

class CookingStep {
  final String id;
  int order;
  String description;
  int durationMinutes;
  int durationSeconds;
  FlameLevel flame;
  List<Ingredient> ingredients;

  CookingStep({
    required this.id,
    required this.order,
    required this.description,
    this.durationMinutes = 0,
    this.durationSeconds = 0,
    this.flame = FlameLevel.medium,
    List<Ingredient>? ingredients,
  }) : ingredients = ingredients ?? [];

  int get totalSeconds => (durationMinutes * 60) + durationSeconds;

  String get formattedDuration {
    final m = durationMinutes.toString().padLeft(2, '0');
    final s = durationSeconds.toString().padLeft(2, '0');
    return '$m:$s';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'order': order,
        'description': description.trim(),
        'durationMinutes': durationMinutes,
        'durationSeconds': durationSeconds,
        'flame': flame.name,
        'ingredients': ingredients.map((i) => i.toJson()).toList(),
      };

  factory CookingStep.fromJson(Map<String, dynamic> json) => CookingStep(
        id: json['id'] as String? ?? '',
        order: json['order'] as int? ?? 0,
        description: json['description'] as String? ?? '',
        durationMinutes: json['durationMinutes'] as int? ?? 0,
        durationSeconds: json['durationSeconds'] as int? ?? 0,
        flame: FlameLevelExtension.fromString(json['flame'] as String?),
        ingredients: (json['ingredients'] as List<dynamic>? ?? [])
            .map((i) => Ingredient.fromJson(i as Map<String, dynamic>))
            .toList(),
      );

  CookingStep copyWith({
    String? id,
    int? order,
    String? description,
    int? durationMinutes,
    int? durationSeconds,
    FlameLevel? flame,
    List<Ingredient>? ingredients,
  }) {
    return CookingStep(
      id: id ?? this.id,
      order: order ?? this.order,
      description: description ?? this.description,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      flame: flame ?? this.flame,
      ingredients:
          ingredients ?? this.ingredients.map((i) => i.copyWith()).toList(),
    );
  }
}
