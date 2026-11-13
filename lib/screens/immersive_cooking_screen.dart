import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/cooking_step.dart';
import '../services/sound_service.dart';
import '../state/dish_provider.dart';
import '../theme/nothing_theme.dart';
import '../widgets/flame_badge.dart';

class ImmersiveCookingScreen extends StatefulWidget {
  final String dishId;

  const ImmersiveCookingScreen({super.key, required this.dishId});

  @override
  State<ImmersiveCookingScreen> createState() => _ImmersiveCookingScreenState();
}

class _ImmersiveCookingScreenState extends State<ImmersiveCookingScreen> {
  late PageController _pageController;
  int _currentPage = 0;
  bool _isLandscapeForced = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // Allow all orientations for immersive mode
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    _pageController.dispose();
    // Reset orientation preferences when exiting immersive mode
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  void _toggleForcedLandscape() {
    setState(() {
      _isLandscapeForced = !_isLandscapeForced;
      if (_isLandscapeForced) {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      } else {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final dish = context.watch<DishProvider>().getDish(widget.dishId);

    if (dish == null || dish.steps.isEmpty) {
      return Scaffold(
        backgroundColor: NothingTheme.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'NO STEPS TO DISPLAY',
                style: GoogleFonts.spaceMono(color: NothingTheme.grey),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('EXIT', style: GoogleFonts.spaceMono(color: NothingTheme.white)),
              ),
            ],
          ),
        ),
      );
    }

