import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame_learn_to_fly/game/models/enum_enemy_platform_state.dart';
import 'package:flame_learn_to_fly/game/sprites/platform/platform.dart';

class EnemyPlatform extends Platform<EnemyPlatformState>{
  EnemyPlatform({super.position});

  @override
  Future<void>? onLoad() async {
    var randBool = Random().nextBool();
    var enemySprite = randBool ? 'enemy_trash_can' : 'enemy_error';

    sprites = <EnemyPlatformState, Sprite>{
      EnemyPlatformState.only : await gameRef.loadSprite('game/$enemySprite.png')
    };

    current = EnemyPlatformState.only;
    return super.onLoad();
  }
}