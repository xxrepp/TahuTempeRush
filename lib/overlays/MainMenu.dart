import 'package:flutter/material.dart';
import '../game/TahuTempeGame.dart';

/// Main menu overlay
class MainMenu extends StatelessWidget {
  final TahuTempeGame game;

  const MainMenu({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Title
            const Text(
              'TahuTempeRush',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.yellow,
                shadows: [
                  Shadow(
                    blurRadius: 10,
                    color: Colors.orange,
                    offset: Offset(0, 0),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // High Score
            Text(
              'High Score: ${game.highScore}',
              style: const TextStyle(
                fontSize: 24,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(height: 60),
            
            // Play Button
            ElevatedButton(
              onPressed: () {
                game.overlays.remove('MainMenu');
                game.overlays.add('GameUI');
                game.resetGame();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(
                  horizontal: 60,
                  vertical: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'PLAY',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Shop Button
            ElevatedButton(
              onPressed: () {
                game.overlays.remove('MainMenu');
                game.overlays.add('Shop');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(
                  horizontal: 60,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'SHOP',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Instructions
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  Text(
                    'TAP: Single Shot',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'SWIPE UP: Dual Shot',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
