import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/dish.dart';
import '../services/storage_service.dart';
import '../state/dish_provider.dart';
import '../theme/nothing_theme.dart';
import 'dish_detail_screen.dart';
import 'dish_edit_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void _showSettingsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _SettingsSheet(parentContext: context),
    );
  }

  void _navigateToCreateDish(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DishEditScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DishProvider>();

    return Scaffold(
      backgroundColor: NothingTheme.black,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                color: NothingTheme.red,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'COOKIE',
              style: GoogleFonts.spaceMono(
                letterSpacing: 2.0,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          // Settings button (Import / Export)
          IconButton(
            icon: const Icon(Icons.settings_outlined, size: 22),
            tooltip: 'Settings (Import / Export)',
            onPressed: () => _showSettingsMenu(context),
          ),
          // Add Dish button
          IconButton(
            icon: const Icon(Icons.add_rounded, size: 26),
            tooltip: 'Add Dish',
            onPressed: () => _navigateToCreateDish(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: provider.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: NothingTheme.white,
                strokeWidth: 2,
              ),
            )
          : provider.isEmpty
              ? _buildEmptyState(context)
              : _buildDishGrid(context, provider.dishes),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Minimalist wireframe empty card
            InkWell(
              onTap: () => _navigateToCreateDish(context),
              borderRadius: BorderRadius.circular(24),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
                decoration: BoxDecoration(
                  color: NothingTheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: NothingTheme.border,
                    width: 1.2,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: NothingTheme.white, width: 1.5),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: NothingTheme.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'ADD YOUR FIRST DISH',
                      style: GoogleFonts.spaceMono(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                        color: NothingTheme.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Record cooking steps, ingredients,\nflame levels, and timers.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: NothingTheme.grey,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDishGrid(BuildContext context, List<Dish> dishes) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 2 cards per row layout as requested
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 0.88, // Balanced aspect ratio for big title + estimated time
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final dish = dishes[index];
                return _DishCard(dish: dish);
              },
              childCount: dishes.length,
            ),
          ),
        ),
      ],
    );
  }
}

class _DishCard extends StatelessWidget {
  final Dish dish;

  const _DishCard({required this.dish});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DishDetailScreen(dishId: dish.id),
          ),
        );
      },
      borderRadius: BorderRadius.circular(22),
      child: Container(
        decoration: BoxDecoration(
          color: NothingTheme.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: NothingTheme.border,
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top section: Big Title
            Expanded(
              child: Text(
                dish.title.toUpperCase(),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.spaceMono(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                  letterSpacing: 0.5,
                  color: NothingTheme.white,
                ),
              ),
            ),

            // Bottom section: Estimated total time (no step counter badge as requested)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: NothingTheme.black,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: NothingTheme.border,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.schedule_rounded,
                    size: 13,
                    color: NothingTheme.grey,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      dish.totalEstimatedTimeFormatted,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.spaceMono(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: NothingTheme.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsSheet extends StatelessWidget {
  final BuildContext parentContext;

  const _SettingsSheet({required this.parentContext});

  Future<void> _handleExport(BuildContext context) async {
    Navigator.pop(context);
    final provider = parentContext.read<DishProvider>();
    final jsonStr = provider.exportJson();

    showDialog(
      context: parentContext,
      builder: (ctx) => AlertDialog(
        backgroundColor: NothingTheme.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: NothingTheme.border, width: 1),
        ),
        title: Text(
          'EXPORT RECIPES',
          style: GoogleFonts.spaceMono(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            color: NothingTheme.white,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Export ${provider.dishes.length} dishes as JSON format for backup or sharing.',
              style: GoogleFonts.inter(fontSize: 13, color: NothingTheme.grey),
            ),
            const SizedBox(height: 16),
            Container(
              height: 120,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: NothingTheme.black,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: NothingTheme.border),
              ),
              child: SingleChildScrollView(
                child: Text(
                  jsonStr,
                  style: GoogleFonts.spaceMono(
                    fontSize: 10,
                    color: const Color(0xFFCCCCCC),
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: jsonStr));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(parentContext).showSnackBar(
                const SnackBar(content: Text('JSON copied to clipboard')),
              );
            },
            child: Text(
              'COPY JSON',
              style: GoogleFonts.spaceMono(
                fontWeight: FontWeight.bold,
                color: NothingTheme.white,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: NothingTheme.white,
              foregroundColor: NothingTheme.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final file = await StorageService().createExportFile(jsonStr);
              if (file != null) {
                await SharePlus.instance.share(
                  ShareParams(
                    files: [XFile(file.path)],
                    subject: 'Cookie Recipe Backup (JSON)',
                  ),
                );
              } else {
                await SharePlus.instance.share(
                  ShareParams(
                    text: jsonStr,
                    subject: 'Cookie Recipes',
                  ),
                );
              }
            },
            child: Text(
              'SHARE FILE',
              style: GoogleFonts.spaceMono(
                fontWeight: FontWeight.bold,
                color: NothingTheme.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleImport(BuildContext context) async {
    Navigator.pop(context);

    showModalBottomSheet(
      context: parentContext,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _ImportOptionsSheet(parentContext: parentContext),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
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
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: NothingTheme.grey.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
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
                'SETTINGS & DATA',
                style: GoogleFonts.spaceMono(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: NothingTheme.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Option 1: Import JSON
          ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: NothingTheme.border),
            ),
            tileColor: NothingTheme.surfaceElevated,
            leading: const Icon(Icons.file_download_outlined, color: NothingTheme.white),
            title: Text(
              'IMPORT RECIPES',
              style: GoogleFonts.spaceMono(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: NothingTheme.white,
              ),
            ),
            subtitle: Text(
              'Import dishes from a JSON backup file or pasted text',
              style: GoogleFonts.inter(fontSize: 11, color: NothingTheme.grey),
            ),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: NothingTheme.grey),
            onTap: () => _handleImport(context),
          ),
          const SizedBox(height: 12),

          // Option 2: Export JSON
          ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: NothingTheme.border),
            ),
            tileColor: NothingTheme.surfaceElevated,
            leading: const Icon(Icons.file_upload_outlined, color: NothingTheme.white),
            title: Text(
              'EXPORT RECIPES',
              style: GoogleFonts.spaceMono(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: NothingTheme.white,
              ),
            ),
            subtitle: Text(
              'Save all dishes as a portable JSON file or copy to clipboard',
              style: GoogleFonts.inter(fontSize: 11, color: NothingTheme.grey),
            ),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: NothingTheme.grey),
            onTap: () => _handleExport(context),
          ),
        ],
      ),
    );
  }
}

