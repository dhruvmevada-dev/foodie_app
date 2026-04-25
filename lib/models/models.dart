import 'dart:convert';

// ─── Ingredient Model ───────────────────────────────────────────────────────
class Ingredient {
  final String id;
  final String name;
  final double quantity;
  final String unit;
  final double pricePerUnit;
  final String emoji;

  Ingredient({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.pricePerUnit,
    this.emoji = '🥘',
  });

  double get totalPrice => quantity * pricePerUnit;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'quantity': quantity,
    'unit': unit,
    'pricePerUnit': pricePerUnit,
    'emoji': emoji,
  };

  factory Ingredient.fromJson(Map<String, dynamic> json) => Ingredient(
    id: json['id'],
    name: json['name'],
    quantity: (json['quantity'] as num).toDouble(),
    unit: json['unit'],
    pricePerUnit: (json['pricePerUnit'] as num).toDouble(),
    emoji: json['emoji'] ?? '🥘',
  );

  Ingredient copyWith({
    String? id, String? name, double? quantity,
    String? unit, double? pricePerUnit, String? emoji,
  }) => Ingredient(
    id: id ?? this.id,
    name: name ?? this.name,
    quantity: quantity ?? this.quantity,
    unit: unit ?? this.unit,
    pricePerUnit: pricePerUnit ?? this.pricePerUnit,
    emoji: emoji ?? this.emoji,
  );
}

// ─── Suggested Meal Model ───────────────────────────────────────────────────
class SuggestedMeal {
  final String name;
  final String description;
  final String cookTime;
  final String difficulty;
  final String emoji;
  final List<String> usedIngredients;
  final List<String> steps;
  final String cuisine;
  final int calories;

  SuggestedMeal({
    required this.name,
    required this.description,
    required this.cookTime,
    required this.difficulty,
    required this.emoji,
    required this.usedIngredients,
    required this.steps,
    required this.cuisine,
    required this.calories,
  });

  factory SuggestedMeal.fromJson(Map<String, dynamic> json) => SuggestedMeal(
    name: json['name'] ?? '',
    description: json['description'] ?? '',
    cookTime: json['cookTime'] ?? '30 min',
    difficulty: json['difficulty'] ?? 'Easy',
    emoji: json['emoji'] ?? '🍽️',
    usedIngredients: List<String>.from(json['usedIngredients'] ?? []),
    steps: List<String>.from(json['steps'] ?? []),
    cuisine: json['cuisine'] ?? 'International',
    calories: json['calories'] ?? 0,
  );
}

// ─── Meal Plan Models ───────────────────────────────────────────────────────
enum MealType { breakfast, lunch, dinner, snack }

extension MealTypeExt on MealType {
  String get label {
    switch (this) {
      case MealType.breakfast: return 'Breakfast';
      case MealType.lunch: return 'Lunch';
      case MealType.dinner: return 'Dinner';
      case MealType.snack: return 'Snack';
    }
  }

  String get emoji {
    switch (this) {
      case MealType.breakfast: return '🌅';
      case MealType.lunch: return '☀️';
      case MealType.dinner: return '🌙';
      case MealType.snack: return '🍎';
    }
  }
}

class MealEntry {
  final String id;
  final String mealName;
  final MealType mealType;
  final String emoji;
  final String? notes;

  MealEntry({
    required this.id,
    required this.mealName,
    required this.mealType,
    this.emoji = '🍽️',
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'mealName': mealName,
    'mealType': mealType.index,
    'emoji': emoji,
    'notes': notes,
  };

  factory MealEntry.fromJson(Map<String, dynamic> json) => MealEntry(
    id: json['id'],
    mealName: json['mealName'],
    mealType: MealType.values[json['mealType']],
    emoji: json['emoji'] ?? '🍽️',
    notes: json['notes'],
  );
}

class WeeklyPlan {
  // Key: "Monday", "Tuesday", etc.
  // Value: Map of MealType -> MealEntry
  final Map<String, Map<MealType, MealEntry>> plan;

  WeeklyPlan({required this.plan});

  factory WeeklyPlan.empty() {
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return WeeklyPlan(plan: {for (var d in days) d: {}});
  }

  Map<String, dynamic> toJson() {
    final result = <String, dynamic>{};
    plan.forEach((day, meals) {
      result[day] = {};
      meals.forEach((type, entry) {
        result[day][type.index.toString()] = entry.toJson();
      });
    });
    return result;
  }

