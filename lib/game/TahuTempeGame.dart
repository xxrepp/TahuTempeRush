import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'components/Player.dart';
import 'components/Enemy.dart';
import '../managers/AudioManager.dart';
import '../managers/HapticManager.dart';

/// Main game class for TahuTempeRush
class TahuTempeGame extends FlameGame with HasCollisionDetection {
  late Player player;
  
  int score = 0;
  int highScore = 0;
  int combo = 0;
  int consecutiveMisses = 0;
  bool gameOver = false;
  bool reviveUsed = false;
  
  // Difficulty scaling
  double baseSpawnInterval = 1.0; // seconds
  double currentSpawnInterval = 1.0;
  double baseFallSpeed = 100.0;
  double currentFallSpeed = 100.0;
  
  double _spawnTimer = 0;
  final Random _random = Random();

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Load high score
    await _loadHighScore();
    
    // Create player at bottom center
    player = Player(position: Vector2(size.x / 2, size.y - 80));
    await add(player);
    
    // Start background music
    AudioManager().playBackgroundMusic();
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    if (gameOver) return;
    
    // Spawn enemies
    _spawnTimer += dt;
    if (_spawnTimer >= currentSpawnInterval) {
      _spawnTimer = 0;
      _spawnEnemy();
    }
    
    // Update difficulty every 100 points
    _updateDifficulty();
    
    // Update music speed every 500 points
    AudioManager().updateMusicSpeed(score);
  }

  /// Spawn a random enemy
  void _spawnEnemy() {
    final x = _random.nextDouble() * size.x;
    final spawnPos = Vector2(x, -50);
    
    // 2% chance for Sambal power-up
    if (_random.nextDouble() < 0.02) {
      add(Enemy(
        type: EnemyType.sambal,
        position: spawnPos,
        fallSpeed: currentFallSpeed,
      ));
    } else {
      // Random Tahu or Tempe (60% Tahu, 40% Tempe)
      final type = _random.nextDouble() < 0.6 
          ? EnemyType.tahu 
          : EnemyType.tempe;
      
      add(Enemy(
        type: type,
        position: spawnPos,
        fallSpeed: currentFallSpeed,
      ));
    }
  }

  /// Update difficulty based on score
  void _updateDifficulty() {
    final difficultyMultiplier = 1.0 + (score ~/ 100) * 0.05;
    currentFallSpeed = baseFallSpeed * difficultyMultiplier;
    currentSpawnInterval = baseSpawnInterval / difficultyMultiplier;
  }

  /// Add score and check high score
  void addScore(int points) {
    score += points;
    if (score > highScore) {
      highScore = score;
      _saveHighScore();
    }
  }

  /// Increment combo on successful hit
  void incrementCombo() {
    combo++;
    consecutiveMisses = 0;
  }

  /// Reset combo on miss
  void resetCombo() {
    combo = 0;
  }

  /// Trigger nuke (clear all enemies)
  void triggerNuke() {
    HapticManager().heavy();
    _shakeScreen();
    
    // Find and remove all enemies
    final enemies = children.whereType<Enemy>().toList();
    for (final enemy in enemies) {
      if (enemy.type != EnemyType.sambal) {
        // Award points for cleared enemies
        if (enemy.type == EnemyType.tahu) {
          addScore(10);
        } else if (enemy.type == EnemyType.tempe) {
          addScore(20);
        }
      }
      enemy.removeFromParent();
    }
  }

  /// Shake screen effect
  void _shakeScreen() {
    // Simple camera shake implementation
    final originalPos = camera.viewfinder.position.clone();
    
    Future.delayed(const Duration(milliseconds: 50), () {
      camera.viewfinder.position = originalPos + Vector2(5, 5);
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      camera.viewfinder.position = originalPos + Vector2(-5, -5);
    });
    Future.delayed(const Duration(milliseconds: 150), () {
      camera.viewfinder.position = originalPos;
    });
  }

  /// End game
  void endGame() {
    gameOver = true;
    HapticManager().heavy();
    _shakeScreen();
    AudioManager().stopBackgroundMusic();
    overlays.add('GameOver');
  }

  /// Revive player (called from GameOver overlay)
  void revive() {
    gameOver = false;
    reviveUsed = true;
    
    // Clear all enemies
    final enemies = children.whereType<Enemy>().toList();
    for (final enemy in enemies) {
      enemy.removeFromParent();
    }
    
    // Resume game
    AudioManager().playBackgroundMusic();
    overlays.remove('GameOver');
  }

  /// Reset game for new run
  void resetGame() {
    score = 0;
    combo = 0;
    gameOver = false;
    reviveUsed = false;
    currentFallSpeed = baseFallSpeed;
    currentSpawnInterval = baseSpawnInterval;
    
    // Remove all enemies
    final enemies = children.whereType<Enemy>().toList();
    for (final enemy in enemies) {
      enemy.removeFromParent();
    }
    
    // Reset player position
    player.position = Vector2(size.x / 2, size.y - 80);
    
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
