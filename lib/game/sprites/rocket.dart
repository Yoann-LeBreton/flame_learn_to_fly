import 'package:flame/components.dart';
import 'package:flame_learn_to_fly/game/sprites/powerup.dart';

class Rocket extends PowerUp {
  @override
  double get jumpSpeedMultiplier => 3.5;
  
  Rocket({super.position});
  
  @override
  Future<void>? onLoad() async {
    await super.onLoad();
    sprite = await gameRef.loadSprite('game/rocket_1.png');
    size = Vector2(50, 70);
  }
}