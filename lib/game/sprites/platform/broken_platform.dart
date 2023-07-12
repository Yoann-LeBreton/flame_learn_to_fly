import 'package:flame/components.dart';
import 'package:flame_learn_to_fly/game/sprites/platform/platform.dart';


import '../../models/enum_broken_platform_state.dart';

class BrokenPlatform extends Platform<BrokenPlatformState> {
  BrokenPlatform({super.position});

  @override
  Future<void>? onLoad() async {
    await super.onLoad();

    sprites = <BrokenPlatformState, Sprite>{
      BrokenPlatformState.cracked:
      await gameRef.loadSprite('game/platform_cracked_monitor.png'),
      BrokenPlatformState.broken:
      await gameRef.loadSprite('game/platform_monitor_broken.png'),
    };
    current = BrokenPlatformState.cracked;
    size = Vector2(115, 84);
  }

  void breakPlatform() {
    current = BrokenPlatformState.broken;
  }
}