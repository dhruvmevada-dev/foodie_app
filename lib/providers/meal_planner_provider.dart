import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class MealPlannerProvider extends ChangeNotifier {
  WeeklyPlan _weeklyPlan = WeeklyPlan.empty();
  List<SavedMeal> _mealLibrary = [];
  String _selectedCategory = 'All';
  String _selectedDay = 'Monday';

  static const String _planKey = 'weekly_plan';
  static const String _libraryKey = 'meal_library';

  WeeklyPlan get weeklyPlan => _weeklyPlan;
  List<SavedMeal> get mealLibrary => _mealLibrary;
  String get selectedCategory => _selectedCategory;
  String get selectedDay => _selectedDay;

  List<SavedMeal> get filteredMeals {
    if (_selectedCategory == 'All') return _mealLibrary;
    return _mealLibrary.where((m) => m.category == _selectedCategory).toList();
  }

  Map<MealType, MealEntry> get selectedDayPlan =>
      _weeklyPlan.plan[_selectedDay] ?? {};

  MealPlannerProvider() {
    _init();
  }

  Future<void> _init() async {
    await _loadData();
    if (_mealLibrary.isEmpty) {
      _mealLibrary = List.from(defaultMeals);
      await _saveLibrary();
    }
    notifyListeners();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    // Load weekly plan
    final planJson = prefs.getString(_planKey);
    if (planJson != null) {
      try {
        _weeklyPlan = WeeklyPlan.fromJson(jsonDecode(planJson));
      } catch (_) {
        _weeklyPlan = WeeklyPlan.empty();
      }
    }

    // Load meal library
    final libraryJson = prefs.getString(_libraryKey);
    if (libraryJson != null) {
      try {
        final list = jsonDecode(libraryJson) as List;
        _mealLibrary = list.map((m) => SavedMeal.fromJson(m)).toList();
      } catch (_) {
        _mealLibrary = [];
      }
    }
  }

  Future<void> _savePlan() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_planKey, jsonEncode(_weeklyPlan.toJson()));
  }

  Future<void> _saveLibrary() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_libraryKey, jsonEncode(_mealLibrary.map((m) => m.toJson()).toList()));
  }

  void selectDay(String day) {
    _selectedDay = day;
    notifyListeners();
  }

  void selectCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Future<void> addMealToPlan(String day, MealType mealType, SavedMeal meal) async {
    final entry = MealEntry(
      id: '${day}_${mealType.index}_${DateTime.now().millisecondsSinceEpoch}',
      mealName: meal.name,
      mealType: mealType,
      emoji: meal.emoji,
      notes: meal.description,
    );
    _weeklyPlan.plan[day]![mealType] = entry;
    await _savePlan();
    notifyListeners();
  }

  Future<void> removeMealFromPlan(String day, MealType mealType) async {
    _weeklyPlan.plan[day]!.remove(mealType);
    await _savePlan();
    notifyListeners();
  }

  Future<void> addCustomMealToPlan(String day, MealType mealType, String mealName, String emoji) async {
    final entry = MealEntry(
      id: '${day}_${mealType.index}_${DateTime.now().millisecondsSinceEpoch}',
      mealName: mealName,
      mealType: mealType,
      emoji: emoji,
    );
    _weeklyPlan.plan[day]![mealType] = entry;
    await _savePlan();
    notifyListeners();
  }

  Future<void> addMealToLibrary(SavedMeal meal) async {
    _mealLibrary.add(meal);
    await _saveLibrary();
    notifyListeners();
  }

  Future<void> removeMealFromLibrary(String id) async {
    _mealLibrary.removeWhere((m) => m.id == id);
    await _saveLibrary();
    notifyListeners();
  }

  Future<void> clearWeeklyPlan() async {
    _weeklyPlan = WeeklyPlan.empty();
    await _savePlan();
    notifyListeners();
  }
}
