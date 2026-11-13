import 'package:flutter/foundation.dart';
import '../models/dish.dart';
import '../services/storage_service.dart';

class DishProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();

  List<Dish> _dishes = [];
  bool _isLoading = true;

  List<Dish> get dishes => List.unmodifiable(_dishes);
  bool get isLoading => _isLoading;
  bool get isEmpty => _dishes.isEmpty;

  DishProvider() {
    loadDishes();
  }

  Future<void> loadDishes() async {
    _isLoading = true;
    notifyListeners();

    _dishes = await _storageService.loadDishes();
    _isLoading = false;
    notifyListeners();
  }

  Dish? getDish(String id) {
    try {
      return _dishes.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> addDish(Dish dish) async {
    _dishes.insert(0, dish);
    notifyListeners();
    await _storageService.saveDishes(_dishes);
  }

  Future<void> updateDish(Dish updatedDish) async {
    final index = _dishes.indexWhere((d) => d.id == updatedDish.id);
    if (index != -1) {
      _dishes[index] = updatedDish;
      notifyListeners();
      await _storageService.saveDishes(_dishes);
    }
  }

  Future<void> deleteDish(String id) async {
    _dishes.removeWhere((d) => d.id == id);
    notifyListeners();
    await _storageService.saveDishes(_dishes);
  }

  /// Import dishes from parsed list
  Future<int> importDishes(List<Dish> importedDishes, {bool overwrite = false}) async {
    if (overwrite) {
      _dishes = List.from(importedDishes);
    } else {
      // Merge: Update existing if id matches, otherwise prepend new dishes
      for (final newDish in importedDishes) {
        final existingIdx = _dishes.indexWhere((d) => d.id == newDish.id);
        if (existingIdx != -1) {
          _dishes[existingIdx] = newDish;
        } else {
          _dishes.add(newDish);
        }
      }
    }
    notifyListeners();
    await _storageService.saveDishes(_dishes);
    return importedDishes.length;
  }

  String exportJson() {
    return _storageService.exportToJson(_dishes);
  }
}
