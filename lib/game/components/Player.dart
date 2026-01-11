import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import '../../managers/HapticManager.dart';
import 'Bullet.dart';

/// Player component with shooting mechanics and skin system
class Player extends RectangleComponent with HasGameRef {
  Player({required Vector2 position})
      : super(
          position: position,
          size: Vector2(50, 50),
          anchor: Anchor.center,
        );

  // Skin colors (unlockable via shop)
  static const List<Color> skinColors = [
    Colors.blue,      // Default (free)
    Colors.green,     // 50 Beans
    Colors.purple,    // 100 Beans
    Colors.orange,    // 150 Beans
    Colors.pink,      // 200 Beans
  ];

  int currentSkin = 0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    paint = Paint()..color = skinColors[currentSkin];
    add(RectangleHitbox());
  }

  /// Fire a single bullet (tap)
  void shootSingle() {
    HapticManager().light();
    
    final bullet = Bullet(
      position: position.clone() + Vector2(0, -size.y / 2),
      velocity: Vector2(0, -300),
    );
    gameRef.add(bullet);
  }

  /// Fire dual bullets (swipe up)
  void shootDual() {
    HapticManager().light();
    
    // Left bullet
    final leftBullet = Bullet(
      position: position.clone() + Vector2(-15, -size.y / 2),
      velocity: Vector2(0, -300),
    );
    
    // Right bullet
    final rightBullet = Bullet(
      position: position.clone() + Vector2(15, -size.y / 2),
      velocity: Vector2(0, -300),
    );
    
    gameRef.add(leftBullet);
    gameRef.add(rightBullet);
  }

  /// Change player skin
  void setSkin(int skinIndex) {
    if (skinIndex >= 0 && skinIndex < skinColors.length) {
      currentSkin = skinIndex;
      paint.color = skinColors[skinIndex];
    }
  }

  /// Move player horizontally (optional for swipe left/right)
  void move(double dx) {
    position.x += dx;
    // Clamp to game boundaries
    position.x = position.x.clamp(size.x / 2, gameRef.size.x - size.x / 2);
  }
}
