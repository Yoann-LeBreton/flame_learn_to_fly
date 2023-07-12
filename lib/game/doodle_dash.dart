import 'dart:ui';

import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_learn_to_fly/game/managers/managers.dart';
import 'package:flame_learn_to_fly/game/world.dart';
import 'sprites/sprites.dart';

import 'models/enum_game_state.dart';

class DoodleDash extends FlameGame 
  with HasKeyboardHandlerComponents, HasCollisionDetection{
  DoodleDash({super.children});

  final World _world = World();
  LevelManager levelManager = LevelManager();
  GameManager gameManager = GameManager();
  int screenBufferSpace = 300;
  ObjectManager objectManager = ObjectManager();

  late Player player;
  /// Register components game
  @override
  Future<void> onLoad() async {
    await add(_world);
    await add(gameManager);
    overlays.add('gameOverlay');
    await add(levelManager);
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Losing the game: Add isGameOver check

    if (gameManager.isIntro) {
      overlays.add('mainMenuOverlay');
      return;
    }
    if(gameManager.isGameOver){
      return;
    }

    if (gameManager.isPlaying) {
      checkLevelUp();

      final Rect newWorldBounds = Rect.fromLTRB(
          0,
          camera.position.y - screenBufferSpace,
          camera.gameSize.x,
          camera.position.y + _world.size.y
      );
      camera.worldBounds = newWorldBounds;
      if(player.isMovingDown){
        camera.worldBounds = newWorldBounds;
      }
      var isInTopHalfOfScreen = player.position.y <= (_world.size.y /2);
      if(!player.isMovingDown && isInTopHalfOfScreen){
        camera.followComponent(player);
      }

      if (player.position.y >
          camera.position.y +
              _world.size.y +
              player.size.y +
              screenBufferSpace) {
        onLose();
      }
    }
  }

  @override
  Color backgroundColor() {
    return const Color.fromARGB(255, 241, 247, 249);
  }

  void initializeGameStart() {
    setCharacter();
    gameManager.reset();

    if (children.contains(objectManager)) objectManager.removeFromParent();

    levelManager.reset();

    player.reset();
    final Rect newWorldBounds = Rect.fromLTRB(
        0,
        -_world.size.y ,
        camera.gameSize.x,
        _world.size.y + screenBufferSpace);
    camera.worldBounds = newWorldBounds;
    camera.followComponent(player);
    player.resetPosition();

    objectManager = ObjectManager(
        minVerticalDistanceToNextPlatform: levelManager.minDistance,
        maxVerticalDistanceToNextPlatform: levelManager.maxDistance);

    add(objectManager);

    objectManager.configure(levelManager.level, levelManager.difficulty);
  }

  void setCharacter() {
    //Initialize character
    player = Player(character: gameManager.character, jumpSpeed: levelManager.startingJumpSpeed);
    add(player);
  }

  void startGame() {
    initializeGameStart();
    gameManager.state = GameState.playing;
    overlays.remove('mainMenuOverlay');
  }

  void onLose(){
    gameManager.state = GameState.gameOver;
    player.removeFromParent();
    //Display GameOverScreen
    overlays.add('gameOverOverlay');
  }

  void resetGame() {
    startGame();
    overlays.remove('gameOverOverlay');
  }

  void togglePauseState() {
    if (paused) {
      resumeEngine();
    } else {
      pauseEngine();
    }
  }

  void checkLevelUp() {
    if (levelManager.shouldLevelUp(gameManager.score.value)) {
      levelManager.increaseLevel();

      objectManager.configure(levelManager.level, levelManager.difficulty);

      // Core gameplay: Call setJumpSpeed
    }
  }
}