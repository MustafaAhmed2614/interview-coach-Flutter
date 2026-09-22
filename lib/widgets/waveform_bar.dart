import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/constants.dart';

class WaveformBar extends StatefulWidget {
  final bool isActive;
  final double height;
  final Color color;

  const WaveformBar({
    super.key,
    required this.isActive,
    this.height = 60,
    this.color = AppColors.primary,
  });

  @override
  State<WaveformBar> createState() => _WaveformBarState();
}

class _WaveformBarState extends State<WaveformBar> {
  late Timer _timer;
  final List<double> _barHeights = List.filled(20, 0.2);
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  void _startAnimation() {
    _timer = Timer.periodic(const Duration(milliseconds: 80), (_) {
      if (!mounted) return;
      setState(() {
        for (int i = 0; i < _barHeights.length; i++) {
          if (widget.isActive) {
            _barHeights[i] = 0.1 + _random.nextDouble() * 0.9;
          } else {
            _barHeights[i] = 0.05 + _random.nextDouble() * 0.15;
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(_barHeights.length, (i) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 80),
            margin: const EdgeInsets.symmetric(horizontal: 2),
            width: 4,
            height: _barHeights[i] * widget.height,
            decoration: BoxDecoration(
              color: widget.isActive
                  ? widget.color.withOpacity(0.6 + _barHeights[i] * 0.4)
                  : AppColors.textMuted,
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }
}
