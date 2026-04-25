import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/pantry_provider.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../widgets/common_widgets.dart';

class PantryScreen extends StatelessWidget {
  const PantryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FoodieBackground(
      child: Consumer<PantryProvider>(
        builder: (context, pantry, _) {
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
                          const Text('🛒', style: TextStyle(fontSize: 32)),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'My Pantry',
                                style: GoogleFonts.playfairDisplay(
                                  color: FoodieTheme.textPrimary, fontSize: 24, fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'Ingredients & Prices 💰',
                                style: GoogleFonts.playfairDisplay(
                                  color: FoodieTheme.accent, fontSize: 18, fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => _showAddDialog(context, pantry),
                            child: Container(
                              width: 46, height: 46,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [FoodieTheme.primary, Color(0xFFFF9A5C)]),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [BoxShadow(color: FoodieTheme.primary.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 3))],
                              ),
                              child: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
                            ),
                          ),
                        ],
                      ).animate().fadeIn(duration: 600.ms),
                      const SizedBox(height: 20),

                      // Summary Card
                      _SummaryCard(pantry: pantry),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              // Ingredient List
              if (pantry.ingredients.isEmpty)
                SliverFillRemaining(
                  child: EmptyState(
                    emoji: '🥡',
                    title: 'Pantry is Empty',
                    subtitle: 'Add ingredients to track\nyour stock and prices',
                    action: FoodieButton(
                      label: 'Add First Ingredient',
                      icon: Icons.add_rounded,
                      onTap: () => _showAddDialog(context, pantry),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        final ingredient = pantry.ingredients[i];
                        return _IngredientRow(
                          ingredient: ingredient,
                          index: i,
                          onEdit: () => _showEditDialog(context, pantry, ingredient),
                          onDelete: () => pantry.removeIngredient(ingredient.id),
                        );
                      },
                      childCount: pantry.ingredients.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _showAddDialog(BuildContext context, PantryProvider pantry) {
    _showIngredientDialog(context, pantry, null);
  }

  void _showEditDialog(BuildContext context, PantryProvider pantry, Ingredient ingredient) {
    _showIngredientDialog(context, pantry, ingredient);
  }

  void _showIngredientDialog(BuildContext context, PantryProvider pantry, Ingredient? existing) {
    final nameCtrl = TextEditingController(text: existing?.name);
    final qtyCtrl = TextEditingController(text: existing?.quantity.toString());
    final priceCtrl = TextEditingController(text: existing?.pricePerUnit.toString());
    String selectedUnit = existing?.unit ?? 'kg';
    String selectedEmoji = existing?.emoji ?? '🥘';

    const units = ['kg', 'g', 'L', 'ml', 'pcs', 'dozen', 'cup', 'tbsp'];
    const emojis = ['🥘', '🥩', '🐟', '🥦', '🧅', '🍅', '🧄', '🌾', '🥛', '🧀', '🥚', '🫙', '🌶️', '🫒', '🍋', '🥕', '🫚', '🧈'];

    showModalBottomSheet(
      context: context,
      backgroundColor: FoodieTheme.bgCard,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(width: 40, height: 4, decoration: BoxDecoration(color: FoodieTheme.divider, borderRadius: BorderRadius.circular(2))),
                ),
                const SizedBox(height: 16),
                Text(
                  existing != null ? 'Edit Ingredient' : 'Add Ingredient',
                  style: GoogleFonts.playfairDisplay(color: FoodieTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),

                // Emoji picker
                Text('Choose Emoji:', style: GoogleFonts.poppins(color: FoodieTheme.textSecondary, fontSize: 12)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 48,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: emojis.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) => GestureDetector(
                      onTap: () => setModalState(() => selectedEmoji = emojis[i]),
                      child: Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: selectedEmoji == emojis[i] ? FoodieTheme.primary.withOpacity(0.3) : FoodieTheme.bgCardLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: selectedEmoji == emojis[i] ? FoodieTheme.primary : FoodieTheme.divider),
                        ),
                        child: Center(child: Text(emojis[i], style: const TextStyle(fontSize: 22))),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: nameCtrl,
                  style: GoogleFonts.poppins(color: FoodieTheme.textPrimary),
                  decoration: const InputDecoration(
                    hintText: 'Ingredient name (e.g. Tomatoes)',
                    prefixIcon: Icon(Icons.eco_rounded, color: FoodieTheme.textMuted),
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: qtyCtrl,
                        keyboardType: TextInputType.number,
                        style: GoogleFonts.poppins(color: FoodieTheme.textPrimary),
                        decoration: const InputDecoration(
                          hintText: 'Quantity',
                          prefixIcon: Icon(Icons.scale_rounded, color: FoodieTheme.textMuted),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: FoodieTheme.bgCardLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: FoodieTheme.divider),
                      ),
                      child: DropdownButton<String>(
                        value: selectedUnit,
                        dropdownColor: FoodieTheme.bgCard,
                        underline: const SizedBox(),
                        style: GoogleFonts.poppins(color: FoodieTheme.textPrimary, fontSize: 14),
                        items: units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                        onChanged: (v) => setModalState(() => selectedUnit = v ?? 'kg'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: priceCtrl,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.poppins(color: FoodieTheme.textPrimary),
                  decoration: const InputDecoration(
                    hintText: 'Price per unit (₹)',
                    prefixIcon: Icon(Icons.currency_rupee_rounded, color: FoodieTheme.textMuted),
                  ),
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: FoodieButton(
                    label: existing != null ? 'Update Ingredient' : 'Add to Pantry',
                    icon: existing != null ? Icons.check_rounded : Icons.add_rounded,
                    onTap: () {
                      final name = nameCtrl.text.trim();
                      final qty = double.tryParse(qtyCtrl.text);
                      final price = double.tryParse(priceCtrl.text);

                      if (name.isNotEmpty && qty != null && price != null) {
                        if (existing != null) {
                          pantry.updateIngredient(existing.copyWith(
                            name: name, quantity: qty, unit: selectedUnit,
                            pricePerUnit: price, emoji: selectedEmoji,
                          ));
                        } else {
                          pantry.addIngredient(
                            name: name, quantity: qty, unit: selectedUnit,
                            pricePerUnit: price, emoji: selectedEmoji,
                          );
                        }
                        Navigator.pop(ctx);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Please fill all fields correctly!'),
                            backgroundColor: FoodieTheme.error,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Summary Card ─────────────────────────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  final PantryProvider pantry;

  const _SummaryCard({required this.pantry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E4D2B), Color(0xFF0D2B17)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: FoodieTheme.accent.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(color: FoodieTheme.accent.withOpacity(0.2), blurRadius: 16, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Pantry Value',
                  style: GoogleFonts.poppins(color: FoodieTheme.accent.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${pantry.totalValue.toStringAsFixed(2)}',
                  style: GoogleFonts.playfairDisplay(
                    color: FoodieTheme.textPrimary, fontSize: 28, fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${pantry.ingredients.length} ingredients in stock',
                  style: GoogleFonts.poppins(color: FoodieTheme.accent.withOpacity(0.7), fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(
              color: FoodieTheme.accent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: FoodieTheme.accent.withOpacity(0.3)),
            ),
            child: const Center(child: Text('💰', style: TextStyle(fontSize: 28))),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 200.ms).slideY(begin: 0.2);
  }
}

// ─── Ingredient Row ───────────────────────────────────────────────────────────
class _IngredientRow extends StatelessWidget {
  final Ingredient ingredient;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _IngredientRow({
    required this.ingredient,
    required this.index,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        gradient: FoodieTheme.cardGradient,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: FoodieTheme.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Emoji
            Container(
              width: 50, height: 50,
              decoration: BoxDecoration(
                color: FoodieTheme.bgDark,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(child: Text(ingredient.emoji, style: const TextStyle(fontSize: 26))),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ingredient.name,
                    style: GoogleFonts.poppins(
                      color: FoodieTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${ingredient.quantity} ${ingredient.unit} • ₹${ingredient.pricePerUnit}/${ingredient.unit}',
                    style: GoogleFonts.poppins(color: FoodieTheme.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),

            // Price badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E4D2B), Color(0xFF0D2B17)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: FoodieTheme.accent.withOpacity(0.3)),
                  ),
                  child: Text(
                    '₹${ingredient.totalPrice.toStringAsFixed(2)}',
                    style: GoogleFonts.poppins(
                      color: FoodieTheme.accent, fontSize: 12, fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    GestureDetector(
                      onTap: onEdit,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: FoodieTheme.secondary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.edit_rounded, color: FoodieTheme.secondary, size: 14),
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: onDelete,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: FoodieTheme.error.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.delete_outline_rounded, color: FoodieTheme.error, size: 14),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate(delay: (index * 60).ms).fadeIn(duration: 400.ms).slideX(begin: 0.1);
  }
}
