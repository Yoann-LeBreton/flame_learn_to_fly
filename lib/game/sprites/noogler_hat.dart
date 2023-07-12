import 'package:flame/components.dart';
import 'package:flame_learn_to_fly/game/sprites/powerup.dart';

class NooglerHat extends PowerUp {
  @override
  double get jumpSpeedMultiplier => 2.5;

  NooglerHat({super.position});
  
  final int activeLengthInMs = 5000;
  
  @override
  Future<void>? onLoad() async {
    await super.onLoad();
    sprite = await gameRef.loadSprite('game/noogler_hat.png');
    size = Vector2(75, 50);
  }
}