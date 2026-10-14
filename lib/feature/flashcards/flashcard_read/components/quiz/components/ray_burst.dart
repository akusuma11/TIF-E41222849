import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Small burst of rays that can be triggered from a controller.
class RayBurstController extends ChangeNotifier {
  void fire() => notifyListeners();
}

class RayBurst extends StatefulWidget {
  const RayBurst({
    super.key,
    required this.controller,
    required this.child,
    this.color = const Color(0xFF6B42B8),
    this.duration = const Duration(milliseconds: 380),
    this.rayCount = 10,
  });

  final RayBurstController controller;
  final Widget child;
  final Color color;
  final Duration duration;
  final int rayCount;

  @override
  State<RayBurst> createState() => _RayBurstState();
}

class _RayBurstState extends State<RayBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: widget.duration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _anim.reset();
        }
      });
    widget.controller.addListener(_onFire);
  }

  @override
  void didUpdateWidget(covariant RayBurst oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onFire);
      widget.controller.addListener(_onFire);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onFire);
    _anim.dispose();
    super.dispose();
  }

  void _onFire() {
    _anim.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            child!,
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _RayPainter(
                    progress: _anim.value,
                    color: widget.color,
                    rayCount: widget.rayCount,
                  ),
                ),
              ),
            ),
          ],
        );
      },
      child: widget.child,
    );
  }
}

class _RayPainter extends CustomPainter {
  _RayPainter({
    required this.progress,
    required this.color,
    required this.rayCount,
  });

  final double progress;
  final Color color;
  final int rayCount;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final maxLen = (math.min(size.width, size.height) / 2) + 32;
    final len = maxLen * progress;
    final strokeWidth = 3.0 * (1 - progress).clamp(0.3, 1.0);
    final paint = Paint()
      ..color = color.withOpacity(0.7 * (1 - progress))
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < rayCount; i++) {
      final angle = (2 * math.pi / rayCount) * i;
      final dx = math.cos(angle) * len;
      final dy = math.sin(angle) * len;
      canvas.drawLine(center, center.translate(dx, dy), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RayPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.rayCount != rayCount;
  }
}


class RayDraggableChip<T extends Object> extends StatefulWidget {
  const RayDraggableChip({
    required this.data,
    required this.child,
    required this.feedback,
    this.childWhenDragging,
    this.color = const Color(0xFF6B42B8),
  });

  final T data;
  final Widget child;
  final Widget feedback;
  final Widget? childWhenDragging;
  final Color color;

  @override
  State<RayDraggableChip<T>> createState() => _RayDraggableChipState<T>();
}

class _RayDraggableChipState<T extends Object>
    extends State<RayDraggableChip<T>> {
  @override
  Widget build(BuildContext context) {
    return Draggable<T>(
      data: widget.data,
      feedback: widget.feedback,
      childWhenDragging: widget.childWhenDragging,
      child: widget.child,
    );
  }
}
