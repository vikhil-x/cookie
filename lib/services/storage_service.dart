import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/dish.dart';

class StorageService {
  static const String _prefKey = 'cookie_dishes_data_v1';
  static const String _fileName = 'cookie_recipes.json';

  /// Load all dishes from storage
  Future<List<Dish>> loadDishes() async {
    try {
      String? jsonContent;

      // 1. Try reading from local file if on non-web
      if (!kIsWeb) {
        try {
          final dir = await getApplicationDocumentsDirectory();
          final file = File('${dir.path}/$_fileName');
          if (await file.exists()) {
            jsonContent = await file.readAsString();
          }
        } catch (e) {
          debugPrint('Error reading file directly: $e');
        }
      }

      // 2. Fallback to SharedPreferences if file was empty or on web
      if (jsonContent == null || jsonContent.trim().isEmpty) {
        final prefs = await SharedPreferences.getInstance();
        jsonContent = prefs.getString(_prefKey);
      }

      if (jsonContent == null || jsonContent.trim().isEmpty) {
        return [];
      }

      final dynamic decoded = jsonDecode(jsonContent);
      List<dynamic> list;
      if (decoded is Map<String, dynamic> && decoded['dishes'] is List) {
        list = decoded['dishes'] as List<dynamic>;
      } else if (decoded is List) {
        list = decoded;
      } else {
        return [];
      }

      return list
          .map((item) => Dish.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error loading dishes: $e');
      return [];
    }
  }

  /// Save all dishes to storage
  Future<void> saveDishes(List<Dish> dishes) async {
    try {
      final jsonMap = {
        'version': 1,
        'updatedAt': DateTime.now().toIso8601String(),
        'dishes': dishes.map((d) => d.toJson()).toList(),
      };
      final jsonString = const JsonEncoder.withIndent('  ').convert(jsonMap);

      // Save to SharedPreferences for quick cache & Web support
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, jsonString);

      // Save to local file system
      if (!kIsWeb) {
        try {
          final dir = await getApplicationDocumentsDirectory();
          final file = File('${dir.path}/$_fileName');
          await file.writeAsString(jsonString);
        } catch (e) {
          debugPrint('Error saving to file: $e');
        }
      }
    } catch (e) {
      debugPrint('Error saving dishes: $e');
    }
  }

  /// Export dishes to formatted JSON string
  String exportToJson(List<Dish> dishes) {
    final jsonMap = {
      'app': 'Cookie',
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'dishes': dishes.map((d) => d.toJson()).toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(jsonMap);
  }

  /// Parse and validate imported JSON string
  List<Dish> parseImportJson(String jsonString) {
    final dynamic decoded = jsonDecode(jsonString);
    List<dynamic> list;
    if (decoded is Map<String, dynamic> && decoded['dishes'] is List) {
      list = decoded['dishes'] as List<dynamic>;
    } else if (decoded is List) {
      list = decoded;
    } else {
      throw const FormatException('Invalid recipe format. Missing dish list.');
    }

    return list
        .map((item) => Dish.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Save JSON to temporary file for sharing
  Future<File?> createExportFile(String jsonString) async {
    if (kIsWeb) return null;
    try {
      final tempDir = await getTemporaryDirectory();
      final dateStr = DateTime.now().toIso8601String().replaceAll(':', '-').split('.').first;
      final file = File('${tempDir.path}/cookie_backup_$dateStr.json');
      await file.writeAsString(jsonString);
      return file;
    } catch (e) {
      debugPrint('Error creating export file: $e');
      return null;
    }
  }
}
