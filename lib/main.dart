import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/animals_screen.dart';
import 'screens/bubbles_screen.dart';
import 'screens/xylophone_screen.dart';
import 'screens/shapes_screen.dart';
import 'services/sound_service.dart';
import 'widgets/particle_overlay.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Fullscreen sticky mode for toddlers
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const ToddlerJoyApp());
}

class ToddlerJoyApp extends StatelessWidget {
  const ToddlerJoyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Toddler Joy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFFF8ED),
        fontFamily: 'sans-serif',
      ),
      home: const ToddlerHomePage(),
    );
  }
}

class ToddlerHomePage extends StatefulWidget {
  const ToddlerHomePage({super.key});

  @override
  State<ToddlerHomePage> createState() => _ToddlerHomePageState();
}

class _ToddlerHomePageState extends State<ToddlerHomePage> {
  int _activeTab = 0;

  static const List<String> _tabLabels = [
    '🦁 Zoo',
    '🫧 Pop',
    '🎵 Music',
    '🎨 Shapes',
  ];

  void _onTabSelect(int index) {
    if (_activeTab == index) return;
    setState(() {
      _activeTab = index;
    });

    SoundService.vibrate();

    switch (index) {
      case 0:
        SoundService.speak('Animals!');
        break;
      case 1:
        SoundService.speak('Pop the bubbles!');
        break;
      case 2:
        SoundService.speak('Music time!');
        break;
      case 3:
        SoundService.speak('Colors and shapes!');
        break;
    }
  }

  Widget _buildBody() {
    switch (_activeTab) {
      case 0:
        return const AnimalsScreen();
      case 1:
        return const BubblesScreen();
      case 2:
        return const XylophoneScreen();
      case 3:
        return const ShapesScreen();
      default:
        return const AnimalsScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ParticleOverlay(
        child: SafeArea(
          child: Column(
            children: [
              // Header & Tabs
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Column(
                  children: [
                    const Text(
                      '✨ Toddler Joy ✨',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3D405B),
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFF3E5D8), width: 2),
                      ),
                      child: Row(
                        children: List.generate(_tabLabels.length, (index) {
                          final bool isSelected = _activeTab == index;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => _onTabSelect(index),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFFFF6B8B)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Center(
                                  child: Text(
                                    _tabLabels[index],
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? Colors.white
                                          : const Color(0xFF7A869A),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
              // Screen Content
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: _buildBody(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
