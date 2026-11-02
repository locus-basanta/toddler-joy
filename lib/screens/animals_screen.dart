import 'package:flutter/material.dart';
import '../services/sound_service.dart';
import '../widgets/particle_overlay.dart';

class AnimalItem {
  final String emoji;
  final String name;
  final String soundKey;
  final String speech;
  final Color bgColor;

  const AnimalItem({
    required this.emoji,
    required this.name,
    required this.soundKey,
    required this.speech,
    required this.bgColor,
  });
}

class AnimalsScreen extends StatelessWidget {
  const AnimalsScreen({super.key});

  static const List<AnimalItem> animals = [
    AnimalItem(
      emoji: '🐶',
      name: 'Puppy',
      soundKey: 'dog',
      speech: 'Woof! Happy puppy!',
      bgColor: Color(0xFFFFE8DC),
    ),
    AnimalItem(
      emoji: '🐱',
      name: 'Kitty',
      soundKey: 'cat',
      speech: 'Meow! Cute kitty!',
      bgColor: Color(0xFFE1F5FE),
    ),
    AnimalItem(
      emoji: '🦁',
      name: 'Lion',
      soundKey: 'lion',
      speech: 'Roar! King lion!',
      bgColor: Color(0xFFFFF3CD),
    ),
    AnimalItem(
      emoji: '🐮',
      name: 'Cow',
      soundKey: 'cow',
      speech: 'Moo! Sweet cow!',
      bgColor: Color(0xFFE8F5E9),
    ),
    AnimalItem(
      emoji: '🦆',
      name: 'Duck',
      soundKey: 'duck',
      speech: 'Quack quack! Yellow duck!',
      bgColor: Color(0xFFFFF9C4),
    ),
    AnimalItem(
      emoji: '🐸',
      name: 'Frog',
      soundKey: 'frog',
      speech: 'Ribbit! Jumping frog!',
      bgColor: Color(0xFFE0F2F1),
    ),
    AnimalItem(
      emoji: '🐑',
      name: 'Sheep',
      soundKey: 'sheep',
      speech: 'Baa baa! Fluffy sheep!',
      bgColor: Color(0xFFF3E5F5),
    ),
    AnimalItem(
      emoji: '🐘',
      name: 'Elephant',
      soundKey: 'elephant',
      speech: 'Trumpet! Big elephant!',
      bgColor: Color(0xFFEDE7F6),
    ),
  ];

  static const List<Color> particleColors = [
    Color(0xFFFF4D6D),
    Color(0xFFFF8C38),
    Color(0xFFFFC82C),
    Color(0xFF38D39F),
    Color(0xFF3A86FF),
    Color(0xFF8338EC),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: GridView.builder(
        itemCount: animals.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 1.15,
        ),
        itemBuilder: (context, index) {
          final item = animals[index];
          return _AnimalCard(
            item: item,
            particleColors: particleColors,
          );
        },
      ),
    );
  }
}

class _AnimalCard extends StatefulWidget {
  final AnimalItem item;
  final List<Color> particleColors;

  const _AnimalCard({
    super.key,
    required this.item,
    required this.particleColors,
  });

  @override
  State<_AnimalCard> createState() => _AnimalCardState();
}

class _AnimalCardState extends State<_AnimalCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.88), weight: 35),
      TweenSequenceItem(tween: Tween(begin: 0.88, end: 1.12), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.12, end: 1.0), weight: 25),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTap(TapUpDetails details) {
    _controller.forward(from: 0.0);

    SoundService.playSound(widget.item.soundKey);
    SoundService.speak(widget.item.speech);
    SoundService.vibrate();

    final RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box != null) {
      final Offset globalPos = box.localToGlobal(details.localPosition);
      ParticleOverlay.of(context)?.spawn(globalPos, widget.particleColors, 18);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapUp: _onTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: widget.item.bgColor,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.black12, width: 2.5),
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
                widget.item.emoji,
                style: const TextStyle(fontSize: 48),
              ),
              const SizedBox(height: 6),
              Text(
                widget.item.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
