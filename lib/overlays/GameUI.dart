import 'package:flutter/material.dart';

/// In-game HUD overlay
class GameUI extends StatelessWidget {
  final int score;
  final int beans;

  const GameUI({
    super.key,
    required this.score,
    required this.beans,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          // Score (top center)
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Score: $score',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 4,
                      color: Colors.black,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Bean balance (top left)
          Positioned(
            top: 20,
            left: 20,
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Colors.brown,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$beans',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 4,
                        color: Colors.black,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Instructions (bottom)
          const Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Column(
                children: [
                  Text(
                    'TAP: 1 Block',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'SWIPE UP: 2 Blocks',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

