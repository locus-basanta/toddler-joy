import 'package:flutter/material.dart';
import '../services/sound_service.dart';
import '../widgets/particle_overlay.dart';

class ShapeItemData {
  final String icon;
  final String name;
  final String speakText;
  final Color shapeColor;
  final Color bgColor;

  const ShapeItemData({
    required this.icon,
    required this.name,
    required this.speakText,
    required this.shapeColor,
    required this.bgColor,
  });
}

class ShapesScreen extends StatelessWidget {
  const ShapesScreen({super.key});

  static const List<ShapeItemData> shapes = [
    ShapeItemData(
      icon: '🔴',
      name: 'Red Circle',
      speakText: 'Red Circle! Yay!',
      shapeColor: Color(0xFFFF4D6D),
      bgColor: Color(0xFFFFE5EC),
    ),
    ShapeItemData(
      icon: '🟦',
      name: 'Blue Square',
      speakText: 'Blue Square! Good job!',
      shapeColor: Color(0xFF3A86FF),
      bgColor: Color(0xFFE7F0FD),
    ),
    ShapeItemData(
      icon: '⭐',
      name: 'Yellow Star',
      speakText: 'Yellow Star! Twinkle twinkle!',
      shapeColor: Color(0xFFFFBE0B),
      bgColor: Color(0xFFFFF8DB),
    ),
    ShapeItemData(
      icon: '🔺',
      name: 'Green Triangle',
      speakText: 'Green Triangle! Great!',
      shapeColor: Color(0xFF06D6A0),
      bgColor: Color(0xFFE0FBF4),
    ),
    ShapeItemData(
      icon: '🧡',
      name: 'Orange Heart',
      speakText: 'Orange Heart! Sweet!',
      shapeColor: Color(0xFFFB5607),
      bgColor: Color(0xFFFFECE5),
    ),
    ShapeItemData(
      icon: '💎',
      name: 'Purple Diamond',
      speakText: 'Purple Diamond! Sparkle!',
      shapeColor: Color(0xFF8338EC),
      bgColor: Color(0xFFF2E7FE),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: GridView.builder(
        itemCount: shapes.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 1.15,
        ),
        itemBuilder: (context, index) {
          return _ShapeCard(item: shapes[index]);
        },
      ),
    );
  }
}

class _ShapeCard extends StatefulWidget {
  final ShapeItemData item;

  const _ShapeCard({super.key, required this.item});

  @override
  State<_ShapeCard> createState() => _ShapeCardState();
}

class _ShapeCardState extends State<_ShapeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.85), weight: 35),
      TweenSequenceItem(tween: Tween(begin: 0.85, end: 1.15), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 1.0), weight: 25),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _rotateAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -0.1), weight: 25),
      TweenSequenceItem(tween: Tween(begin: -0.1, end: 0.1), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 0.1, end: 0.0), weight: 25),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTap(TapUpDetails details) {
    _controller.forward(from: 0.0);

    SoundService.playSound('sparkle');
    SoundService.speak(widget.item.speakText);
    SoundService.vibrate();

    final RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box != null) {
      final Offset globalPos = box.localToGlobal(details.localPosition);
      ParticleOverlay.of(context)?.spawn(
        globalPos,
        [widget.item.shapeColor, Colors.white, const Color(0xFFFFD700)],
        20,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapUp: _onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.rotate(
            angle: _rotateAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: widget.item.bgColor,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: widget.item.shapeColor.withOpacity(0.35),
              width: 2.5,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.item.icon,
                style: const TextStyle(fontSize: 48),
              ),
              const SizedBox(height: 6),
              Text(
                widget.item.name,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2B2D42),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
