import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class AIService {
  static const String _baseUrl = 'https://api.mistral.ai/v1/chat/completions';
  static const String _apiKey = '8HozjxlXKsB2qwmsRFCF864RHlaNJprp'; // 🔑 Replace this
  static const String _model = 'mistral-large-latest';

  /// Suggests meals based on available ingredients
  static Future<List<SuggestedMeal>> suggestMeals(List<String> ingredients) async {
    if (ingredients.isEmpty) return [];

    final prompt = '''
You are a creative chef. Given these available ingredients: ${ingredients.join(', ')}

Suggest exactly 4 different meals that can be made primarily using these ingredients.
For each meal provide a complete recipe.

Respond ONLY with a valid JSON array (no markdown, no explanation), like this:
[
  {
    "name": "Meal Name",
    "description": "Brief appetizing description",
    "cookTime": "25 min",
    "difficulty": "Easy",
    "emoji": "🍳",
    "cuisine": "Indian",
    "calories": 350,
    "usedIngredients": ["ingredient1", "ingredient2"],
    "steps": [
      "Step 1: Do this first...",
      "Step 2: Then do this...",
      "Step 3: Finally..."
    ]
  }
]

Rules:
- Use only or mostly the given ingredients
- Steps should be detailed and practical (minimum 5 steps per meal)
- Difficulty must be one of: Easy, Medium, Hard
- Emoji must be a food-relevant emoji
- Make it practical for home cooking
''';

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {'role': 'user', 'content': prompt},
          ],
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['choices'][0]['message']['content'] as String;
        final cleaned = text.trim().replaceAll(RegExp(r'```json|```'), '').trim();
        final List<dynamic> mealsJson = jsonDecode(cleaned);
        return mealsJson.map((m) => SuggestedMeal.fromJson(m)).toList();
      } else {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print("Mistral Error: $e");
      return _getMockMeals(ingredients);
    }
  }

  /// Fallback mock meals for development/demo without API key
  static List<SuggestedMeal> _getMockMeals(List<String> ingredients) {
    return [
      SuggestedMeal(
        name: 'Quick Stir Fry',
        description: 'A vibrant, healthy stir-fry using your fresh ingredients',
        cookTime: '20 min',
        difficulty: 'Easy',
        emoji: '🥘',
        cuisine: 'Asian',
        calories: 320,
        usedIngredients: ingredients.take(3).toList(),
        steps: [
          '🔪 Step 1: Wash and chop all vegetables into bite-sized pieces.',
          '🫙 Step 2: Mix soy sauce, garlic, and a pinch of sugar in a bowl.',
          '🔥 Step 3: Heat oil in a wok over high heat until smoking.',
          '🥬 Step 4: Add vegetables in order of hardness — hardest first.',
          '🍳 Step 5: Toss everything together and pour in the sauce.',
          '🍽️ Step 6: Serve hot over steamed rice. Garnish with sesame seeds.',
        ],
      ),
      SuggestedMeal(
        name: 'Hearty Soup',
        description: 'A warming, nourishing soup perfect for any time of day',
        cookTime: '35 min',
        difficulty: 'Easy',
        emoji: '🍲',
        cuisine: 'International',
        calories: 280,
        usedIngredients: ingredients.take(4).toList(),
        steps: [
          '🧅 Step 1: Dice onions, garlic, and any root vegetables finely.',
          '🫒 Step 2: Sauté onion and garlic in olive oil until golden.',
          '🥕 Step 3: Add harder vegetables and cook for 5 minutes.',
          '💧 Step 4: Pour in 4 cups of water or stock. Bring to a boil.',
          '🌿 Step 5: Add remaining ingredients and season with salt and pepper.',
          '⏰ Step 6: Simmer for 20 minutes until everything is tender.',
          '🍽️ Step 7: Blend partially for creaminess or serve as-is with bread.',
        ],
      ),
      SuggestedMeal(
        name: 'Savory Rice Bowl',
        description: 'A satisfying rice bowl packed with flavor and nutrition',
        cookTime: '30 min',
        difficulty: 'Medium',
        emoji: '🍚',
        cuisine: 'Fusion',
        calories: 450,
        usedIngredients: ingredients.take(3).toList(),
        steps: [
          '🍚 Step 1: Rinse 1 cup of rice thoroughly and cook with 2 cups water.',
          '🥩 Step 2: Season your protein with salt, pepper, and spices.',
          '🔥 Step 3: Cook protein in a hot pan until golden and cooked through.',
          '🥗 Step 4: Prepare your vegetables — sauté or keep fresh.',
          '🫙 Step 5: Make a simple dressing with available condiments.',
          '🍽️ Step 6: Assemble bowl — rice first, then toppings, then sauce.',
          '✨ Step 7: Garnish with herbs or sesame seeds and serve immediately.',
        ],
      ),
      SuggestedMeal(
        name: 'Spiced Flatbread Wrap',
        description: 'A quick, portable wrap bursting with fresh flavors',
        cookTime: '15 min',
        difficulty: 'Easy',
        emoji: '🫔',
        cuisine: 'Fusion',
        calories: 380,
        usedIngredients: ingredients.take(2).toList(),
        steps: [
          '🫓 Step 1: Warm your flatbread or make a simple dough if needed.',
          '🌿 Step 2: Mix together a simple sauce — yogurt, garlic, and herbs.',
          '🔥 Step 3: Quickly sauté any protein or vegetables with spices.',
          '🥗 Step 4: Prepare fresh toppings — slice tomatoes, greens, etc.',
          '🫔 Step 5: Spread sauce on flatbread, add fillings, and wrap tightly.',
          '✂️ Step 6: Cut diagonally and serve with extra dipping sauce.',
        ],
      ),
    ];
  }
}
