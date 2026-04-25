import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'theme/app_theme.dart';
import 'providers/cook_now_provider.dart';
import 'providers/meal_planner_provider.dart';
import 'providers/pantry_provider.dart';
import 'screens/cook_now_screen.dart';
import 'screens/meal_planner_screen.dart';
import 'screens/pantry_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const FoodieApp());
}

class FoodieApp extends StatelessWidget {
  const FoodieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CookNowProvider()),
        ChangeNotifierProvider(create: (_) => MealPlannerProvider()),
        ChangeNotifierProvider(create: (_) => PantryProvider()),
      ],
      child: MaterialApp(
        title: 'Foodie',
        debugShowCheckedModeBanner: false,
        theme: FoodieTheme.theme,
        home: const MainNavigation(),
      ),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late final PageController _pageController;

  final _screens = const [
    CookNowScreen(),
    MealPlannerScreen(),
    PantryScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _screens,
      ),
      bottomNavigationBar: _FoodieNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}

class _FoodieNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _FoodieNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavItem(emoji: '🍳', label: 'Cook Now', index: 0),
      _NavItem(emoji: '📅', label: 'Meal Plan', index: 1),
      _NavItem(emoji: '🛒', label: 'Pantry', index: 2),
    ];

    return Container(
      decoration: BoxDecoration(
        color: FoodieTheme.bgCard,
        border: const Border(top: BorderSide(color: FoodieTheme.divider, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.map((item) {
              final isSelected = currentIndex == item.index;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(item.index),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: 200.ms,
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? const LinearGradient(
                        colors: [FoodieTheme.primary, Color(0xFFFF9A5C)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                          : null,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedScale(
                          scale: isSelected ? 1.2 : 1.0,
                          duration: 200.ms,
                          child: Text(item.emoji, style: const TextStyle(fontSize: 22)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.label,
                          style: GoogleFonts.poppins(
                            color: isSelected ? Colors.white : FoodieTheme.textMuted,
                            fontSize: 10,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final String emoji;
  final String label;
  final int index;
  const _NavItem({required this.emoji, required this.label, required this.index});
}
