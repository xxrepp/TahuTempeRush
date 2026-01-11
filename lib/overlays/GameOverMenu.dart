import 'package:flutter/material.dart';
import '../game/TahuTempeGame.dart';
import '../managers/AdManager.dart';
import '../managers/IAPManager.dart';

/// Game over overlay with revive system
class GameOverMenu extends StatelessWidget {
  final TahuTempeGame game;

  const GameOverMenu({super.key, required this.game});

  Future<void> _handleRevive(BuildContext context) async {
    if (game.reviveUsed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Revive already used this run!')),
      );
      return;
    }

    // Check if premium (no ads)
    if (IAPManager().isPremium) {
      game.revive();
    } else {
      // Show rewarded ad
      final watched = await AdManager().showRewardedAd();
      if (watched) {
        game.revive();
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ad not available or not watched')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final canRevive = !game.reviveUsed;
    final isPremium = IAPManager().isPremium;

    return Material(
      color: Colors.black.withOpacity(0.9),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Game Over Text
            const Text(
              'GAME OVER',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.red,
                shadows: [
                  Shadow(
                    blurRadius: 10,
                    color: Colors.redAccent,
                    offset: Offset(0, 0),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Score
            Text(
              'Score: ${game.score}',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // High Score
            if (game.score >= game.highScore)
              const Text(
                '🎉 NEW HIGH SCORE! 🎉',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.yellow,
                ),
              )
            else
              Text(
                'High Score: ${game.highScore}',
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.white70,
                ),
              ),
            
            const SizedBox(height: 60),
            
            // Revive Button
            if (canRevive)
              ElevatedButton.icon(
                onPressed: () => _handleRevive(context),
                icon: const Icon(Icons.favorite, color: Colors.white),
                label: Text(
                  isPremium ? 'REVIVE (FREE)' : 'REVIVE (Watch Ad)',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            
            const SizedBox(height: 20),
            
            // Retry Button
            ElevatedButton(
              onPressed: () {
                game.overlays.remove('GameOver');
                game.overlays.add('GameUI');
                game.resetGame();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'RETRY',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Main Menu Button
            TextButton(
              onPressed: () {
                game.overlays.remove('GameOver');
                game.overlays.add('MainMenu');
              },
              child: const Text(
                'Main Menu',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
