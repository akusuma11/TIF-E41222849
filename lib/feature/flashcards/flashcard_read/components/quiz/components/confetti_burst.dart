import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Lightweight, reusable confetti burst that fires upward from the bottom
/// center. Trigger via [ConfettiBurstController.fire()].
class ConfettiBurstController extends ChangeNotifier {
  void fire() => notifyListeners();
}

class ConfettiBurst extends StatefulWidget {
  const ConfettiBurst({
    super.key,
    required this.controller,
    required this.child,
    this.colors = const [
      Color(0xFF6B42B8),
      Color(0xFF2ECC71),
      Color(0xFFF39C12),
      Color(0xFFE74C3C),
      Color(0xFF3498DB),
    ],
    this.particleCount = 140,
    this.duration = const Duration(milliseconds: 1600),
  });

  final ConfettiBurstController controller;
  final Widget child;
  final List<Color> colors;
  final int particleCount;
  final Duration duration;

  @override
  State<ConfettiBurst> createState() => _ConfettiBurstState();
}

class _ConfettiBurstState extends State<ConfettiBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  final List<_ConfettiParticle> _particles = [];
  final math.Random _rand = math.Random();

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
  void didUpdateWidget(covariant ConfettiBurst oldWidget) {
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
    _particles
      ..clear()
      ..addAll(List.generate(widget.particleCount, (_) => _spawnParticle()));
    _anim.forward(from: 0);
  }

  _ConfettiParticle _spawnParticle() {
    final fan = 1.7; // wider spread for big burst
    final angle = -math.pi / 2 + (_rand.nextDouble() * fan * 2 - fan);
    final speed =
        _rand.nextDouble() * 900 + 1100; // px/s equivalent for higher throw
    final size = _rand.nextDouble() * 7 + 7;
    final sway = _rand.nextDouble() * math.pi * 2;
    final spin = _rand.nextDouble() * math.pi * 2.2;
    final color = widget.colors[_rand.nextInt(widget.colors.length)];
    return _ConfettiParticle(
      angle: angle,
      speed: speed,
      size: size,
      sway: sway,
      spin: spin,
      color: color,
    );
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
                  painter: _ConfettiPainter(
                    progress: _anim.value,
                    particles: _particles,
                    durationSeconds: widget.duration.inMilliseconds / 1000,
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

class _ConfettiParticle {
  _ConfettiParticle({
    required this.angle,
    required this.speed,
    required this.size,
    required this.sway,
    required this.spin,
    required this.color,
  });

  final double angle;
  final double speed;
  final double size;
  final double sway;
  final double spin;
  final Color color;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({
    required this.progress,
    required this.particles,
    required this.durationSeconds,
  });

  final double progress;
  final List<_ConfettiParticle> particles;
  final double durationSeconds;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || particles.isEmpty) return;
    final centerX = size.width / 2;
    final baseY = size.height;
    const gravity = 420.0; // slower pull so pieces climb higher before falling
    final paint = Paint();

    for (final p in particles) {
      final t = progress * durationSeconds;
      final vx = math.cos(p.angle) * p.speed;
      final vy = math.sin(p.angle) * p.speed;

      var x = centerX + (vx * t);
      // start from bottom, shoot upward (vy negative), then gravity pulls down
      var y = baseY + (vy * t) + 0.5 * gravity * math.pow(t, 2);
      // horizontal sway
      x += math.sin(t * 8 + p.sway) * 12;

      // Cap so we don't paint way off canvas
      if (y < -80 || y > size.height + 140) continue;

      final rotation = p.spin * t;
      paint.color = p.color.withOpacity((1 - progress).clamp(0.0, 1.0));

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromCenter(
              center: Offset.zero, width: p.size, height: p.size * 2),
          topLeft: const Radius.circular(3),
          topRight: const Radius.circular(3),
          bottomLeft: const Radius.circular(3),
          bottomRight: const Radius.circular(3),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.particles != particles ||
        oldDelegate.durationSeconds != durationSeconds;
  }
}
