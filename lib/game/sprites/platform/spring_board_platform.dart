import 'package:flame/components.dart';
import 'package:flame_learn_to_fly/game/models/enum_spring_board_state.dart';

import 'platform.dart';

class SpringBoardPlatform extends Platform<SpringBoardState> {
  SpringBoardPlatform({
    super.position,
  });

  @override
  Future<void>? onLoad() async {
    await super.onLoad();

    sprites = <SpringBoardState, Sprite>{
      SpringBoardState.down:
      await gameRef.loadSprite('game/platform_trampoline_down.png'),
      SpringBoardState.up:
      await gameRef.loadSprite('game/platform_trampoline_up.png'),
    };

    current = SpringBoardState.up;

    size = Vector2(100, 45);
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);

    bool isCollidingVertically =
        (intersectionPoints.first.y - intersectionPoints.last.y).abs() < 5;

    if (isCollidingVertically) {
      current = SpringBoardState.down;
    }
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);

    current = SpringBoardState.up;
  }
}