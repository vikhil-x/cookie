import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/sound_service.dart';
import '../theme/nothing_theme.dart';

class StepTimerWidget extends StatefulWidget {
  final int totalDurationSeconds;
  final String stepLabel;
  final bool compact;

  const StepTimerWidget({
    super.key,
    required this.totalDurationSeconds,
    this.stepLabel = '',
    this.compact = false,
  });

  @override
  State<StepTimerWidget> createState() => _StepTimerWidgetState();
}

class _StepTimerWidgetState extends State<StepTimerWidget>
    with SingleTickerProviderStateMixin {
  late int _remainingSeconds;
  Timer? _timer;
  bool _isRunning = false;
  bool _isFinished = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.totalDurationSeconds;

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(covariant StepTimerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.totalDurationSeconds != widget.totalDurationSeconds) {
      if (!_isRunning) {
        setState(() {
          _remainingSeconds = widget.totalDurationSeconds;
          _isFinished = false;
        });
      }
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
      _remainingSeconds = widget.totalDurationSeconds;
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
        // Timer complete
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
    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    _pulseController.stop();
    setState(() {
      _isRunning = false;
      _isFinished = false;
      _remainingSeconds = widget.totalDurationSeconds;
    });
  }

  String _formatTime(int sec) {
    final m = (sec ~/ 60).toString().padLeft(2, '0');
    final s = (sec % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.totalDurationSeconds <= 0) {
      return const SizedBox.shrink();
    }

    final progress = widget.totalDurationSeconds > 0
        ? (_remainingSeconds / widget.totalDurationSeconds).clamp(0.0, 1.0)
        : 0.0;

    if (widget.compact) {
      return _buildCompactTimer();
    }

    return ScaleTransition(
      scale: _isFinished ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: _isFinished
              ? NothingTheme.red.withValues(alpha: 0.15)
              : _isRunning
                  ? NothingTheme.surfaceElevated
                  : NothingTheme.black,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isFinished
                ? NothingTheme.red
                : _isRunning
                    ? NothingTheme.white.withValues(alpha: 0.3)
                    : NothingTheme.border,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Circular Progress Indicator
            SizedBox(
              width: 22,
              height: 22,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 2.2,
                    backgroundColor: NothingTheme.border,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _isFinished
                          ? NothingTheme.red
                          : _isRunning
                              ? NothingTheme.white
                              : NothingTheme.grey,
                    ),
                  ),
                  if (_isRunning)
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: NothingTheme.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Time Text
            Text(
              _formatTime(_remainingSeconds),
              style: GoogleFonts.spaceMono(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
                color: _isFinished
                    ? NothingTheme.red
                    : _isRunning
                        ? NothingTheme.white
                        : const Color(0xFFD1D1D6),
              ),
            ),
            const SizedBox(width: 10),
            // Play / Pause / Reset button
            if (_isFinished) ...[
              InkWell(
                onTap: _resetTimer,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: NothingTheme.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'RESET',
                    style: GoogleFonts.spaceMono(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: NothingTheme.white,
                    ),
                  ),
                ),
              ),
            ] else ...[
              IconButton(
                icon: Icon(
                  _isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  size: 20,
                  color: _isRunning ? NothingTheme.white : NothingTheme.white,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                splashRadius: 18,
                onPressed: _isRunning ? _pauseTimer : _startTimer,
                tooltip: _isRunning ? 'Pause Timer' : 'Start Timer',
              ),
              if (_isRunning ||
                  _remainingSeconds != widget.totalDurationSeconds) ...[
                IconButton(
                  icon: const Icon(
                    Icons.refresh_rounded,
                    size: 16,
                    color: NothingTheme.grey,
                  ),
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 24, minHeight: 24),
                  splashRadius: 16,
                  onPressed: _resetTimer,
                  tooltip: 'Reset',
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCompactTimer() {
    return InkWell(
      onTap: _isRunning ? _pauseTimer : _startTimer,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: _isFinished
              ? NothingTheme.red.withValues(alpha: 0.2)
              : _isRunning
                  ? NothingTheme.surfaceElevated
                  : NothingTheme.black,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _isFinished ? NothingTheme.red : NothingTheme.border,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _isFinished
                  ? Icons.notifications_active_rounded
                  : _isRunning
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
              size: 16,
              color: _isFinished
                  ? NothingTheme.red
                  : _isRunning
                      ? NothingTheme.white
                      : NothingTheme.grey,
            ),
            const SizedBox(width: 6),
            Text(
              _formatTime(_remainingSeconds),
              style: GoogleFonts.spaceMono(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _isFinished ? NothingTheme.red : NothingTheme.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
