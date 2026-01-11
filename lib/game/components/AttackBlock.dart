import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import 'FallingBlock.dart';

/// Player-sent Tahu block that moves upward
class AttackBlock extends RectangleComponent with HasGameRef, CollisionCallbacks {
  final Vector2 velocity;

  AttackBlock({
    required Vector2 position,
    required this.velocity,
  }) : super(
          position: position,
          size: Vector2(30, 30), // Smaller than falling blocks
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    paint = Paint()..color = Colors.orange; // Orange to distinguish from falling yellow Tahu
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Move upward
    position += velocity * dt;
    
    // Remove if off screen (top)
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
    
    if (other is FallingBlock) {
      // Deal 1 damage to falling block
      other.takeDamage(1);
      
      // Remove this attack block
      removeFromParent();
    }
  }
}
