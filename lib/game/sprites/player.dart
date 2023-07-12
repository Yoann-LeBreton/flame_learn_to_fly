// Copyright 2022 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_learn_to_fly/game/models/enum_broken_platform_state.dart';
import 'package:flame_learn_to_fly/game/sprites/noogler_hat.dart';
import 'package:flame_learn_to_fly/game/sprites/rocket.dart';
import 'package:flutter/services.dart';

import '../doodle_dash.dart';
import '../models/enum_character.dart';
import '../models/enum_player_state.dart';
import 'sprites.dart';

class Player extends SpriteGroupComponent<PlayerState>
    with HasGameRef<DoodleDash>, KeyboardHandler, CollisionCallbacks {

  Player({
    super.position,
    required this.character,
    this.jumpSpeed = 600,
  }) : super(
    size: Vector2(79, 109),
    anchor: Anchor.center,
    priority: 1,
  );

  int _hAxisInput = 0;
  final int movingLeftInput = -1;
  final int movingRightInput = 1;
  Vector2 _velocity = Vector2.zero();
  bool get isMovingDown => _velocity.y > 0;
  Character character;
  double jumpSpeed;
  final double _gravity = 9;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await add(CircleHitbox());

    await _loadCharacterSprites();
    // Default Dash onLoad to center state
    current = PlayerState.center;
  }

  @override
  void update(double dt) {
    // check if game is on non-playable state
    if(gameRef.gameManager.isIntro || gameRef.gameManager.isGameOver) return;
    // calculation for Dash's horizontal velocity
    _velocity.x = _hAxisInput * jumpSpeed;

    final double dashHorizontalCenter = size.x / 2;

    // Infinite side boundaries logic
    if(position.x < dashHorizontalCenter){
      position.x = gameRef.size.x - (dashHorizontalCenter);
    }
    if(position.x > gameRef.size.x - (dashHorizontalCenter)){
      position.x = dashHorizontalCenter;
    }

    // add gravity to make player falls down
    _velocity.y += _gravity;
    position += _velocity*dt;
    super.update(dt);
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    _hAxisInput = 0;

    //keypress logic
    if(keysPressed.contains(LogicalKeyboardKey.arrowLeft)){
      moveLeft();
    }
    if(keysPressed.contains(LogicalKeyboardKey.arrowRight)){
      moveRight();
    }
    if(keysPressed.contains(LogicalKeyboardKey.arrowUp)){
      // jump();
    }
    return true;
  }

  void moveLeft() {
    _hAxisInput = 0;
    //logic for moving left
    if(isWearingHat){
      current = PlayerState.nooglerLeft;
    }else if(!hasPowerUp){
      current = PlayerState.left;
    }
    _hAxisInput += movingLeftInput;
  }

  void moveRight() {
    _hAxisInput = 0;
    //logic for moving right
    if(isWearingHat){
      current = PlayerState.nooglerRight;
    }else if(!hasPowerUp){
      current = PlayerState.right;
    }
    _hAxisInput += movingRightInput;
  }

  void resetDirection() {
    _hAxisInput = 0;
  }

  bool get hasPowerUp =>
      current == PlayerState.rocket ||
      current == PlayerState.nooglerLeft ||
      current == PlayerState.nooglerRight ||
      current == PlayerState.nooglerCenter;

  bool get isInvincible => current == PlayerState.rocket;

  bool get isWearingHat =>
      current == PlayerState.nooglerLeft ||
      current == PlayerState.nooglerRight ||
      current == PlayerState.nooglerCenter;

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    bool isCollidingVertically = (intersectionPoints.first.y - intersectionPoints.last.y).abs() < 5;
    if(other is EnemyPlatform && !isInvincible){
      gameRef.onLose();
      return;
    }

    if(isMovingDown && isCollidingVertically){
      current = PlayerState.center;
      if(other is NormalPlatform){
        jump();
        return;
      }else if(other is SpringBoardPlatform){
        jump(specialJumpSpeed: jumpSpeed * 2);
        return;
      }else if(other is BrokenPlatform
          && other.current == BrokenPlatformState.cracked){
        jump();
        other.breakPlatform();
        Future.delayed(const Duration(milliseconds: 800), () {
          gameRef.objectManager.removePlatform(other);
        });
        return;
      }
    }

    if(!hasPowerUp && other is Rocket){
      current == PlayerState.rocket;
      other.removeFromParent();
      jump(specialJumpSpeed: jumpSpeed * other.jumpSpeedMultiplier);
      return;
    } else if(!hasPowerUp && other is NooglerHat){
      if(current == PlayerState.center) current = PlayerState.nooglerCenter;
      if(current == PlayerState.left) current = PlayerState.nooglerLeft;
      if(current == PlayerState.right) current = PlayerState.nooglerRight;
      other.removeFromParent();
      _removePowerupAfterTime(other.activeLengthInMs);
      jump(specialJumpSpeed: jumpSpeed * other.jumpSpeedMultiplier);
      return;
    }
  }

  void jump({double? specialJumpSpeed}){
    _velocity.y = specialJumpSpeed != null ? - specialJumpSpeed : - jumpSpeed;
  }

  void _removePowerupAfterTime(int ms) {
    Future.delayed(Duration(milliseconds: ms), () {
      current = PlayerState.center;
    });
  }

  void setJumpSpeed(double newJumpSpeed) {
    jumpSpeed = newJumpSpeed;
  }

  void reset() {
    _velocity = Vector2.zero();
    current = PlayerState.center;
  }

  void resetPosition() {
    position = Vector2(
      (gameRef.size.x - size.x) / 2,
      (gameRef.size.y - size.y) / 2,
    );
  }

  Future<void> _loadCharacterSprites() async {
    // Load & configure sprite assets
    final left = await gameRef.loadSprite('game/${character.name}_left.png');
    final right = await gameRef.loadSprite('game/${character.name}_right.png');
    final center =
    await gameRef.loadSprite('game/${character.name}_center.png');
    final rocket = await gameRef.loadSprite('game/rocket_4.png');
    final nooglerCenter =
    await gameRef.loadSprite('game/${character.name}_hat_center.png');
    final nooglerLeft =
    await gameRef.loadSprite('game/${character.name}_hat_left.png');
    final nooglerRight =
    await gameRef.loadSprite('game/${character.name}_hat_right.png');

    //set map => state - sprite
    sprites = <PlayerState, Sprite>{
      PlayerState.left: left,
      PlayerState.right: right,
      PlayerState.center: center,
      PlayerState.rocket: rocket,
      PlayerState.nooglerCenter: nooglerCenter,
      PlayerState.nooglerLeft: nooglerLeft,
      PlayerState.nooglerRight: nooglerRight,
    };
  }
}