    final totalSteps = dish.steps.length;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: NothingTheme.black,
      body: SafeArea(
        child: Column(
          children: [
            // Immersive Top Bar: Minimalist with Step Index, Orientation toggle, and Exit
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  // Red active indicator + dish title
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: NothingTheme.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      dish.title.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.spaceMono(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: NothingTheme.white,
                      ),
                    ),
                  ),

                  // Step counter (e.g. 02 / 06)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: NothingTheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: NothingTheme.border),
                    ),
                    child: Text(
                      '${(_currentPage + 1).toString().padLeft(2, '0')} / ${totalSteps.toString().padLeft(2, '0')}',
                      style: GoogleFonts.spaceMono(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: NothingTheme.white,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Rotate / Landscape toggle button
                  IconButton(
                    icon: Icon(
                      _isLandscapeForced ? Icons.screen_rotation_rounded : Icons.screen_lock_rotation_rounded,
                      size: 20,
                      color: _isLandscapeForced ? NothingTheme.red : NothingTheme.white,
                    ),
                    tooltip: 'Lock Landscape',
                    onPressed: _toggleForcedLandscape,
                  ),

                  // Exit button
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 24, color: NothingTheme.white),
                    tooltip: 'Exit Immersive Mode',
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Main Card-by-Card View
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: totalSteps,
                onPageChanged: (page) => setState(() => _currentPage = page),
                itemBuilder: (context, index) {
                  final step = dish.steps[index];
                  return _ImmersiveStepCard(
                    step: step,
                    stepNumber: index + 1,
                    totalSteps: totalSteps,
                    isLandscape: isLandscape,
                  );
                },
              ),
            ),

            // Bottom Navigation Controls
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Previous button
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: _currentPage > 0 ? NothingTheme.white : NothingTheme.darkGrey,
                    ),
                    onPressed: _currentPage > 0
                        ? () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        : null,
                    icon: const Icon(Icons.arrow_back_rounded, size: 18),
                    label: Text(
                      'PREV',
                      style: GoogleFonts.spaceMono(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),

                  // Step indicator dots
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      totalSteps,
                      (i) => Container(
                        width: i == _currentPage ? 18 : 6,
                        height: 6,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          color: i == _currentPage ? NothingTheme.white : NothingTheme.darkGrey,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),

                  // Next / Finish button
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: NothingTheme.white,
                    ),
                    onPressed: _currentPage < totalSteps - 1
                        ? () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        : () => Navigator.pop(context),
                    label: Text(
                      _currentPage < totalSteps - 1 ? 'NEXT' : 'FINISH',
                      style: GoogleFonts.spaceMono(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                        color: _currentPage == totalSteps - 1 ? NothingTheme.red : NothingTheme.white,
                      ),
                    ),
                    icon: Icon(
                      _currentPage < totalSteps - 1 ? Icons.arrow_forward_rounded : Icons.check_circle_outline,
                      size: 18,
                      color: _currentPage == totalSteps - 1 ? NothingTheme.red : NothingTheme.white,
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

class _ImmersiveStepCard extends StatefulWidget {
  final CookingStep step;
  final int stepNumber;
  final int totalSteps;
  final bool isLandscape;

  const _ImmersiveStepCard({
    required this.step,
    required this.stepNumber,
    required this.totalSteps,
    required this.isLandscape,
  });

  @override
  State<_ImmersiveStepCard> createState() => _ImmersiveStepCardState();
}

class _ImmersiveStepCardState extends State<_ImmersiveStepCard>
    with SingleTickerProviderStateMixin {
  late int _remainingSeconds;
  Timer? _timer;
  bool _isRunning = false;
  bool _isFinished = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseScale;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.step.totalSeconds;

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _pulseScale = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(covariant _ImmersiveStepCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.step.id != widget.step.id) {
      _timer?.cancel();
      _pulseController.stop();
      setState(() {
        _remainingSeconds = widget.step.totalSeconds;
        _isRunning = false;
        _isFinished = false;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (_remainingSeconds <= 0) {
      _remainingSeconds = widget.step.totalSeconds;
      _isFinished = false;
    }

    _timer?.cancel();
    setState(() {
      _isRunning = true;
      _isFinished = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 1) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        timer.cancel();
        setState(() {
          _remainingSeconds = 0;
          _isRunning = false;
          _isFinished = true;
        });
        _pulseController.repeat(reverse: true);
        SoundService().playChime();
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _resetTimer() {
    _timer?.cancel();
    _pulseController.stop();
    setState(() {
      _remainingSeconds = widget.step.totalSeconds;
      _isRunning = false;
      _isFinished = false;
    });
  }

  String _formatTime(int sec) {
    final m = (sec ~/ 60).toString().padLeft(2, '0');
    final s = (sec % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final stepNum = widget.stepNumber.toString().padLeft(2, '0');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: NothingTheme.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: _isFinished ? NothingTheme.red : NothingTheme.border,
            width: 1.4,
          ),
        ),
        child: widget.isLandscape
            ? _buildLandscapeLayout(stepNum)
            : _buildPortraitLayout(stepNum),
      ),
    );
  }

  // Portrait layout
  Widget _buildPortraitLayout(String stepNum) {
    return Padding(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step Header & Flame
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'STEP $stepNum',
                style: GoogleFonts.spaceMono(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.0,
                  color: NothingTheme.white,
                ),
              ),
              FlameBadge(flame: widget.step.flame, showFull: true),
            ],
          ),

          const SizedBox(height: 16),

          // Main Step Description (large, kitchen counter readable)
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.step.description,
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: NothingTheme.white,
                      height: 1.5,
                      letterSpacing: 0.2,
                    ),
                  ),

                  // Highlighted Thin Box for Ingredients
                  if (widget.step.ingredients.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _buildIngredientsBox(),
                  ],
                ],
              ),
            ),
          ),

          // Large Timer Section
          if (widget.step.totalSeconds > 0) ...[
            const SizedBox(height: 12),
            _buildLargeTimerSection(),
          ],
        ],
      ),
    );
  }

  // Landscape layout (horizontal kitchen counter mode)
  Widget _buildLandscapeLayout(String stepNum) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Column: Step details & description
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'STEP $stepNum',
                      style: GoogleFonts.spaceMono(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                        color: NothingTheme.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    FlameBadge(flame: widget.step.flame, showFull: true),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.step.description,
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: NothingTheme.white,
                            height: 1.45,
                          ),
                        ),
                        if (widget.step.ingredients.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          _buildIngredientsBox(),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),
          const VerticalDivider(color: NothingTheme.border, width: 1),
          const SizedBox(width: 16),

          // Right Column: Big prominent timer controls
          Expanded(
            flex: 4,
            child: Center(
              child: widget.step.totalSeconds > 0
                  ? _buildLargeTimerSection()
                  : Text(
                      'NO TIMER FOR THIS STEP',
                      style: GoogleFonts.spaceMono(
                        fontSize: 12,
                        color: NothingTheme.grey,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                  color: NothingTheme.red,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'PREPARE FOR THIS STEP',
                style: GoogleFonts.spaceMono(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: NothingTheme.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.step.ingredients.map((ing) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: NothingTheme.black,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: NothingTheme.border),
                ),
                child: Text(
                  '${ing.name}${ing.quantity.isNotEmpty ? '  •  ${ing.quantity}' : ''}',
                  style: GoogleFonts.spaceMono(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: NothingTheme.white,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLargeTimerSection() {
    final progress = widget.step.totalSeconds > 0
        ? (_remainingSeconds / widget.step.totalSeconds).clamp(0.0, 1.0)
        : 0.0;

    return ScaleTransition(
      scale: _isFinished ? _pulseScale : const AlwaysStoppedAnimation(1.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _isFinished
              ? NothingTheme.red.withValues(alpha: 0.15)
              : NothingTheme.black,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: _isFinished ? NothingTheme.red : NothingTheme.border,
            width: 1.2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Linear Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 4,
                backgroundColor: NothingTheme.border,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _isFinished ? NothingTheme.red : NothingTheme.white,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Giant Countdown numbers
            Text(
              _formatTime(_remainingSeconds),
              style: GoogleFonts.spaceMono(
                fontSize: 38,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.0,
                color: _isFinished ? NothingTheme.red : NothingTheme.white,
              ),
            ),
            const SizedBox(height: 10),

            // Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isFinished) ...[
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: NothingTheme.red,
                      foregroundColor: NothingTheme.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    ),
                    onPressed: _resetTimer,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: Text(
                      'STEP COMPLETE - RESET',
                      style: GoogleFonts.spaceMono(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ] else ...[
                  // Play/Pause button
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: NothingTheme.white,
                      foregroundColor: NothingTheme.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    onPressed: _isRunning ? _pauseTimer : _startTimer,
                    icon: Icon(
                      _isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      size: 20,
                    ),
                    label: Text(
                      _isRunning ? 'PAUSE' : 'START TIMER',
                      style: GoogleFonts.spaceMono(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  if (_isRunning || _remainingSeconds != widget.step.totalSeconds) ...[
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded, color: NothingTheme.grey),
                      tooltip: 'Reset',
                      onPressed: _resetTimer,
                    ),
                  ],
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
