import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import 'Enemy.dart';

/// Bullet component fired by the player
class Bullet extends RectangleComponent with HasGameRef, CollisionCallbacks {
  final Vector2 velocity;

  Bullet({
    required Vector2 position,
    required this.velocity,
  }) : super(
          position: position,
          size: Vector2(8, 20),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    paint = Paint()..color = Colors.white;
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Move bullet
    position += velocity * dt;
    
    // Remove if off screen
    if (position.y < -size.y) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    
    if (other is Enemy) {
      // Deal 1 damage to enemy
      other.takeDamage(1);
      
      // Increment combo
      (gameRef as dynamic).incrementCombo();
      
      // Remove bullet
      removeFromParent();
    }
  }
}
