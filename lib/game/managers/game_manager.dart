import 'package:flame/components.dart';
import 'package:flame_learn_to_fly/game/doodle_dash.dart';
import 'package:flutter/widgets.dart';

import '../models/enum_character.dart';
import '../models/enum_game_state.dart';

/// Game state management
class GameManager extends Component with HasGameRef<DoodleDash> {
  GameManager();

  Character character = Character.dash;
  ValueNotifier<int> score = ValueNotifier(0);
  GameState state = GameState.intro;

  bool get isPlaying => state == GameState.playing;
  bool get isGameOver => state == GameState.gameOver;
  bool get isIntro => state == GameState.intro;

  void reset(){
    score.value = 0;
    state = GameState.intro;
  }

  void increaseScore(){
    score.value++;
  }

  void selectCharacter(Character selectedCharacter) {
    character = selectedCharacter;
  }
}
