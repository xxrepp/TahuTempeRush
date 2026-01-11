import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import '../../managers/HapticManager.dart';
import '../../managers/AudioManager.dart';
import '../../managers/CurrencyManager.dart';

enum EnemyType { tahu, tempe, sambal }

/// Enemy component with three types: Tahu, Tempe, Sambal
class Enemy extends RectangleComponent with HasGameRef, CollisionCallbacks {
  final EnemyType type;
  int health;
  final double fallSpeed;

  Enemy({
    required this.type,
    required Vector2 position,
    required this.fallSpeed,
  })  : health = type == EnemyType.tahu ? 1 : (type == EnemyType.tempe ? 2 : 1),
        super(
          position: position,
          size: _getSizeForType(type),
          anchor: Anchor.center,
        );

  static Vector2 _getSizeForType(EnemyType type) {
    switch (type) {
      case EnemyType.tahu:
        return Vector2(40, 40); // Yellow square
      case EnemyType.tempe:
        return Vector2(60, 30); // Brown rectangle
      case EnemyType.sambal:
        return Vector2(35, 50); // Red bottle shape
    }
  }

  Color _getColorForType() {
    switch (type) {
      case EnemyType.tahu:
        return Colors.yellow;
      case EnemyType.tempe:
        return health == 2 ? Colors.brown[700]! : Colors.brown[300]!;
      case EnemyType.sambal:
        return Colors.red;
    }
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    paint = Paint()..color = _getColorForType();
    add(RectangleHitbox());
    
    // Play spawn sound for Tahu (throttled)
    if (type == EnemyType.tahu) {
      AudioManager().playTahuSpawnSFX();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Fall down
    position.y += fallSpeed * dt;
    
    // Remove if off screen
    if (position.y > gameRef.size.y + size.y) {
      removeFromParent();
    }
  }

  /// Take damage from bullet
  void takeDamage(int damage) {
    health -= damage;
    
    if (health <= 0) {
      _onDestroyed();
    } else {
      // Update color for damaged Tempe
      if (type == EnemyType.tempe) {
        paint.color = _getColorForType();
      }
    }
  }

  /// Handle enemy destruction
  void _onDestroyed() {
    // Haptic feedback
    HapticManager().medium();
    
    // Play break sound
    AudioManager().playBreakSFX();
    
    // Award points and currency
    switch (type) {
      case EnemyType.tahu:
        (gameRef as dynamic).addScore(10);
        break;
      case EnemyType.tempe:
        (gameRef as dynamic).addScore(20);
        CurrencyManager().addBeans(1); // Drop 1 Bean
        break;
      case EnemyType.sambal:
        (gameRef as dynamic).triggerNuke(); // Clear all enemies
        break;
    }
    
    removeFromParent();
  }
}
