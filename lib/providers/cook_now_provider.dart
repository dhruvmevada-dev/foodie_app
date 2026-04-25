import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/ai_service.dart';

enum CookNowState { idle, loading, loaded, error }

class CookNowProvider extends ChangeNotifier {
  List<String> _inputIngredients = [];
  String _currentInput = '';
  List<SuggestedMeal> _suggestedMeals = [];
  CookNowState _state = CookNowState.idle;
  String _errorMessage = '';
  SuggestedMeal? _selectedMeal;

  List<String> get inputIngredients => _inputIngredients;
  List<SuggestedMeal> get suggestedMeals => _suggestedMeals;
  CookNowState get state => _state;
  String get errorMessage => _errorMessage;
  SuggestedMeal? get selectedMeal => _selectedMeal;

  void addIngredient(String ingredient) {
    final trimmed = ingredient.trim();
    if (trimmed.isNotEmpty && !_inputIngredients.contains(trimmed.toLowerCase())) {
      _inputIngredients.add(trimmed.toLowerCase());
      notifyListeners();
    }
  }

  void removeIngredient(String ingredient) {
    _inputIngredients.remove(ingredient);
    if (_suggestedMeals.isNotEmpty) {
      _suggestedMeals = [];
      _state = CookNowState.idle;
    }
    notifyListeners();
  }

  void clearIngredients() {
    _inputIngredients = [];
    _suggestedMeals = [];
    _state = CookNowState.idle;
    notifyListeners();
  }

  void selectMeal(SuggestedMeal meal) {
    _selectedMeal = meal;
    notifyListeners();
  }

  void clearSelectedMeal() {
    _selectedMeal = null;
    notifyListeners();
  }

  Future<void> getSuggestions() async {
    if (_inputIngredients.isEmpty) return;

    _state = CookNowState.loading;
    _suggestedMeals = [];
    _errorMessage = '';
    notifyListeners();

    try {
      final meals = await AIService.suggestMeals(_inputIngredients);
      _suggestedMeals = meals;
      _state = CookNowState.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _state = CookNowState.error;
    }

    notifyListeners();
  }
}
