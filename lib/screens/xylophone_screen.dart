import 'package:flutter/material.dart';
import '../services/sound_service.dart';
import '../widgets/particle_overlay.dart';

class XyloKeyData {
  final String noteName;
  final String solfege;
  final String soundKey;
  final Color color;

  const XyloKeyData({
    required this.noteName,
    required this.solfege,
    required this.soundKey,
    required this.color,
  });
}

class XylophoneScreen extends StatelessWidget {
  const XylophoneScreen({super.key});

  static const List<XyloKeyData> keys = [
    XyloKeyData(noteName: 'C', solfege: 'Do', soundKey: 'note_c4', color: Color(0xFFFF385C)),
    XyloKeyData(noteName: 'D', solfege: 'Re', soundKey: 'note_d4', color: Color(0xFFFF8A00)),
    XyloKeyData(noteName: 'E', solfege: 'Mi', soundKey: 'note_e4', color: Color(0xFFFFC700)),
    XyloKeyData(noteName: 'F', solfege: 'Fa', soundKey: 'note_f4', color: Color(0xFF00D084)),
    XyloKeyData(noteName: 'G', solfege: 'Sol', soundKey: 'note_g4', color: Color(0xFF06D6A0)),
    XyloKeyData(noteName: 'A', solfege: 'La', soundKey: 'note_a4', color: Color(0xFF2A9D8F)),
    XyloKeyData(noteName: 'B', solfege: 'Ti', soundKey: 'note_b4', color: Color(0xFF4361EE)),
    XyloKeyData(noteName: 'C\'', solfege: 'Do', soundKey: 'note_c5', color: Color(0xFFB5179E)),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      child: Column(
        children: List.generate(keys.length, (index) {
          final keyData = keys[index];
          final double margin = 4.0 + index * 5.0;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: margin, vertical: 5.0),
              child: _XyloKeyWidget(data: keyData),
            ),
          );
        }),
      ),
    );
  }
}

class _XyloKeyWidget extends StatefulWidget {
  final XyloKeyData data;

  const _XyloKeyWidget({super.key, required this.data});

  @override
  State<_XyloKeyWidget> createState() => _XyloKeyWidgetState();
}

class _XyloKeyWidgetState extends State<_XyloKeyWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.94), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 0.94, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward(from: 0.0);

    SoundService.playSound(widget.data.soundKey);
    SoundService.vibrate();

    final RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box != null) {
      final Offset globalPos = box.localToGlobal(details.localPosition);
      ParticleOverlay.of(context)?.spawn(
        globalPos,
        [widget.data.color, Colors.white, const Color(0xFFFFEAA7)],
        12,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: widget.data.color,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.35), width: 2.5),
            boxShadow: const [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 4,
                offset: Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('🔘', style: TextStyle(fontSize: 14)),
              Text(
                '${widget.data.solfege}  (${widget.data.noteName})',
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.1,
                ),
              ),
              const Text('🔘', style: TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}
