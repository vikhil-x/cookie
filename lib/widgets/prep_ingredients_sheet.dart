import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/dish.dart';
import '../theme/nothing_theme.dart';

class PrepIngredientsSheet extends StatefulWidget {
  final Dish dish;

  const PrepIngredientsSheet({super.key, required this.dish});

  static void show(BuildContext context, Dish dish) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PrepIngredientsSheet(dish: dish),
    );
  }

  @override
  State<PrepIngredientsSheet> createState() => _PrepIngredientsSheetState();
}

class _PrepIngredientsSheetState extends State<PrepIngredientsSheet> {
  bool _isCardView = false;
  final Set<String> _checkedItemIds = {};

  List<({String id, String name, String quantity, String stepInfo})>
      get _allIngredients {
    final list = <({String id, String name, String quantity, String stepInfo})>[];
    for (int i = 0; i < widget.dish.steps.length; i++) {
      final step = widget.dish.steps[i];
      final stepNum = (i + 1).toString().padLeft(2, '0');
      for (final ing in step.ingredients) {
        if (ing.name.trim().isNotEmpty) {
          list.add((
            id: '${step.id}_${ing.id}',
            name: ing.name.trim(),
            quantity: ing.quantity.trim(),
            stepInfo: 'STEP $stepNum',
          ));
        }
      }
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final ingredients = _allIngredients;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.82,
      ),
      decoration: const BoxDecoration(
        color: NothingTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: NothingTheme.border, width: 1.2),
          left: BorderSide(color: NothingTheme.border, width: 1.2),
          right: BorderSide(color: NothingTheme.border, width: 1.2),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                color: NothingTheme.grey.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                            'INGREDIENTS PREP',
                            style: GoogleFonts.spaceMono(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                              color: NothingTheme.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${ingredients.length} items to prepare beforehand',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: NothingTheme.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                // View Toggle (List / Cards)
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: NothingTheme.black,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: NothingTheme.border, width: 1),
                  ),
                  child: Row(
                    children: [
                      _buildToggleButton(
                        icon: Icons.format_list_bulleted_rounded,
                        label: 'LIST',
                        isSelected: !_isCardView,
                        onTap: () => setState(() => _isCardView = false),
                      ),
                      _buildToggleButton(
                        icon: Icons.grid_view_rounded,
                        label: 'CARDS',
                        isSelected: _isCardView,
                        onTap: () => setState(() => _isCardView = true),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(color: NothingTheme.border, height: 1),

          // Content
          Expanded(
            child: ingredients.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        'NO INGREDIENTS LISTED YET\nAdd ingredients to steps when editing.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.spaceMono(
                          fontSize: 12,
                          color: NothingTheme.grey,
                          height: 1.5,
                        ),
                      ),
                    ),
                  )
                : _isCardView
                    ? _buildCardGrid(ingredients)
                    : _buildListView(ingredients),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? NothingTheme.white : Colors.transparent,
          borderRadius: BorderRadius.circular(13),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? NothingTheme.black : NothingTheme.grey,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.spaceMono(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: isSelected ? NothingTheme.black : NothingTheme.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView(
      List<({String id, String name, String quantity, String stepInfo})>
          ingredients) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: ingredients.length,
      separatorBuilder: (_, __) =>
          const Divider(color: Color(0x1AFFFFFF), height: 1),
      itemBuilder: (context, index) {
        final item = ingredients[index];
        final isChecked = _checkedItemIds.contains(item.id);

        return InkWell(
          onTap: () {
            setState(() {
              if (isChecked) {
                _checkedItemIds.remove(item.id);
              } else {
                _checkedItemIds.add(item.id);
              }
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                // Custom Nothing Checkbox
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: isChecked ? NothingTheme.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isChecked ? NothingTheme.white : NothingTheme.border,
                      width: 1.4,
                    ),
                  ),
                  child: isChecked
                      ? const Icon(
                          Icons.check_rounded,
                          size: 16,
                          color: NothingTheme.black,
                        )
                      : null,
                ),
                const SizedBox(width: 14),
                // Ingredient Name
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: isChecked ? NothingTheme.grey : NothingTheme.white,
                          decoration: isChecked
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.stepInfo,
                        style: GoogleFonts.spaceMono(
                          fontSize: 10,
                          color: NothingTheme.grey,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
                // Quantity text
                if (item.quantity.isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: NothingTheme.black,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: NothingTheme.border,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      item.quantity,
                      style: GoogleFonts.spaceMono(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isChecked ? NothingTheme.grey : NothingTheme.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCardGrid(
      List<({String id, String name, String quantity, String stepInfo})>
          ingredients) {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.4,
      ),
      itemCount: ingredients.length,
      itemBuilder: (context, index) {
        final item = ingredients[index];
        final isChecked = _checkedItemIds.contains(item.id);

        return GestureDetector(
          onTap: () {
            setState(() {
              if (isChecked) {
                _checkedItemIds.remove(item.id);
              } else {
                _checkedItemIds.add(item.id);
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isChecked
                  ? NothingTheme.black.withValues(alpha: 0.5)
                  : NothingTheme.surfaceElevated,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isChecked
                    ? NothingTheme.grey.withValues(alpha: 0.3)
                    : NothingTheme.border,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.stepInfo,
                      style: GoogleFonts.spaceMono(
                        fontSize: 9,
                        color: NothingTheme.grey,
                        letterSpacing: 0.8,
                      ),
                    ),
                    Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: isChecked ? NothingTheme.white : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isChecked
                              ? NothingTheme.white
                              : NothingTheme.border,
                          width: 1.2,
                        ),
                      ),
                      child: isChecked
                          ? const Icon(
                              Icons.check,
                              size: 12,
                              color: NothingTheme.black,
                            )
                          : null,
                    ),
                  ],
                ),
                Text(
                  item.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isChecked ? NothingTheme.grey : NothingTheme.white,
                    decoration: isChecked
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
                Text(
                  item.quantity.isNotEmpty ? item.quantity : 'As needed',
                  style: GoogleFonts.spaceMono(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isChecked ? NothingTheme.grey : const Color(0xFFD1D1D6),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
