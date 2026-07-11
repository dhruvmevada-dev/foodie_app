# 🍳 Foodie — What Can I Cook Right Now?

A vibrant Flutter app with AI-powered meal suggestions, weekly meal planning, and pantry management.

---

## ✨ Features

### Tab 1 — Cook Now 🍳
- Add ingredients you have at home
- Import all ingredients from Pantry with one tap
- AI suggests 4 meals you can make right now
- Keyboard auto-dismisses when tapping **Find Recipes**
- Step-by-step cooking instructions with numbered steps
- Meal stats: cook time, calories, difficulty, cuisine

### Tab 2 — Meal Planner 📅
- 7-day weekly meal planning (Breakfast, Lunch, Dinner, Snack)
- Day selector with dot indicator when meals are planned
- Full meal library with 18+ default meals
- Category filters (Indian, Italian, Chinese, Mexican, etc.)
- Add custom meals with emoji picker to the library
- Tap any library meal → assign to a day & meal slot

### Tab 3 — Pantry 🛒
- Track ingredients with quantity, unit, and price
- Price per unit × quantity = total value per item
- Total pantry value summary card
- Emoji picker for visual ingredient identification
- Edit / delete individual items

---

## 🚀 Setup

### 1. Prerequisites
- Flutter SDK 3.x or higher
- Dart 3.x

### 2. Install dependencies
```bash
flutter pub get
```

### 3. Add your Mistral API Key
Open `lib/services/ai_service.dart` and replace:
```dart
static const String _apiKey = 'YOUR_MISTRAL_API_KEY_HERE';
```
With your actual key from [console.mistral.ai](https://console.mistral.ai)

> **No API key?** The app falls back to 4 built-in demo recipes so you can test all features instantly.

### 4. Run
```bash
flutter run
```

---

## 🤖 AI Integration

The app uses the **Mistral API** directly — no backend needed.

| Setting | Value |
|---|---|
| Endpoint | `https://api.mistral.ai/v1/chat/completions` |
| Model | `mistral-large-latest` |
| Auth | Bearer token in header |

To switch to a cheaper/faster model, change this line in `ai_service.dart`:
```dart
static const String _model = 'mistral-small-latest';
```

---

## 🎨 Tech Stack

| Layer | Technology |
|---|---|
| State Management | `provider` |
| Local Storage | `shared_preferences` |
| AI Integration | Mistral API (via `http`) |
| Animations | `flutter_animate` |
| Typography | `google_fonts` — Playfair Display + Poppins |
| Unique IDs | `uuid` |

---

## 📁 Project Structure

```
lib/
├── main.dart                      # App entry + animated bottom nav
├── theme/
│   └── app_theme.dart             # Colors, fonts, full theme config
├── models/
│   └── models.dart                # All data models + 18 default meals
├── providers/
│   ├── cook_now_provider.dart     # Tab 1 state
│   ├── meal_planner_provider.dart # Tab 2 state + SharedPreferences
│   └── pantry_provider.dart       # Tab 3 state + SharedPreferences
├── services/
│   └── ai_service.dart            # Mistral API integration
├── screens/
│   ├── cook_now_screen.dart       # Tab 1 UI + Recipe Detail screen
│   ├── meal_planner_screen.dart   # Tab 2 UI + meal library
│   └── pantry_screen.dart         # Tab 3 UI + summary card
└── widgets/
    └── common_widgets.dart        # Reusable cards, chips, buttons
```

---

## 🎨 Design System

**Color Palette:**

| Name | Hex | Usage |
|---|---|---|
| Spicy Orange | `#FF6B35` | Primary, buttons, accents |
| Saffron Yellow | `#FFD23F` | Secondary, stats |
| Mint Green | `#06D6A0` | Accent, success states |
| Berry Red | `#EF476F` | Error, calories badge |
| Deep Espresso | `#1A0A00` | App background |
| Dark Mocha | `#2D1506` | Card background |

**Typography:**
- Headings & display → **Playfair Display**
- Body & UI labels → **Poppins**

---

## 🔧 Customization

**Change currency symbol** — Search `₹` in `pantry_screen.dart` and replace with your local symbol (`$`, `€`, `£`, etc.)

**Add more default meals** — Edit the `defaultMeals` list in `lib/models/models.dart`

**Change AI model** — Edit `_model` in `lib/services/ai_service.dart`

**Adjust AI prompt** — Edit the `prompt` string inside `suggestMeals()` in `ai_service.dart`

---

## 🐛 Known Fixes Applied

| Issue | Fix |
|---|---|
| Stats row overflow on small screens | Changed `Row` → `Wrap` in `MealSuggestionCard` |
| Keyboard stays open after tapping Find Recipes | Added `FocusScope.of(context).unfocus()` before API call |

---

## 📱 App Icon

The logo uses a dark espresso circular design with a chef hat, fork, spoon, and the **Foodie** wordmark in Spicy Orange. To generate all launcher icon sizes automatically:

1. Add `flutter_launcher_icons` to `dev_dependencies` in `pubspec.yaml`
2. Place your `logo.png` (1024×1024) in the `assets/images/` folder
3. Run:
```bash
flutter pub run flutter_launcher_icons
```
