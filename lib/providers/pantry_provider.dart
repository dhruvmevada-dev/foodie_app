import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';

class PantryProvider extends ChangeNotifier {
  List<Ingredient> _ingredients = [];
  static const String _key = 'pantry_ingredients';
  final _uuid = const Uuid();

  List<Ingredient> get ingredients => _ingredients;

  double get totalValue =>
      _ingredients.fold(0, (sum, i) => sum + i.totalPrice);

  PantryProvider() {
    _loadIngredients();
  }

  Future<void> _loadIngredients() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_key);
    if (json != null) {
      try {
        final list = jsonDecode(json) as List;
        _ingredients = list.map((i) => Ingredient.fromJson(i)).toList();
        notifyListeners();
      } catch (_) {}
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(_ingredients.map((i) => i.toJson()).toList()),
    );
  }

  Future<void> addIngredient({
    required String name,
    required double quantity,
    required String unit,
    required double pricePerUnit,
    String emoji = '🥘',
  }) async {
    final ingredient = Ingredient(
      id: _uuid.v4(),
      name: name,
      quantity: quantity,
      unit: unit,
      pricePerUnit: pricePerUnit,
      emoji: emoji,
    );
    _ingredients.add(ingredient);
    await _save();
    notifyListeners();
  }

  Future<void> updateIngredient(Ingredient updated) async {
    final idx = _ingredients.indexWhere((i) => i.id == updated.id);
    if (idx != -1) {
      _ingredients[idx] = updated;
      await _save();
      notifyListeners();
    }
  }

  Future<void> removeIngredient(String id) async {
    _ingredients.removeWhere((i) => i.id == id);
    await _save();
    notifyListeners();
  }

  Future<void> clearAll() async {
    _ingredients = [];
    await _save();
    notifyListeners();
  }

  List<String> get ingredientNames =>
      _ingredients.map((i) => i.name).toList();

  // Group by category/unit for display
  Map<String, List<Ingredient>> get groupedIngredients {
    final map = <String, List<Ingredient>>{};
    for (final i in _ingredients) {
      map.putIfAbsent(i.unit, () => []).add(i);
    }
    return map;
  }
}
