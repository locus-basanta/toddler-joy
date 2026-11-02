import 'dart:math';
import 'package:flutter/material.dart';

class ParticleOverlay extends StatefulWidget {
  final Widget child;

  const ParticleOverlay({super.key, required this.child});

  static ParticleOverlayState? of(BuildContext context) {
    return context.findAncestorStateOfType<ParticleOverlayState>();
  }

  @override
  ParticleOverlayState createState() => ParticleOverlayState();
}

class ParticleOverlayState extends State<ParticleOverlay>
    with SingleTickerProviderStateMixin {
  final List<Particle> _particles = [];
  final Random _random = Random();
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..addListener(_updateParticles);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void spawn(Offset origin, List<Color> colors, int count) {
    for (int i = 0; i < count; i++) {
      final double angle = _random.nextDouble() * 2 * pi;
      final double speed = 5.0 + _random.nextDouble() * 14.0;
      _particles.add(Particle(
        x: origin.dx,
        y: origin.dy,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed - 4.0,
        size: 16.0 + _random.nextDouble() * 22.0,
        color: colors[_random.nextInt(colors.length)],
        rotation: _random.nextDouble() * 360,
        rotSpeed: -12.0 + _random.nextDouble() * 24.0,
        shape: _random.nextInt(3),
        alpha: 1.0,
      ));
    }
    if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  void _updateParticles() {
    if (_particles.isEmpty) {
      if (_controller.isAnimating) _controller.stop();
      return;
    }

    setState(() {
      for (int i = _particles.length - 1; i >= 0; i--) {
        final p = _particles[i];
        p.x += p.vx;
        p.y += p.vy;
        p.vy += 0.55; // Gravity
        p.vx *= 0.96; // Air resistance
        p.rotation += p.rotSpeed;
        p.alpha -= 0.025;

        if (p.alpha <= 0) {
          _particles.removeAt(i);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: ParticlePainter(_particles),
            ),
          ),
        ),
      ],
    );
  }
}

class Particle {
  double x, y;
  double vx, vy;
  double size;
  Color color;
  double rotation;
  double rotSpeed;
  int shape; // 0: Star, 1: Circle, 2: Heart
  double alpha;

  Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.color,
    required this.rotation,
    required this.rotSpeed,
    required this.shape,
    required this.alpha,
  });
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;

  ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..isAntiAlias = true;

    for (final p in particles) {
      final effectiveAlpha = (p.alpha * 255).clamp(0, 255).toInt();
      paint.color = p.color.withAlpha(effectiveAlpha);

      canvas.save();
      canvas.translate(p.x, p.y);
      canvas.rotate(p.rotation * pi / 180);

      if (p.shape == 0) {
        _drawStar(canvas, p.size, paint);
      } else if (p.shape == 1) {
        canvas.drawCircle(Offset.zero, p.size * 0.45, paint);
      } else {
        _drawHeart(canvas, p.size, paint);
      }

      canvas.restore();
    }
  }

  void _drawStar(Canvas canvas, double size, Paint paint) {
    final Path path = Path();
    final double outer = size * 0.5;
    final double inner = outer * 0.45;
    for (int i = 0; i < 10; i++) {
      final double angle = -pi / 2 + i * pi / 5;
      final double r = i.isEven ? outer : inner;
      final double x = cos(angle) * r;
      final double y = sin(angle) * r;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawHeart(Canvas canvas, double size, Paint paint) {
    final double h = size * 0.45;
    final Path path = Path()
      ..moveTo(0, h * 0.3)
      ..cubicTo(-h, -h * 0.6, -h * 1.2, h * 0.5, 0, h * 1.2)
      ..cubicTo(h * 1.2, h * 0.5, h, -h * 0.6, 0, h * 0.3)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) => true;
}
