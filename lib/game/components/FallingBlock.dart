import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';

enum BlockType { tahu, tempe }

/// Falling block component (replaces Enemy)
class FallingBlock extends RectangleComponent with HasGameRef, CollisionCallbacks {
  final BlockType type;
  int health;
  final double fallSpeed;

  FallingBlock({
    required this.type,
    required Vector2 position,
    required this.fallSpeed,
  })  : health = type == BlockType.tahu ? 1 : 2,
        super(
          position: position,
          size: _getSizeForType(type),
          anchor: Anchor.center,
        );

  static Vector2 _getSizeForType(BlockType type) {
    switch (type) {
      case BlockType.tahu:
        return Vector2(40, 40); // Yellow square
      case BlockType.tempe:
        return Vector2(60, 30); // Brown rectangle
    }
  }

  Color _getColorForType() {
    switch (type) {
      case BlockType.tahu:
        return Colors.yellow;
      case BlockType.tempe:
        return health == 2 ? Colors.brown[700]! : Colors.brown[300]!;
    }
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    paint = Paint()..color = _getColorForType();
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Fall down
    position.y += fallSpeed * dt;
    
    // Check if reached bottom - game over
    if (position.y > gameRef.size.y + size.y / 2) {
      (gameRef as dynamic).endGame();
      removeFromParent();
    }
  }

  /// Take damage from attack block
  void takeDamage(int damage) {
    health -= damage;
    
    if (health <= 0) {
      _onDestroyed();
    } else {
      // Update color for damaged Tempe
      if (type == BlockType.tempe) {
        paint.color = _getColorForType();
      }
    }
  }

  /// Handle block destruction
  void _onDestroyed() {
    // Award points
    final points = type == BlockType.tahu ? 10 : 20;
    (gameRef as dynamic).addScore(points);
    
    removeFromParent();
  }
}
