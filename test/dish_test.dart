import 'package:flutter_test/flutter_test.dart';
import 'package:cookie/models/dish.dart';
import 'package:cookie/models/cooking_step.dart';
import 'package:cookie/models/ingredient.dart';
import 'package:cookie/services/storage_service.dart';

void main() {
  group('Dish & Step Models Test', () {
    test('Calculates total duration and formats correctly', () {
      final step1 = CookingStep(
        id: '1',
        order: 1,
        description: 'Heat pan and add oil',
        durationMinutes: 2,
        durationSeconds: 30,
        flame: FlameLevel.medium,
        ingredients: [
          Ingredient(id: 'i1', name: 'Mustard Seeds', quantity: '1 tsp'),
        ],
      );

      final step2 = CookingStep(
        id: '2',
        order: 2,
        description: 'Add chopped onions and saute',
        durationMinutes: 3,
        durationSeconds: 15,
        flame: FlameLevel.high,
        ingredients: [
          Ingredient(id: 'i2', name: 'Onion', quantity: '1 finely chopped'),
        ],
      );

      final dish = Dish(
        id: 'd1',
        title: 'Tadka Dal',
        steps: [step1, step2],
      );

      // Total seconds: (2*60 + 30) + (3*60 + 15) = 150 + 195 = 345 seconds (5m 45s)
      expect(dish.totalDurationSeconds, 345);
      expect(dish.totalEstimatedTimeFormatted, '5M 45S');
    });

    test('Serializes to JSON and deserializes accurately', () {
      final step = CookingStep(
        id: 's1',
        order: 1,
        description: 'Bring water to boil and add tea leaves',
        durationMinutes: 4,
        durationSeconds: 0,
        flame: FlameLevel.high,
        ingredients: [
          Ingredient(id: 'i1', name: 'Water', quantity: '2 cups'),
          Ingredient(id: 'i2', name: 'Tea Leaves', quantity: '2 tsp'),
        ],
      );

      final originalDish = Dish(
        id: 'd2',
        title: 'Masala Chai',
        steps: [step],
      );

      final storage = StorageService();
      final exportedJson = storage.exportToJson([originalDish]);
      final importedDishes = storage.parseImportJson(exportedJson);

      expect(importedDishes.length, 1);
      final importedDish = importedDishes.first;
      expect(importedDish.title, 'Masala Chai');
      expect(importedDish.steps.length, 1);
      expect(importedDish.steps.first.description, 'Bring water to boil and add tea leaves');
      expect(importedDish.steps.first.flame, FlameLevel.high);
      expect(importedDish.steps.first.ingredients.length, 2);
      expect(importedDish.steps.first.ingredients[0].name, 'Water');
      expect(importedDish.steps.first.ingredients[0].quantity, '2 cups');
    });

    test('Flame levels handle fallback gracefully', () {
      expect(FlameLevelExtension.fromString('low'), FlameLevel.low);
      expect(FlameLevelExtension.fromString('medium'), FlameLevel.medium);
      expect(FlameLevelExtension.fromString('med'), FlameLevel.medium);
      expect(FlameLevelExtension.fromString('high'), FlameLevel.high);
      expect(FlameLevelExtension.fromString('off'), FlameLevel.off);
      expect(FlameLevelExtension.fromString('unknown'), FlameLevel.off);
      expect(FlameLevelExtension.fromString(null), FlameLevel.off);
    });
  });
}
