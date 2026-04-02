import 'dart:async';
import 'package:flutter/material.dart';

/// Widget that displays a live timer since the order was created
class KitchenTimer extends StatefulWidget {
  final DateTime createdAt;
  final bool isOverdue;

  const KitchenTimer({
    super.key,
    required this.createdAt,
    this.isOverdue = false,
  });

  @override
  State<KitchenTimer> createState() => _KitchenTimerState();
}

class _KitchenTimerState extends State<KitchenTimer> {
  late Timer _timer;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateElapsed();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateElapsed();
    });
  }

  void _updateElapsed() {
    setState(() {
      _elapsed = DateTime.now().difference(widget.createdAt);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = _elapsed.inMinutes;
    final seconds = _elapsed.inSeconds % 60;
    
    final isUrgent = minutes > 10;
    final isWarning = minutes > 5;

    Color timerColor;
    if (isUrgent) {
      timerColor = Colors.red;
    } else if (isWarning) {
      timerColor = Colors.orange;
    } else {
      timerColor = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: timerColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: timerColor, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer,
            color: timerColor,
            size: 20,
          ),
          const SizedBox(width: 6),
          Text(
            '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: timerColor,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}