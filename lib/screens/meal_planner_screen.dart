import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/meal_planner_provider.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../widgets/common_widgets.dart';
import 'package:uuid/uuid.dart';

class MealPlannerScreen extends StatelessWidget {
  const MealPlannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FoodieBackground(
      child: Consumer<MealPlannerProvider>(
        builder: (context, planner, _) {
          return CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('📅', style: TextStyle(fontSize: 32)),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Weekly Meal',
                                style: GoogleFonts.playfairDisplay(
                                  color: FoodieTheme.textPrimary, fontSize: 24, fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'Planner 🗓️',
                                style: GoogleFonts.playfairDisplay(
                                  color: FoodieTheme.secondary, fontSize: 20, fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => _confirmClearAll(context, planner),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: FoodieTheme.bgCard,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: FoodieTheme.divider),
                              ),
                              child: const Icon(Icons.refresh_rounded, color: FoodieTheme.textMuted, size: 20),
                            ),
                          ),
                        ],
                      ).animate().fadeIn(duration: 600.ms),
                      const SizedBox(height: 4),
                      Text(
                        'Plan your meals for the whole week',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 20),

                      // Day Selector
                      _DaySelector(planner: planner),
                    ],
                  ),
                ),
              ),

              // Day Plan
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: _DayPlanSection(planner: planner),
                ),
              ),

              // Meal Library Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '🍽️ Meal Library',
                            style: GoogleFonts.playfairDisplay(
                              color: FoodieTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => _showAddMealDialog(context, planner),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [FoodieTheme.primary, Color(0xFFFF9A5C)]),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.add_rounded, color: Colors.white, size: 16),
                                  const SizedBox(width: 4),
                                  Text('Add', style: GoogleFonts.poppins(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Category filter
                      SizedBox(
                        height: 36,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: mealCategories.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, i) {
                            final cat = mealCategories[i];
                            final isSelected = planner.selectedCategory == cat;
                            return GestureDetector(
                              onTap: () => planner.selectCategory(cat),
                              child: AnimatedContainer(
                                duration: 200.ms,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  gradient: isSelected
                                      ? const LinearGradient(colors: [FoodieTheme.primary, Color(0xFFFF9A5C)])
                                      : null,
                                  color: isSelected ? null : FoodieTheme.bgCard,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected ? Colors.transparent : FoodieTheme.divider,
                                  ),
                                ),
                                child: Text(
                                  cat,
                                  style: GoogleFonts.poppins(
                                    color: isSelected ? Colors.white : FoodieTheme.textSecondary,
                                    fontSize: 12,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Meal Library Grid
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 95),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.3,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final meal = planner.filteredMeals[i];
                      return _MealLibraryCard(
                        meal: meal,
                        index: i,
                        onAddToPlan: () => _showAddToPlanDialog(context, planner, meal),
                        onDelete: () => planner.removeMealFromLibrary(meal.id),
                        isDefault: defaultMeals.any((d) => d.id == meal.id),
                      );
                    },
                    childCount: planner.filteredMeals.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmClearAll(BuildContext context, MealPlannerProvider planner) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: FoodieTheme.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Clear Weekly Plan?', style: GoogleFonts.playfairDisplay(color: FoodieTheme.textPrimary)),
        content: Text('This will remove all meals from your weekly plan.', style: GoogleFonts.poppins(color: FoodieTheme.textSecondary, fontSize: 14)),
        actions: [
          TextButton(child: Text('Cancel', style: GoogleFonts.poppins(color: FoodieTheme.textMuted)), onPressed: () => Navigator.pop(context)),
          ElevatedButton(
            onPressed: () { planner.clearWeeklyPlan(); Navigator.pop(context); },
            style: ElevatedButton.styleFrom(backgroundColor: FoodieTheme.error),
            child: Text('Clear All', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddMealDialog(BuildContext context, MealPlannerProvider planner) {
    final nameCtrl = TextEditingController();
    String selectedEmoji = '🍽️';
    String selectedCategory = 'Other';

    showModalBottomSheet(
      context: context,
      backgroundColor: FoodieTheme.bgCard,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(width: 40, height: 4, decoration: BoxDecoration(color: FoodieTheme.divider, borderRadius: BorderRadius.circular(2))),
              ),
              const SizedBox(height: 16),
              Text('Add New Meal', style: GoogleFonts.playfairDisplay(color: FoodieTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                style: GoogleFonts.poppins(color: FoodieTheme.textPrimary),
                decoration: const InputDecoration(hintText: 'Meal name...', prefixIcon: Icon(Icons.fastfood_rounded, color: FoodieTheme.textMuted)),
              ),
              const SizedBox(height: 12),
              // Emoji picker
              Text('Choose Emoji:', style: GoogleFonts.poppins(color: FoodieTheme.textSecondary, fontSize: 13)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ['🍽️', '🍳', '🍲', '🥗', '🍜', '🍛', '🍕', '🥙', '🫔', '🥩', '🍚', '🥣', '🍮', '🥤']
                    .map((e) => GestureDetector(
                          onTap: () => setModalState(() => selectedEmoji = e),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: selectedEmoji == e ? FoodieTheme.primary.withOpacity(0.3) : FoodieTheme.bgCardLight,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: selectedEmoji == e ? FoodieTheme.primary : FoodieTheme.divider),
                            ),
                            child: Text(e, style: const TextStyle(fontSize: 22)),
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                dropdownColor: FoodieTheme.bgCard,
                style: GoogleFonts.poppins(color: FoodieTheme.textPrimary, fontSize: 14),
                decoration: const InputDecoration(hintText: 'Category'),
                items: mealCategories.where((c) => c != 'All').map((c) =>
                  DropdownMenuItem(value: c, child: Text(c))
                ).toList(),
                onChanged: (v) => setModalState(() => selectedCategory = v ?? 'Other'),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FoodieButton(
                  label: 'Add to Library',
                  icon: Icons.add_rounded,
                  onTap: () {
                    if (nameCtrl.text.trim().isNotEmpty) {
                      planner.addMealToLibrary(SavedMeal(
                        id: const Uuid().v4(),
                        name: nameCtrl.text.trim(),
                        emoji: selectedEmoji,
                        category: selectedCategory,
                      ));
                      Navigator.pop(ctx);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddToPlanDialog(BuildContext context, MealPlannerProvider planner, SavedMeal meal) {
    String selectedDay = planner.selectedDay;
    MealType selectedType = MealType.lunch;

    showModalBottomSheet(
      context: context,
      backgroundColor: FoodieTheme.bgCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(width: 40, height: 4, decoration: BoxDecoration(color: FoodieTheme.divider, borderRadius: BorderRadius.circular(2))),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(meal.emoji, style: const TextStyle(fontSize: 32)),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Add to Plan', style: GoogleFonts.poppins(color: FoodieTheme.textMuted, fontSize: 12)),
                      Text(meal.name, style: GoogleFonts.playfairDisplay(color: FoodieTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text('Select Day', style: GoogleFonts.poppins(color: FoodieTheme.textSecondary, fontSize: 13)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'].asMap().entries.map((e) {
                  final daysFull = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
                  final day = daysFull[e.key];
                  return GestureDetector(
                    onTap: () => setModalState(() => selectedDay = day),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: selectedDay == day
                            ? const LinearGradient(colors: [FoodieTheme.primary, Color(0xFFFF9A5C)])
                            : null,
                        color: selectedDay != day ? FoodieTheme.bgCardLight : null,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: selectedDay == day ? Colors.transparent : FoodieTheme.divider),
                      ),
                      child: Text(
                        e.value,
                        style: GoogleFonts.poppins(
                          color: selectedDay == day ? Colors.white : FoodieTheme.textSecondary,
                          fontSize: 12, fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Text('Meal Time', style: GoogleFonts.poppins(color: FoodieTheme.textSecondary, fontSize: 13)),
              const SizedBox(height: 8),
              Row(
                children: MealType.values.map((type) => Expanded(
                  child: GestureDetector(
                    onTap: () => setModalState(() => selectedType = type),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        gradient: selectedType == type
                            ? const LinearGradient(colors: [FoodieTheme.secondary, Color(0xFFFFB700)])
                            : null,
                        color: selectedType != type ? FoodieTheme.bgCardLight : null,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: selectedType == type ? Colors.transparent : FoodieTheme.divider),
                      ),
                      child: Column(
                        children: [
                          Text(type.emoji, style: const TextStyle(fontSize: 18)),
                          Text(
                            type.label,
                            style: GoogleFonts.poppins(
                              color: selectedType == type ? FoodieTheme.bgDark : FoodieTheme.textSecondary,
                              fontSize: 10, fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FoodieButton(
                  label: 'Add to ${selectedDay.substring(0, 3)} ${selectedType.label}',
                  icon: Icons.check_rounded,
                  onTap: () {
                    planner.addMealToPlan(selectedDay, selectedType, meal);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${meal.emoji} ${meal.name} added to $selectedDay ${selectedType.label}!'),
                        backgroundColor: FoodieTheme.accent,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Day Selector ────────────────────────────────────────────────────────────
class _DaySelector extends StatelessWidget {
  final MealPlannerProvider planner;

  const _DaySelector({required this.planner});

  @override
  Widget build(BuildContext context) {
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final shorts = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return SizedBox(
      height: 70,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final isSelected = planner.selectedDay == days[i];
          final hasEntries = planner.weeklyPlan.plan[days[i]]!.isNotEmpty;

          return GestureDetector(
            onTap: () => planner.selectDay(days[i]),
            child: AnimatedContainer(
              duration: 200.ms,
              width: 58,
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(colors: [FoodieTheme.primary, Color(0xFFFF9A5C)], begin: Alignment.topLeft, end: Alignment.bottomRight)
                    : null,
                color: isSelected ? null : FoodieTheme.bgCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isSelected ? Colors.transparent : FoodieTheme.divider),
                boxShadow: isSelected ? [
                  BoxShadow(color: FoodieTheme.primary.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))
                ] : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    shorts[i],
                    style: GoogleFonts.poppins(
                      color: isSelected ? Colors.white : FoodieTheme.textSecondary,
                      fontSize: 12, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  if (hasEntries)
                    Container(
                      width: 6, height: 6,
                      margin: const EdgeInsets.only(top: 4),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : FoodieTheme.secondary,
                        shape: BoxShape.circle,
                      ),
                    )
                  else
                    const SizedBox(height: 10),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Day Plan Section ────────────────────────────────────────────────────────
class _DayPlanSection extends StatelessWidget {
  final MealPlannerProvider planner;

  const _DayPlanSection({required this.planner});

  @override
  Widget build(BuildContext context) {
    final dayPlan = planner.selectedDayPlan;

    return FoodieCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${planner.selectedDay}\'s Menu',
                style: GoogleFonts.playfairDisplay(
                  color: FoodieTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                '${dayPlan.length}/4 meals',
                style: GoogleFonts.poppins(color: FoodieTheme.textMuted, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...MealType.values.map((type) {
            final entry = dayPlan[type];
            return _MealSlot(
              type: type,
              entry: entry,
              onRemove: () => planner.removeMealFromPlan(planner.selectedDay, type),
            );
          }),
        ],
      ),
    );
  }
}

class _MealSlot extends StatelessWidget {
  final MealType type;
  final MealEntry? entry;
  final VoidCallback onRemove;

  const _MealSlot({required this.type, required this.entry, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: FoodieTheme.bgCardLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: entry != null ? FoodieTheme.primary.withOpacity(0.3) : FoodieTheme.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: FoodieTheme.bgDark,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(child: Text(type.emoji, style: const TextStyle(fontSize: 18))),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type.label,
                  style: GoogleFonts.poppins(color: FoodieTheme.textMuted, fontSize: 11, fontWeight: FontWeight.w500),
                ),
                Text(
                  entry?.mealName ?? 'Not planned yet',
                  style: GoogleFonts.poppins(
                    color: entry != null ? FoodieTheme.textPrimary : FoodieTheme.textMuted,
                    fontSize: 13,
                    fontWeight: entry != null ? FontWeight.w600 : FontWeight.w400,
                    fontStyle: entry != null ? FontStyle.normal : FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          if (entry != null)
            GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: FoodieTheme.error.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.close_rounded, color: FoodieTheme.error, size: 16),
              ),
            )
          else
            Text(entry?.emoji ?? '', style: const TextStyle(fontSize: 20)),
        ],
      ),
    );
  }
}

// ─── Meal Library Card ───────────────────────────────────────────────────────
class _MealLibraryCard extends StatelessWidget {
  final SavedMeal meal;
  final int index;
  final VoidCallback onAddToPlan;
  final VoidCallback onDelete;
  final bool isDefault;

  const _MealLibraryCard({
    required this.meal,
    required this.index,
    required this.onAddToPlan,
    required this.onDelete,
    required this.isDefault,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onAddToPlan,
      child: Container(
        decoration: BoxDecoration(
          gradient: FoodieTheme.cardGradient,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: FoodieTheme.divider),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(meal.emoji, style: const TextStyle(fontSize: 32)),
                  const Spacer(),
                  Text(
                    meal.name,
                    style: GoogleFonts.poppins(
                      color: FoodieTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: FoodieTheme.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      meal.category,
                      style: GoogleFonts.poppins(color: FoodieTheme.primary, fontSize: 10, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            // Add to plan indicator
            Positioned(
              top: 10,
              right: 10,
              child: Row(
                children: [
                  if (!isDefault)
                    GestureDetector(
                      onTap: onDelete,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: FoodieTheme.error.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.delete_outline_rounded, color: FoodieTheme.error, size: 14),
                      ),
                    ),
                  if (!isDefault) const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: FoodieTheme.accent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.add_rounded, color: FoodieTheme.accent, size: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate(delay: (index * 60).ms).fadeIn(duration: 400.ms).scale(begin: const Offset(0.9, 0.9));
  }
}
