import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/cooking_step.dart';
import '../models/dish.dart';
import '../models/ingredient.dart';
import '../state/dish_provider.dart';
import '../theme/nothing_theme.dart';
import '../widgets/flame_badge.dart';

class DishEditScreen extends StatefulWidget {
  final Dish? dish;

  const DishEditScreen({super.key, this.dish});

  @override
  State<DishEditScreen> createState() => _DishEditScreenState();
}

class _DishEditScreenState extends State<DishEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late List<CookingStep> _steps;
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.dish?.title ?? '');
    _steps = widget.dish != null
        ? widget.dish!.steps.map((s) => s.copyWith()).toList()
        : [];
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _saveDish() {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final provider = context.read<DishProvider>();

    // Re-index steps order
    for (int i = 0; i < _steps.length; i++) {
      _steps[i].order = i + 1;
    }

    if (widget.dish == null) {
      // Create new dish
      final newDish = Dish(
        id: _uuid.v4(),
        title: title,
        steps: _steps,
      );
      provider.addDish(newDish);
    } else {
      // Update existing dish
      final updated = widget.dish!.copyWith(
        title: title,
        steps: _steps,
      );
      provider.updateDish(updated);
    }

    Navigator.pop(context);
  }

  void _confirmDeleteDish() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: NothingTheme.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: NothingTheme.border),
        ),
        title: Text(
          'DELETE DISH?',
          style: GoogleFonts.spaceMono(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: NothingTheme.red,
          ),
        ),
        content: Text(
          'This will permanently remove "${widget.dish!.title}".',
          style: GoogleFonts.inter(fontSize: 13, color: NothingTheme.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'CANCEL',
              style: GoogleFonts.spaceMono(color: NothingTheme.grey),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: NothingTheme.red,
              foregroundColor: NothingTheme.white,
            ),
            onPressed: () {
              Navigator.pop(ctx); // Close dialog
              context.read<DishProvider>().deleteDish(widget.dish!.id);
              Navigator.pop(context); // Close edit screen
              Navigator.pop(context); // Close detail screen
            },
            child: Text(
              'DELETE',
              style: GoogleFonts.spaceMono(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openStepEditor({CookingStep? existingStep, int? index}) async {
    final result = await showModalBottomSheet<CookingStep>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _StepEditorSheet(
        initialStep: existingStep,
        stepOrder: (index != null ? index + 1 : _steps.length + 1),
      ),
    );

    if (result != null) {
      setState(() {
        if (index != null) {
          _steps[index] = result;
        } else {
          _steps.add(result);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.dish != null;

    return Scaffold(
      backgroundColor: NothingTheme.black,
      appBar: AppBar(
        title: Text(
          isEditing ? 'EDIT DISH' : 'NEW DISH',
          style: GoogleFonts.spaceMono(
            letterSpacing: 1.5,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded,
                  color: NothingTheme.red, size: 22),
              tooltip: 'Delete Dish',
              onPressed: _confirmDeleteDish,
            ),
          TextButton(
            onPressed: _saveDish,
            child: Text(
              'SAVE',
              style: GoogleFonts.spaceMono(
                fontWeight: FontWeight.w700,
                color: NothingTheme.white,
                letterSpacing: 1.0,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Dish Title Input
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: TextFormField(
                controller: _titleController,
                textCapitalization: TextCapitalization.words,
                style: GoogleFonts.spaceMono(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: NothingTheme.white,
                ),
                decoration: InputDecoration(
                  labelText: 'DISH TITLE',
                  labelStyle: GoogleFonts.spaceMono(
                    fontSize: 12,
                    color: NothingTheme.grey,
                    letterSpacing: 1.2,
                  ),
                  hintText: 'e.g. Masala Chai, Tadka Dal...',
                  hintStyle: GoogleFonts.spaceMono(
                    fontSize: 14,
                    color: NothingTheme.darkGrey,
                  ),
                  filled: true,
                  fillColor: NothingTheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: NothingTheme.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: NothingTheme.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(
                        color: NothingTheme.white, width: 1.2),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter a dish name';
                  }
                  return null;
                },
              ),
            ),

            // Steps Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
                        'STEPS (${_steps.length})',
                        style: GoogleFonts.spaceMono(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: NothingTheme.grey,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'DRAG TO REORDER',
                    style: GoogleFonts.spaceMono(
                      fontSize: 10,
                      color: NothingTheme.grey.withValues(alpha: 0.7),
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),

            // Reorderable Steps List
            Expanded(
              child: _steps.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.format_list_numbered_rounded,
                            size: 40,
                            color: NothingTheme.grey.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'NO STEPS ADDED YET',
                            style: GoogleFonts.spaceMono(
                              fontSize: 12,
                              color: NothingTheme.grey,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Theme(
                      data: Theme.of(context).copyWith(
                        canvasColor: Colors.transparent,
                      ),
                      child: ReorderableListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        itemCount: _steps.length,
                        onReorder: (oldIndex, newIndex) {
                          setState(() {
                            if (newIndex > oldIndex) newIndex--;
                            final item = _steps.removeAt(oldIndex);
                            _steps.insert(newIndex, item);
                          });
                        },
                        itemBuilder: (context, index) {
                          final step = _steps[index];
                          final stepNum =
                              (index + 1).toString().padLeft(2, '0');

                          return Container(
                            key: ValueKey(step.id),
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: NothingTheme.surface,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: NothingTheme.border,
                                width: 1,
                              ),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              leading: Text(
                                stepNum,
                                style: GoogleFonts.spaceMono(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: NothingTheme.white,
                                ),
                              ),
                              title: Row(
                                children: [
                                  FlameBadge(flame: step.flame),
                                  const SizedBox(width: 8),
                                  if (step.totalSeconds > 0)
                                    Text(
                                      step.formattedDuration,
                                      style: GoogleFonts.spaceMono(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: NothingTheme.grey,
                                      ),
                                    ),
                                ],
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      step.description,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        color: const Color(0xFFD1D1D6),
                                      ),
                                    ),
                                    if (step.ingredients.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        '${step.ingredients.length} ingredient(s)',
                                        style: GoogleFonts.spaceMono(
                                          fontSize: 10,
                                          color: NothingTheme.grey,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit_outlined,
                                      size: 18,
                                      color: NothingTheme.grey,
                                    ),
                                    onPressed: () => _openStepEditor(
                                      existingStep: step,
                                      index: index,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      size: 18,
                                      color: NothingTheme.red,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _steps.removeAt(index);
                                      });
                                    },
                                  ),
                                  ReorderableDragStartListener(
                                    index: index,
                                    child: const Padding(
                                      padding: EdgeInsets.only(left: 6),
                                      child: Icon(
                                        Icons.drag_indicator_rounded,
                                        color: NothingTheme.grey,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),

            // Bottom Add Step Button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: NothingTheme.surface,
                    foregroundColor: NothingTheme.white,
                    side: const BorderSide(
                        color: NothingTheme.border, width: 1.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () => _openStepEditor(),
                  icon: const Icon(Icons.add, size: 20),
                  label: Text(
                    'ADD STEP',
                    style: GoogleFonts.spaceMono(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepEditorSheet extends StatefulWidget {
  final CookingStep? initialStep;
  final int stepOrder;

  const _StepEditorSheet({
    this.initialStep,
    required this.stepOrder,
  });

  @override
  State<_StepEditorSheet> createState() => _StepEditorSheetState();
}

class _StepEditorSheetState extends State<_StepEditorSheet> {
  final _uuid = const Uuid();
  late TextEditingController _descController;
  late TextEditingController _minutesController;
  late TextEditingController _secondsController;
  late FlameLevel _flame;
  late List<Ingredient> _ingredients;

  @override
  void initState() {
    super.initState();
    final s = widget.initialStep;
    _descController = TextEditingController(text: s?.description ?? '');
    _minutesController =
        TextEditingController(text: (s?.durationMinutes ?? 0).toString());
    _secondsController =
        TextEditingController(text: (s?.durationSeconds ?? 0).toString());
    _flame = s?.flame ?? FlameLevel.medium;
    _ingredients =
        s != null ? s.ingredients.map((i) => i.copyWith()).toList() : [];
  }

  @override
  void dispose() {
    _descController.dispose();
    _minutesController.dispose();
    _secondsController.dispose();
    super.dispose();
  }

  void _addIngredientRow() {
    setState(() {
      _ingredients.add(
        Ingredient(id: _uuid.v4(), name: '', quantity: ''),
      );
    });
  }

  void _saveStep() {
    final desc = _descController.text.trim();
    if (desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter step description')),
      );
      return;
    }

    final mins = int.tryParse(_minutesController.text.trim()) ?? 0;
    final secs = int.tryParse(_secondsController.text.trim()) ?? 0;

    // Filter out empty ingredients
    final validIngredients = _ingredients
        .where((i) => i.name.trim().isNotEmpty)
        .toList();

    final step = CookingStep(
      id: widget.initialStep?.id ?? _uuid.v4(),
      order: widget.initialStep?.order ?? widget.stepOrder,
      description: desc,
      durationMinutes: mins.clamp(0, 599),
      durationSeconds: secs.clamp(0, 59),
      flame: _flame,
      ingredients: validIngredients,
    );

    Navigator.pop(context, step);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
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
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: NothingTheme.grey.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.initialStep == null
                      ? 'ADD STEP ${widget.stepOrder.toString().padLeft(2, '0')}'
                      : 'EDIT STEP ${widget.stepOrder.toString().padLeft(2, '0')}',
                  style: GoogleFonts.spaceMono(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: NothingTheme.white,
                  ),
                ),
                TextButton(
                  onPressed: _saveStep,
                  child: Text(
                    'DONE',
                    style: GoogleFonts.spaceMono(
                      fontWeight: FontWeight.bold,
                      color: NothingTheme.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Step Description
            Text(
              'DESCRIPTION',
              style: GoogleFonts.spaceMono(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: NothingTheme.grey,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _descController,
              maxLines: 3,
              style: GoogleFonts.inter(fontSize: 14, color: NothingTheme.white),
              decoration: InputDecoration(
                hintText:
                    'e.g. Heat oil, add mustard seeds until crackling...',
                hintStyle:
                    GoogleFonts.inter(fontSize: 13, color: NothingTheme.darkGrey),
                filled: true,
                fillColor: NothingTheme.black,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: NothingTheme.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: NothingTheme.white),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Flame Selection
            Text(
              'FLAME LEVEL',
              style: GoogleFonts.spaceMono(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: NothingTheme.grey,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: FlameLevel.values.map((f) {
                final isSelected = _flame == f;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: InkWell(
                      onTap: () => setState(() => _flame = f),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? NothingTheme.white
                              : NothingTheme.black,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? NothingTheme.white
                                : NothingTheme.border,
                            width: 1.2,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          f.label,
                          style: GoogleFonts.spaceMono(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                            color: isSelected
                                ? NothingTheme.black
                                : NothingTheme.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Time inputs (Minutes & Seconds)
            Text(
              'STEP DURATION',
              style: GoogleFonts.spaceMono(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: NothingTheme.grey,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minutesController,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.spaceMono(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: NothingTheme.white,
                    ),
                    decoration: InputDecoration(
                      labelText: 'MINUTES',
                      labelStyle: GoogleFonts.spaceMono(
                        fontSize: 10,
                        color: NothingTheme.grey,
                      ),
                      filled: true,
                      fillColor: NothingTheme.black,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide:
                            const BorderSide(color: NothingTheme.border),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _secondsController,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.spaceMono(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: NothingTheme.white,
                    ),
                    decoration: InputDecoration(
                      labelText: 'SECONDS',
                      labelStyle: GoogleFonts.spaceMono(
                        fontSize: 10,
                        color: NothingTheme.grey,
                      ),
                      filled: true,
                      fillColor: NothingTheme.black,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide:
                            const BorderSide(color: NothingTheme.border),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Ingredients for this step
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'INGREDIENTS FOR THIS STEP',
                  style: GoogleFonts.spaceMono(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: NothingTheme.grey,
                  ),
                ),
                TextButton.icon(
                  onPressed: _addIngredientRow,
                  icon: const Icon(Icons.add, size: 14),
                  label: Text(
                    'ADD',
                    style: GoogleFonts.spaceMono(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            if (_ingredients.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: NothingTheme.black,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: NothingTheme.border),
                ),
                child: Text(
                  'No ingredients added for this step yet.\nTap "+ ADD" to add spices or items to prep.',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: NothingTheme.grey,
                  ),
                ),
              )
            else
              ...List.generate(_ingredients.length, (i) {
                final ing = _ingredients[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      // Ingredient Name
                      Expanded(
                        flex: 5,
                        child: TextFormField(
                          initialValue: ing.name,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: NothingTheme.white,
                          ),
                          onChanged: (val) => ing.name = val,
                          decoration: InputDecoration(
                            hintText: 'Ingredient (e.g. Mustard)',
                            hintStyle: GoogleFonts.inter(
                              fontSize: 12,
                              color: NothingTheme.darkGrey,
                            ),
                            filled: true,
                            fillColor: NothingTheme.black,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  const BorderSide(color: NothingTheme.border),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Quantity (as text)
                      Expanded(
                        flex: 4,
                        child: TextFormField(
                          initialValue: ing.quantity,
                          style: GoogleFonts.spaceMono(
                            fontSize: 12,
                            color: NothingTheme.white,
                          ),
                          onChanged: (val) => ing.quantity = val,
                          decoration: InputDecoration(
                            hintText: 'Qty (e.g. 1 tsp)',
                            hintStyle: GoogleFonts.spaceMono(
                              fontSize: 11,
                              color: NothingTheme.darkGrey,
                            ),
                            filled: true,
                            fillColor: NothingTheme.black,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  const BorderSide(color: NothingTheme.border),
                            ),
                          ),
                        ),
                      ),
                      // Remove button
                      IconButton(
                        icon: const Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: NothingTheme.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _ingredients.removeAt(i);
                          });
                        },
                      ),
                    ],
                  ),
                );
              }),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