  factory WeeklyPlan.fromJson(Map<String, dynamic> json) {
    final plan = <String, Map<MealType, MealEntry>>{};
    json.forEach((day, mealsJson) {
      plan[day] = {};
      (mealsJson as Map<String, dynamic>).forEach((typeStr, entryJson) {
        final type = MealType.values[int.parse(typeStr)];
        plan[day]![type] = MealEntry.fromJson(entryJson as Map<String, dynamic>);
      });
    });
    return WeeklyPlan(plan: plan);
  }
}

// ─── Saved Meal (for meal library) ─────────────────────────────────────────
class SavedMeal {
  final String id;
  final String name;
  final String emoji;
  final String category;
  final String? description;

  SavedMeal({
    required this.id,
    required this.name,
    required this.emoji,
    required this.category,
    this.description,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'emoji': emoji,
    'category': category,
    'description': description,
  };

  factory SavedMeal.fromJson(Map<String, dynamic> json) => SavedMeal(
    id: json['id'],
    name: json['name'],
    emoji: json['emoji'] ?? '🍽️',
    category: json['category'] ?? 'Other',
    description: json['description'],
  );
}

// Default meal categories
const List<String> mealCategories = [
  'All', 'Breakfast', 'Indian', 'Italian', 'Chinese', 'Mexican',
  'Salads', 'Soups', 'Snacks', 'Desserts', 'Drinks', 'Other',
];

// Default meal library
final List<SavedMeal> defaultMeals = [
  SavedMeal(id: 'd1', name: 'Masala Omelette', emoji: '🍳', category: 'Breakfast', description: 'Spicy Indian-style omelette'),
  SavedMeal(id: 'd2', name: 'Poha', emoji: '🍚', category: 'Breakfast', description: 'Flattened rice with veggies'),
  SavedMeal(id: 'd3', name: 'Upma', emoji: '🥣', category: 'Breakfast', description: 'Semolina breakfast dish'),
  SavedMeal(id: 'd4', name: 'Dal Tadka', emoji: '🍲', category: 'Indian', description: 'Lentil curry with tempering'),
  SavedMeal(id: 'd5', name: 'Paneer Butter Masala', emoji: '🧆', category: 'Indian', description: 'Creamy paneer curry'),
  SavedMeal(id: 'd6', name: 'Biryani', emoji: '🍛', category: 'Indian', description: 'Fragrant rice dish'),
  SavedMeal(id: 'd7', name: 'Aloo Gobi', emoji: '🥔', category: 'Indian', description: 'Potato and cauliflower stir-fry'),
  SavedMeal(id: 'd8', name: 'Pasta Arrabiata', emoji: '🍝', category: 'Italian', description: 'Spicy tomato pasta'),
  SavedMeal(id: 'd9', name: 'Pizza Margherita', emoji: '🍕', category: 'Italian', description: 'Classic Italian pizza'),
  SavedMeal(id: 'd10', name: 'Fried Rice', emoji: '🍳', category: 'Chinese', description: 'Wok-tossed rice'),
  SavedMeal(id: 'd11', name: 'Noodle Soup', emoji: '🍜', category: 'Chinese', description: 'Comforting noodle broth'),
  SavedMeal(id: 'd12', name: 'Caesar Salad', emoji: '🥗', category: 'Salads', description: 'Classic Caesar with croutons'),
  SavedMeal(id: 'd13', name: 'Tomato Soup', emoji: '🍅', category: 'Soups', description: 'Creamy roasted tomato soup'),
  SavedMeal(id: 'd14', name: 'Samosa', emoji: '🥟', category: 'Snacks', description: 'Crispy pastry with filling'),
  SavedMeal(id: 'd15', name: 'Gulab Jamun', emoji: '🍮', category: 'Desserts', description: 'Sweet milk-solid dumplings'),
  SavedMeal(id: 'd16', name: 'Mango Lassi', emoji: '🥭', category: 'Drinks', description: 'Refreshing yogurt mango drink'),
  SavedMeal(id: 'd17', name: 'Tacos', emoji: '🌮', category: 'Mexican', description: 'Corn tortilla with fillings'),
  SavedMeal(id: 'd18', name: 'Chole Bhature', emoji: '🫓', category: 'Indian', description: 'Chickpea curry with puffed bread'),
];
