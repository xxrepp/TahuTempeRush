import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'components/FallingBlock.dart';
import 'components/AttackBlock.dart';
import '../managers/AudioManager.dart';
import '../managers/HapticManager.dart';

/// Main game class for TahuTempeRush - Endless Block Game
class TahuTempeGame extends FlameGame with HasCollisionDetection {
  int score = 0;
  int highScore = 0;
  bool gameOver = false;
  
  // Difficulty scaling
  double baseSpawnInterval = 1.5; // seconds
  double currentSpawnInterval = 1.5;
  double baseFallSpeed = 150.0;
  double currentFallSpeed = 150.0;
  
  double _spawnTimer = 0;
  final Random _random = Random();

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Load high score
    await _loadHighScore();
    
    // Start background music
    AudioManager().playBackgroundMusic();
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    if (gameOver) return;
    
    // Spawn falling blocks
    _spawnTimer += dt;
    if (_spawnTimer >= currentSpawnInterval) {
      _spawnTimer = 0;
      _spawnFallingBlock();
    }
    
    // Update difficulty every 100 points
    _updateDifficulty();
    
    // Update music speed every 500 points
    AudioManager().updateMusicSpeed(score);
  }

  /// Spawn a random falling block from top
  void _spawnFallingBlock() {
    final x = _random.nextDouble() * size.x;
    final spawnPos = Vector2(x, -50);
    
    // 60% Tahu, 40% Tempe
    final type = _random.nextDouble() < 0.6 
        ? BlockType.tahu 
        : BlockType.tempe;
    
    add(FallingBlock(
      type: type,
      position: spawnPos,
      fallSpeed: currentFallSpeed,
    ));
  }

  /// Update difficulty based on score
  void _updateDifficulty() {
    final difficultyMultiplier = 1.0 + (score ~/ 100) * 0.1;
    currentFallSpeed = baseFallSpeed * difficultyMultiplier;
    currentSpawnInterval = baseSpawnInterval / difficultyMultiplier.clamp(1.0, 2.0);
  }

  /// Add score and check high score
  void addScore(int points) {
    score += points;
    if (score > highScore) {
      highScore = score;
      _saveHighScore();
    }
  }

  /// Send attack block(s) from bottom
  void sendAttackBlock({int count = 1}) {
    HapticManager().light();
    
    if (count == 1) {
      // Single block from center
      final attackBlock = AttackBlock(
        position: Vector2(size.x / 2, size.y - 50),
        velocity: Vector2(0, -400), // Move upward
      );
      add(attackBlock);
    } else {
      // Two blocks side by side
      final leftBlock = AttackBlock(
        position: Vector2(size.x / 2 - 20, size.y - 50),
        velocity: Vector2(0, -400),
      );
      final rightBlock = AttackBlock(
        position: Vector2(size.x / 2 + 20, size.y - 50),
        velocity: Vector2(0, -400),
      );
      add(leftBlock);
      add(rightBlock);
    }
  }

  /// End game
  void endGame() {
    if (gameOver) return; // Prevent multiple triggers
    
    gameOver = true;
    HapticManager().heavy();
    AudioManager().stopBackgroundMusic();
    overlays.add('GameOver');
  }

  /// Reset game for new run
  void resetGame() {
    score = 0;
    gameOver = false;
    currentFallSpeed = baseFallSpeed;
    currentSpawnInterval = baseSpawnInterval;
    
    // Remove all falling blocks and attack blocks
    final blocks = children.whereType<FallingBlock>().toList();
    for (final block in blocks) {
      block.removeFromParent();
    }
    
    final attacks = children.whereType<AttackBlock>().toList();
    for (final attack in attacks) {
      attack.removeFromParent();
    }
    
    AudioManager().playBackgroundMusic();
  }

  /// Load high score from storage
  Future<void> _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    highScore = prefs.getInt('high_score') ?? 0;
  }

  /// Save high score to storage
  Future<void> _saveHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('high_score', highScore);
  }
}
