import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame_learn_to_fly/game/models/enum_normal_platform_state.dart';
import 'package:flame_learn_to_fly/game/sprites/platform/platform.dart';

class NormalPlatform extends Platform<NormalPlatformState> {
  NormalPlatform({super.position});

  final Map<String, Vector2> spriteOptions = {
    'platform_monitor': Vector2(115, 84),
    'platform_phone_center': Vector2(100, 55),
    'platform_terminal': Vector2(110, 83),
    'platform_laptop': Vector2(100, 63),
  };

  @override
  Future<void>? onLoad() async {
    //Generate a Random platform
    var randomSpriteIndex = Random().nextInt(spriteOptions.length);
    String randomSpriteName = spriteOptions.keys.elementAt(randomSpriteIndex);
    //init map state - sprite
    sprites = {
      NormalPlatformState.only: await gameRef.loadSprite('game/$randomSpriteName.png')
    };
    //set the state
    current = NormalPlatformState.only;
    //set the sprite size
    size = spriteOptions[randomSpriteName]!;
    await super.onLoad();
  }
}