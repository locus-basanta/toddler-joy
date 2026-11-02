import 'dart:math';
import 'package:flutter/material.dart';
import '../services/sound_service.dart';
import '../widgets/particle_overlay.dart';

class BubblesScreen extends StatefulWidget {
  const BubblesScreen({super.key});

  @override
  State<BubblesScreen> createState() => _BubblesScreenState();
}

class _BubblesScreenState extends State<BubblesScreen>
    with SingleTickerProviderStateMixin {
  final List<_Bubble> _bubbles = [];
  final Random _random = Random();
  late AnimationController _ticker;
  int _popCount = 0;

  static const List<Color> _bubbleColors = [
    Color(0x88FF6B8B),
    Color(0x884D96FF),
    Color(0x886BCB77),
    Color(0x88FFD93D),
    Color(0x889D4EDD),
    Color(0x88FF9F45),
  ];

  static const List<String> _items = [
    '⭐', '🎈', '🍭', '🍓', '🌸', '🐥', '🦋', '🌈', '🐟', '🚀', '🍄', '🧁'
  ];

  @override
  void initState() {
    super.initState();
    _ticker = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..addListener(_tick);
    _ticker.repeat();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _initBubbles(Size size) {
    if (_bubbles.isNotEmpty) return;
    final int count = max(10, (size.width / 65).round());
    for (int i = 0; i < count; i++) {
      _spawnBubble(size, _random.nextDouble() * size.height);
    }
  }

  void _spawnBubble(Size size, double startY) {
    final double radius = 35.0 + _random.nextDouble() * 22.0;
    _bubbles.add(_Bubble(
      x: radius + _random.nextDouble() * max(10.0, size.width - 2 * radius),
      y: startY,
      radius: radius,
      vy: 1.8 + _random.nextDouble() * 2.2,
      wobblePhase: _random.nextDouble() * 100,
      color: _bubbleColors[_random.nextInt(_bubbleColors.length)],
      item: _items[_random.nextInt(_items.length)],
    ));
  }

  void _tick() {
    setState(() {
      final double now = DateTime.now().millisecondsSinceEpoch * 0.003;
      for (final b in _bubbles) {
        b.y -= b.vy;
        b.x += sin(now + b.wobblePhase) * 1.5;
      }
    });
  }

  void _onTapDown(TapDownDetails details, Size size) {
    final Offset tap = details.localPosition;
    bool popped = false;

    for (int i = _bubbles.length - 1; i >= 0; i--) {
      final b = _bubbles[i];
      final double dx = tap.dx - b.x;
      final double dy = tap.dy - b.y;
      final double dist = sqrt(dx * dx + dy * dy);

      if (dist <= b.radius * 1.3) {
        _bubbles.removeAt(i);
        popped = true;
        _popCount++;

        SoundService.playSound('pop');
        SoundService.vibrate();

        final RenderBox? box = context.findRenderObject() as RenderBox?;
        if (box != null) {
          final Offset globalPos = box.localToGlobal(tap);
          ParticleOverlay.of(context)?.spawn(
            globalPos,
            [b.color.withAlpha(255), Colors.white, const Color(0xFFFFD700)],
            18,
          );
        }

        if (_popCount % 10 == 0) {
          SoundService.speak('Great job! $_popCount bubbles!');
        }

        _spawnBubble(size, size.height + b.radius + _random.nextDouble() * 60);
        break;
      }
    }

    if (!popped) {
      SoundService.vibrate();
      final RenderBox? box = context.findRenderObject() as RenderBox?;
      if (box != null) {
        final Offset globalPos = box.localToGlobal(tap);
        ParticleOverlay.of(context)?.spawn(
          globalPos,
          [Colors.white70, const Color(0xFFFFD93D)],
          6,
        );
      }
    }
  }

  void _popAll(Size size) {
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    for (final b in _bubbles) {
      _popCount++;
      if (box != null) {
        final Offset globalPos = box.localToGlobal(Offset(b.x, b.y));
        ParticleOverlay.of(context)?.spawn(
          globalPos,
          [b.color.withAlpha(255), Colors.white, const Color(0xFFFFD700)],
          14,
        );
      }
    }
    _bubbles.clear();
    SoundService.playSound('sparkle');
    SoundService.speak('Pop! Awesome!');

    for (int i = 0; i < 12; i++) {
      _spawnBubble(size, size.height + 60 + i * 40);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        _initBubbles(size);

        for (final b in _bubbles) {
          if (b.y < -b.radius * 2) {
            b.y = size.height + b.radius + _random.nextDouble() * 50;
            b.x = b.radius + _random.nextDouble() * max(10.0, size.width - 2 * b.radius);
          }
        }

        return Stack(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (details) => _onTapDown(details, size),
              child: CustomPaint(
                size: size,
                painter: _BubblePainter(_bubbles),
              ),
            ),
            Positioned(
              top: 12,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x11000000),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    '🫧 Pops: $_popCount',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Center(
                child: ElevatedButton.icon(
                  onPressed: () => _popAll(size),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B8B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 4,
                  ),
                  icon: const Text('🎉', style: TextStyle(fontSize: 20)),
                  label: const Text(
                    'POP ALL BUBBLES!',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Bubble {
  double x, y;
  double radius;
  double vy;
  double wobblePhase;
  Color color;
  String item;

  _Bubble({
    required this.x,
    required this.y,
    required this.radius,
    required this.vy,
    required this.wobblePhase,
    required this.color,
    required this.item,
  });
}

class _BubblePainter extends CustomPainter {
  final List<_Bubble> bubbles;

  _BubblePainter(this.bubbles);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint fillPaint = Paint()..style = PaintingStyle.fill;
    final Paint strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.white.withOpacity(0.7)
      ..strokeWidth = 2.5;

    final TextPainter tp = TextPainter(textDirection: TextDirection.ltr);

    for (final b in bubbles) {
      fillPaint.color = b.color;
      canvas.drawCircle(Offset(b.x, b.y), b.radius, fillPaint);

      final Rect arcRect = Rect.fromCircle(
        center: Offset(b.x, b.y),
        radius: b.radius * 0.75,
      );
      canvas.drawArc(arcRect, 3.5, 1.2, false, strokePaint);

      tp.text = TextSpan(
        text: b.item,
        style: TextStyle(fontSize: b.radius * 0.85),
      );
      tp.layout();
      tp.paint(
        canvas,
        Offset(b.x - tp.width / 2, b.y - tp.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BubblePainter oldDelegate) => true;
}
