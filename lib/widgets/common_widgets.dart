import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';

// ─── Gradient Background ────────────────────────────────────────────────────
class FoodieBackground extends StatelessWidget {
  final Widget child;
  const FoodieBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: FoodieTheme.bgGradient),
      child: child,
    );
  }
}

// ─── Foodie Card ────────────────────────────────────────────────────────────
class FoodieCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final bool highlight;
  final Color? borderColor;

  const FoodieCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.highlight = false,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2D1506), Color(0xFF3D2010)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: borderColor ?? (highlight ? FoodieTheme.primary : FoodieTheme.divider),
            width: highlight ? 2 : 1,
          ),
          boxShadow: highlight ? [
            BoxShadow(
              color: FoodieTheme.primary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ] : [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
}

// ─── Section Header ─────────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineMedium),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(subtitle!, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

// ─── Ingredient Chip ─────────────────────────────────────────────────────────
class IngredientChip extends StatelessWidget {
  final String label;
  final VoidCallback? onDelete;
  final bool deletable;

  const IngredientChip({
    super.key,
    required this.label,
    this.onDelete,
    this.deletable = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            FoodieTheme.primary.withOpacity(0.2),
            FoodieTheme.accentPink.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: FoodieTheme.primary.withOpacity(0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                color: FoodieTheme.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (deletable && onDelete != null) ...[
              const SizedBox(width: 6),
              GestureDetector(
                onTap: onDelete,
                child: const Icon(Icons.close_rounded, size: 16, color: FoodieTheme.primary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Meal Card ───────────────────────────────────────────────────────────────
// ─── Meal Card ───────────────────────────────────────────────────────────────
class MealSuggestionCard extends StatelessWidget {
  final SuggestedMeal meal;
  final VoidCallback onTap;
  final int index;

  const MealSuggestionCard({
    super.key,
    required this.meal,
    required this.onTap,
    required this.index,
  });

  Color get _difficultyColor {
    switch (meal.difficulty) {
      case 'Easy': return FoodieTheme.accent;
      case 'Medium': return FoodieTheme.warning;
      case 'Hard': return FoodieTheme.error;
      default: return FoodieTheme.accent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2D1506), Color(0xFF3D2010)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: FoodieTheme.divider),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            children: [
              // Top gradient header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      FoodieTheme.primary.withOpacity(0.15),
                      Colors.transparent,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: FoodieTheme.bgCardLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: FoodieTheme.divider),
                      ),
                      child: Center(
                        child: Text(meal.emoji, style: const TextStyle(fontSize: 30)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            meal.name,
                            style: GoogleFonts.playfairDisplay(
                              color: FoodieTheme.textPrimary,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            meal.description,
                            style: GoogleFonts.poppins(
                              color: FoodieTheme.textSecondary,
                              fontSize: 12,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: FoodieTheme.primary,
                      size: 16,
                    ),
                  ],
                ),
              ),

              // Stats row — wrapped to prevent overflow
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _StatBadge(
                      icon: Icons.timer_outlined,
                      label: meal.cookTime,
                      color: FoodieTheme.secondary,
                    ),
                    _StatBadge(
                      icon: Icons.local_fire_department_outlined,
                      label: '${meal.calories} cal',
                      color: FoodieTheme.accentPink,
                    ),
                    _DifficultyBadge(
                      label: meal.difficulty,
                      color: _difficultyColor,
                    ),
                    _CuisineBadge(label: meal.cuisine),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate(delay: (index * 100).ms).fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0);
  }
}

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatBadge({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.poppins(color: color, fontSize: 11, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _DifficultyBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _DifficultyBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _CuisineBadge extends StatelessWidget {
  final String label;

  const _CuisineBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: FoodieTheme.accentPurple.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          color: FoodieTheme.accentPurple, fontSize: 11, fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}


// ─── Loading Shimmer ─────────────────────────────────────────────────────────
class FoodieShimmerCard extends StatelessWidget {
  const FoodieShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: FoodieTheme.bgCard,
        borderRadius: BorderRadius.circular(20),
      ),
    ).animate(onPlay: (c) => c.repeat()).shimmer(
      color: FoodieTheme.bgCardLight,
      duration: 1200.ms,
    );
  }
}

// ─── Empty State ─────────────────────────────────────────────────────────────
class EmptyState extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.emoji,
    required this.title,
    required this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.playfairDisplay(
              color: FoodieTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: GoogleFonts.poppins(color: FoodieTheme.textSecondary, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          if (action != null) ...[
            const SizedBox(height: 24),
            action!,
          ],
        ],
      ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.9, 0.9)),
    );
  }
}

// ─── Primary Button ──────────────────────────────────────────────────────────
class FoodieButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool loading;
  final Color? color;

  const FoodieButton({
    super.key,
    required this.label,
    this.onTap,
    this.icon,
    this.loading = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: color != null
                ? [color!, color!.withOpacity(0.8)]
                : [FoodieTheme.primary, const Color(0xFFFF9A5C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: (color ?? FoodieTheme.primary).withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: loading
              ? const SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      label,
                      style: GoogleFonts.poppins(
                        color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
