import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/cook_now_provider.dart';
import '../providers/pantry_provider.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../widgets/common_widgets.dart';

class CookNowScreen extends StatefulWidget {
  const CookNowScreen({super.key});

  @override
  State<CookNowScreen> createState() => _CookNowScreenState();
}

class _CookNowScreenState extends State<CookNowScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addIngredient(CookNowProvider provider) {
    if (_controller.text.trim().isNotEmpty) {
      provider.addIngredient(_controller.text);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<CookNowProvider, PantryProvider>(
      builder: (context, cookNow, pantry, _) {
        return FoodieBackground(
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('🍳', style: TextStyle(fontSize: 32)),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'What Can I Cook',
                                style: GoogleFonts.playfairDisplay(
                                  color: FoodieTheme.textPrimary,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'Right Now? ✨',
                                style: GoogleFonts.playfairDisplay(
                                  color: FoodieTheme.primary,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2),
                      const SizedBox(height: 8),
                      Text(
                        'Add ingredients you have and let AI suggest meals!',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ).animate(delay: 200.ms).fadeIn(),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Ingredient Input
                      _IngredientInput(
                        controller: _controller,
                        focusNode: _focusNode,
                        onAdd: () => _addIngredient(cookNow),
                      ),

                      const SizedBox(height: 12),

                      // Import from Pantry Button
                      if (pantry.ingredients.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            for (final name in pantry.ingredientNames) {
                              cookNow.addIngredient(name);
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Imported ${pantry.ingredients.length} ingredients from Pantry! 🛒'),
                                backgroundColor: FoodieTheme.accent,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: FoodieTheme.accent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: FoodieTheme.accent.withOpacity(0.4)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.download_rounded, color: FoodieTheme.accent, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  'Import from Pantry (${pantry.ingredients.length} items)',
                                  style: GoogleFonts.poppins(
                                    color: FoodieTheme.accent, fontSize: 13, fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ).animate(delay: 300.ms).fadeIn(),

                      const SizedBox(height: 16),

                      // Ingredient chips
                      if (cookNow.inputIngredients.isNotEmpty) ...[
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: cookNow.inputIngredients.asMap().entries.map((e) {
                            return IngredientChip(
                              label: e.value,
                              onDelete: () => cookNow.removeIngredient(e.value),
                            ).animate(delay: (e.key * 50).ms).fadeIn().scale();
                          }).toList(),
                        ),

                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: FoodieButton(
                                label: 'Find Recipes ✨',
                                icon: Icons.auto_awesome_rounded,
                                loading: cookNow.state == CookNowState.loading,
                                onTap: () {
                                  FocusScope.of(context).unfocus();
                                  cookNow.getSuggestions();
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTap: cookNow.clearIngredients,
                              child: Container(
                                height: 52,
                                width: 52,
                                decoration: BoxDecoration(
                                  color: FoodieTheme.bgCardLight,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: FoodieTheme.divider),
                                ),
                                child: const Icon(Icons.refresh_rounded, color: FoodieTheme.textMuted),
                              ),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Results
                      if (cookNow.state == CookNowState.loading)
                        _LoadingState()
                      else if (cookNow.state == CookNowState.loaded)
                        _MealResults(meals: cookNow.suggestedMeals)
                      else if (cookNow.state == CookNowState.error)
                        _ErrorState(message: cookNow.errorMessage)
                      else if (cookNow.inputIngredients.isEmpty)
                        _EmptyPrompt(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _IngredientInput extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onAdd;

  const _IngredientInput({
    required this.controller,
    required this.focusNode,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: FoodieTheme.cardGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: FoodieTheme.divider),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🥬 Add Your Ingredients',
            style: GoogleFonts.poppins(
              color: FoodieTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  style: GoogleFonts.poppins(color: FoodieTheme.textPrimary, fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: 'e.g. tomato, onion, chicken...',
                    prefixIcon: Icon(Icons.search_rounded, color: FoodieTheme.textMuted, size: 20),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onSubmitted: (_) => onAdd(),
                  textInputAction: TextInputAction.done,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onAdd,
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [FoodieTheme.primary, Color(0xFFFF9A5C)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: FoodieTheme.primary.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: FoodieTheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: FoodieTheme.primary.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(color: FoodieTheme.primary, strokeWidth: 2),
              ),
              const SizedBox(width: 12),
              Text(
                '🤖 Chef AI is thinking...',
                style: GoogleFonts.poppins(color: FoodieTheme.primary, fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ).animate(onPlay: (c) => c.repeat(reverse: true)).shimmer(duration: 1500.ms),
        const SizedBox(height: 12),
        ...List.generate(3, (i) => const FoodieShimmerCard()),
      ],
    );
  }
}

class _MealResults extends StatelessWidget {
  final List<SuggestedMeal> meals;
  const _MealResults({required this.meals});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: '${meals.length} Meals Found! 🎉',
          subtitle: 'Tap any meal to see full recipe',
        ),
        const SizedBox(height: 16),
        ...meals.asMap().entries.map((e) => MealSuggestionCard(
          meal: e.value,
          index: e.key,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => RecipeDetailScreen(meal: e.value)),
          ),
        )),
        const SizedBox(height: 75),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return FoodieCard(
      borderColor: FoodieTheme.error,
      child: Column(
        children: [
          const Text('⚠️', style: TextStyle(fontSize: 36)),
          const SizedBox(height: 8),
          Text('Something went wrong', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            'Using demo recipes instead. Add your API key in ai_service.dart',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _EmptyPrompt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        EmptyState(
          emoji: '🧑‍🍳',
          title: 'Let\'s Cook Something!',
          subtitle: 'Add the ingredients you have\nand discover amazing recipes',
        ),
        const SizedBox(height: 24),
        // Suggestion chips
        Text(
          '💡 Try adding:',
          style: GoogleFonts.poppins(color: FoodieTheme.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: ['🍅 tomato', '🧅 onion', '🥚 eggs', '🍗 chicken', '🥔 potato', '🧄 garlic']
              .asMap().entries.map((e) {
            return GestureDetector(
              onTap: () {
                final label = e.value.split(' ').last;
                context.read<CookNowProvider>().addIngredient(label);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: FoodieTheme.bgCardLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: FoodieTheme.divider),
                ),
                child: Text(e.value, style: GoogleFonts.poppins(color: FoodieTheme.textSecondary, fontSize: 13)),
              ),
            ).animate(delay: (e.key * 80).ms).fadeIn().scale();
          }).toList(),
        ),
        const SizedBox(height: 75),
      ],
    );
  }
}

// ─── Recipe Detail Screen ────────────────────────────────────────────────────
class RecipeDetailScreen extends StatelessWidget {
  final SuggestedMeal meal;
  const RecipeDetailScreen({super.key, required this.meal});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FoodieTheme.bgDark,
      body: CustomScrollView(
        slivers: [
          // Hero Header
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: FoodieTheme.bgDark,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: FoodieTheme.bgCard.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_back_rounded, color: FoodieTheme.textPrimary),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      FoodieTheme.primary.withOpacity(0.3),
                      FoodieTheme.bgDark,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),
                    Text(meal.emoji, style: const TextStyle(fontSize: 80)),
                    Text(
                      meal.cuisine,
                      style: GoogleFonts.poppins(
                        color: FoodieTheme.primary, fontSize: 12, fontWeight: FontWeight.w600,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    meal.name,
                    style: GoogleFonts.playfairDisplay(
                      color: FoodieTheme.textPrimary, fontSize: 28, fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(meal.description, style: Theme.of(context).textTheme.bodyLarge),

                  const SizedBox(height: 16),

                  // Stats row
                  Row(
                    children: [
                      _DetailStat('⏱️', meal.cookTime, 'Time'),
                      const SizedBox(width: 12),
                      _DetailStat('🔥', '${meal.calories}', 'Calories'),
                      const SizedBox(width: 12),
                      _DetailStat('📊', meal.difficulty, 'Level'),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Ingredients used
                  FoodieCard(
                    borderColor: FoodieTheme.accent.withOpacity(0.4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('🛒', style: TextStyle(fontSize: 20)),
                            const SizedBox(width: 8),
                            Text(
                              'Ingredients Used',
                              style: GoogleFonts.poppins(
                                color: FoodieTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: meal.usedIngredients.map((i) =>
                            IngredientChip(label: i, deletable: false),
                          ).toList(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Steps
                  Text(
                    '👨‍🍳 Step-by-Step Instructions',
                    style: GoogleFonts.playfairDisplay(
                      color: FoodieTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),

                  ...meal.steps.asMap().entries.map((e) =>
                    _StepCard(stepNumber: e.key + 1, step: e.value, index: e.key),
                  ),

                  const SizedBox(height: 40),

                  // Done cooking button
                  FoodieButton(
                    label: 'Looks Delicious! 😋',
                    icon: Icons.favorite_rounded,
                    color: FoodieTheme.accentPink,
                    onTap: () => Navigator.pop(context),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailStat extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;

  const _DetailStat(this.emoji, this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: FoodieTheme.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: FoodieTheme.divider),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.poppins(
                color: FoodieTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.poppins(color: FoodieTheme.textMuted, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final int stepNumber;
  final String step;
  final int index;

  const _StepCard({required this.stepNumber, required this.step, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FoodieTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: FoodieTheme.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [FoodieTheme.primary, Color(0xFFFF9A5C)]),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '$stepNumber',
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              step,
              style: GoogleFonts.poppins(color: FoodieTheme.textSecondary, fontSize: 13, height: 1.6),
            ),
          ),
        ],
      ),
    ).animate(delay: (index * 80).ms).fadeIn(duration: 400.ms).slideX(begin: 0.1);
  }
}