class _ImportOptionsSheet extends StatefulWidget {
  final BuildContext parentContext;

  const _ImportOptionsSheet({required this.parentContext});

  @override
  State<_ImportOptionsSheet> createState() => _ImportOptionsSheetState();
}

class _ImportOptionsSheetState extends State<_ImportOptionsSheet> {
  final TextEditingController _textController = TextEditingController();
  bool _isPasteMode = false;

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json', 'txt'],
      );

      if (result != null && result.files.single.bytes != null) {
        final content = utf8.decode(result.files.single.bytes!);
        _processJson(content);
      } else if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final content = await file.readAsString();
        _processJson(content);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to read file: $e')),
      );
    }
  }

  void _processJson(String jsonString) {
    try {
      final dishes = StorageService().parseImportJson(jsonString);
      if (dishes.isEmpty) {
        throw const FormatException('No dishes found in JSON.');
      }

      widget.parentContext.read<DishProvider>().importDishes(dishes);
      Navigator.pop(context);
      ScaffoldMessenger.of(widget.parentContext).showSnackBar(
        SnackBar(
          content: Text('Imported ${dishes.length} dishes successfully!'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(widget.parentContext).showSnackBar(
        SnackBar(content: Text('Invalid JSON format: $e')),
      );
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.of(context).viewInsets.bottom + 24,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          Text(
            'IMPORT RECIPES (JSON)',
            style: GoogleFonts.spaceMono(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: NothingTheme.white,
            ),
          ),
          const SizedBox(height: 16),

          if (!_isPasteMode) ...[
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: NothingTheme.border),
              ),
              tileColor: NothingTheme.surfaceElevated,
              leading: const Icon(Icons.folder_open_rounded, color: NothingTheme.white),
              title: Text(
                'PICK .JSON FILE',
                style: GoogleFonts.spaceMono(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: NothingTheme.white,
                ),
              ),
              onTap: _pickFile,
            ),
            const SizedBox(height: 12),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: NothingTheme.border),
              ),
              tileColor: NothingTheme.surfaceElevated,
              leading: const Icon(Icons.paste_rounded, color: NothingTheme.white),
              title: Text(
                'PASTE JSON STRING',
                style: GoogleFonts.spaceMono(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: NothingTheme.white,
                ),
              ),
              onTap: () => setState(() => _isPasteMode = true),
            ),
          ] else ...[
            TextField(
              controller: _textController,
              maxLines: 6,
              style: GoogleFonts.spaceMono(fontSize: 11, color: NothingTheme.white),
              decoration: InputDecoration(
                hintText: 'Paste recipe JSON content here...',
                hintStyle: GoogleFonts.spaceMono(fontSize: 11, color: NothingTheme.grey),
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
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => setState(() => _isPasteMode = false),
                  child: Text(
                    'CANCEL',
                    style: GoogleFonts.spaceMono(
                      color: NothingTheme.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: NothingTheme.white,
                    foregroundColor: NothingTheme.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    final text = _textController.text.trim();
                    if (text.isNotEmpty) {
                      _processJson(text);
                    }
                  },
                  child: Text(
                    'IMPORT',
                    style: GoogleFonts.spaceMono(
                      fontWeight: FontWeight.bold,
                      color: NothingTheme.black,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
