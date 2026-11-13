import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../state/dish_provider.dart';
import '../theme/nothing_theme.dart';
import '../widgets/prep_ingredients_sheet.dart';
import '../widgets/step_card.dart';
import 'dish_edit_screen.dart';
import 'immersive_cooking_screen.dart';

class DishDetailScreen extends StatelessWidget {
  final String dishId;

  const DishDetailScreen({super.key, required this.dishId});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DishProvider>();
    final dish = provider.getDish(dishId);

    if (dish == null) {
      return Scaffold(
        backgroundColor: NothingTheme.black,
        appBar: AppBar(),
        body: Center(
          child: Text(
            'DISH NOT FOUND',
            style: GoogleFonts.spaceMono(
              color: NothingTheme.grey,
              letterSpacing: 1.2,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: NothingTheme.black,
      appBar: AppBar(
        title: Text(
          dish.title.toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.spaceMono(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
        ),
        actions: [
          // 1. Ingredients Prep Button (Sheet with list/card toggle)
          IconButton(
            icon: const Icon(Icons.egg_alt_outlined, size: 22),
            tooltip: 'Ingredients Prep',
            onPressed: () => PrepIngredientsSheet.show(context, dish),
          ),

          // 2. Immersive Fullscreen Mode Button
          IconButton(
            icon: const Icon(Icons.fullscreen_rounded, size: 26),
            tooltip: 'Immersive Cooking Mode',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ImmersiveCookingScreen(dishId: dish.id),
                ),
              );
            },
          ),

          // 3. Edit Option
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 22),
            tooltip: 'Edit Dish & Steps',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DishEditScreen(dish: dish),
                ),
              );
            },
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Overview Header info
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  color: NothingTheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: NothingTheme.border, width: 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: NothingTheme.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'TOTAL ESTIMATED TIME',
                          style: GoogleFonts.spaceMono(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                            color: NothingTheme.grey,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      dish.totalEstimatedTimeFormatted,
                      style: GoogleFonts.spaceMono(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: NothingTheme.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Step List
          if (dish.steps.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'NO STEPS ADDED YET',
                      style: GoogleFonts.spaceMono(
                        fontSize: 14,
                        letterSpacing: 1.2,
                        color: NothingTheme.grey,
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: NothingTheme.white,
                        side: const BorderSide(color: NothingTheme.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DishEditScreen(dish: dish),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add, size: 18),
                      label: Text(
                        'ADD STEPS',
                        style: GoogleFonts.spaceMono(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final step = dish.steps[index];
                    return StepCard(
                      step: step,
                      index: index,
                    );
                  },
                  childCount: dish.steps.length,
                ),
              ),
            ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 40),
          ),
        ],
      ),
    );
  }
}
