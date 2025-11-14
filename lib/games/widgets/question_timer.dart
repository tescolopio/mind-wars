/**
 * Question Timer Widget
 * Visual countdown timer for vocabulary questions
 */

import 'package:flutter/material.dart';
import 'dart:async';

class QuestionTimer extends StatefulWidget {
  final double maxTime; // in seconds
  final VoidCallback onTimeUp;
  final bool isPaused;

  const QuestionTimer({
    Key? key,
    required this.maxTime,
    required this.onTimeUp,
    this.isPaused = false,
  }) : super(key: key);

  @override
  State<QuestionTimer> createState() => _QuestionTimerState();
}

class _QuestionTimerState extends State<QuestionTimer> {
  late double _remainingTime;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remainingTime = widget.maxTime;
    _startTimer();
  }

  @override
  void didUpdateWidget(QuestionTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPaused != oldWidget.isPaused) {
      if (widget.isPaused) {
        _stopTimer();
      } else {
        _startTimer();
      }
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (mounted && !widget.isPaused) {
        setState(() {
          _remainingTime -= 0.1;
          if (_remainingTime <= 0) {
            _remainingTime = 0;
            _stopTimer();
            widget.onTimeUp();
          }
        });
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }

  Color _getTimerColor() {
    final percentage = _remainingTime / widget.maxTime;
    if (percentage > 0.5) {
      return Colors.green;
    } else if (percentage > 0.25) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final percentage = _remainingTime / widget.maxTime;
    final color = _getTimerColor();

    return Column(
      children: [
        Row(
          children: [
            Icon(Icons.timer, size: 20, color: color),
            const SizedBox(width: 8),
            Text(
              '${_remainingTime.toStringAsFixed(1)}s',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const Spacer(),
            Text(
              '${(percentage * 100).toInt()}%',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}
