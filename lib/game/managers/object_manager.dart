// Copyright 2022 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame_learn_to_fly/game/sprites/noogler_hat.dart';
import 'package:flame_learn_to_fly/game/sprites/rocket.dart';

import './managers.dart';
import '../doodle_dash.dart';
import '../sprites/sprites.dart';
import '../util/util.dart';

final Random _rand = Random();

class ObjectManager extends Component with HasGameRef<DoodleDash> {
  ObjectManager({
    this.minVerticalDistanceToNextPlatform = 200,
    this.maxVerticalDistanceToNextPlatform = 300,
  });

  double minVerticalDistanceToNextPlatform;
  double maxVerticalDistanceToNextPlatform;
  final probGen = ProbabilityGenerator();
  final double _tallestPlatformHeight = 50;
  final List<Platform> _platforms = [];
  final List<EnemyPlatform> _enemies = [];
  final List<PowerUp> _powerUps = [];

  @override
  void onMount() {
    super.onMount();
    var currentX = (gameRef.size.x.floor() / 2).toDouble() - 50;
    var currentY = gameRef.size.y - (_rand.nextInt(gameRef.size.y.floor()) / 3) - 50;

    //insert a list of platform on the screen
    for (var i = 0; i < 9; i++) {
      if (i != 0) {
        currentX = _generateNextX(100);
        currentY = _generateNextY();
      }
      _platforms.add(
        _semiRandomPlatform(
          Vector2(
            currentX,
            currentY,
          ),
        ),
      );
      add(_platforms[i]);
    }
  }

  @override
  void update(double dt) {
    final topOfLowestPlatform =
        _platforms.first.position.y + _tallestPlatformHeight;

    final screenBottom = gameRef.player.position.y +
        (gameRef.size.x / 2) +
        gameRef.screenBufferSpace;

    //when platform come outside the screen
    if (topOfLowestPlatform > screenBottom) {
      final nextPlat = _semiRandomPlatform(Vector2(_generateNextX(100), _generateNextY()));
      add(nextPlat);

      _platforms.add(nextPlat);
      gameRef.gameManager.increaseScore();

      _cleanupPlatforms();
      _maybeAddEnemy();
      _maybeAddPowerUp();
    }
    super.update(dt);
  }

  //functions for each levels
  final Map<String, bool> specialPlatforms = {
    'spring': true, // level 1
    'broken': false, // level 2
    'noogler': false, // level 3
    'rocket': false, // level 4
    'enemy': false, // level 5
  };

  void _cleanupPlatforms() {
    final platform = _platforms.removeAt(0);
    platform.removeFromParent();
  }

  void removePlatform(Platform platform){
    _platforms.remove(platform);
    platform.removeFromParent();
  }

  void enableSpecialty(String specialty) {
    specialPlatforms[specialty] = true;
  }

  void enableLevelSpecialty(int level) {
    //enable functions for each levels
    switch(level){
      case 1:
        enableSpecialty('spring');
        break;
      case 2:
        enableSpecialty('broken');
        break;
      case 3:
        enableSpecialty('noogler');
        break;
      case 4:
        enableSpecialty('rocket');
        break;
      case 5:
        enableSpecialty('enemy');
        break;
    }
  }

  void resetSpecialties() {
    for (var key in specialPlatforms.keys) {
      specialPlatforms[key] = false;
    }
  }

  // Exposes a way for the DoodleDash component to change difficulty mid-game
  void configure(int nextLevel, Difficulty config) {
    minVerticalDistanceToNextPlatform = gameRef.levelManager.minDistance;
    maxVerticalDistanceToNextPlatform = gameRef.levelManager.maxDistance;

    for (int i = 1; i <= nextLevel; i++) {
      enableLevelSpecialty(i);
    }
  }

  double _generateNextX(int platformWidth) {
    final previousPlatformXRange = Range(
      _platforms.last.position.x,
      _platforms.last.position.x + platformWidth,
    );

    double nextPlatformAnchorX;

    do {
      nextPlatformAnchorX =
          _rand.nextInt(gameRef.size.x.floor() - platformWidth).toDouble();
    } while (previousPlatformXRange.overlaps(
        Range(nextPlatformAnchorX, nextPlatformAnchorX + platformWidth)));

    return nextPlatformAnchorX;
  }

  double _generateNextY() {
    final currentHighestPlatformY =
        _platforms.last.center.y + _tallestPlatformHeight;

    final distanceToNextY = minVerticalDistanceToNextPlatform.toInt() +
        _rand
            .nextInt((maxVerticalDistanceToNextPlatform -
            minVerticalDistanceToNextPlatform)
            .floor())
            .toDouble();

    return currentHighestPlatformY - distanceToNextY;
  }

  Platform _semiRandomPlatform(Vector2 position){
    //if function 'spring' enabled
    //Generate a SpringBoard with probabality of 15%
    if(specialPlatforms['spring'] == true
        && probGen.generateWithProbability(15)){
      return SpringBoardPlatform(position: position);
    }
    //if function 'broken' enabled
    //Generate a SpringVoard with probabality of 10%
    if(specialPlatforms['broken'] == true
       && probGen.generateWithProbability(10)){
      return BrokenPlatform(position: position);
    }
    return NormalPlatform(position: position);
  }

  void _maybeAddEnemy(){
    if(specialPlatforms['enemy'] != true){
      return;
    }
    if(probGen.generateWithProbability(20)){
      var enemy = EnemyPlatform(position: Vector2(_generateNextX(100), _generateNextY()));
      add(enemy);
      _enemies.add(enemy);
      _cleanupEnemies();
    }
  }

  void _cleanupEnemies() {
    /*while (_enemies.isNotEmpty && _enemies.first.position.y > _screenBottom()) {
      remove(_enemies.first);
      _enemies.removeAt(0);
    }*/
    _cleanUpElement(_enemies);
  }

  void _maybeAddPowerUp(){
    if(specialPlatforms['noogler'] == true &&
      probGen.generateWithProbability(20)
    ){
      var nooglerHat = NooglerHat(
        position: Vector2(_generateNextX(75), _generateNextY()),
      );
      add(nooglerHat);
      _powerUps.add(nooglerHat);
    }else if(specialPlatforms['rockets'] == true &&
      probGen.generateWithProbability(15)
    ){
      var rocket = Rocket(
        position: Vector2(_generateNextX(50), _generateNextY()),
      );
      add(rocket);
      _powerUps.add(rocket);
    }
    _cleanUpPowerUps();
  }

  void _cleanUpPowerUps(){
    while (_powerUps.isNotEmpty && _powerUps.first.position.y > _screenBottom()) {
      if(_powerUps.first.parent != null){
        remove(_powerUps.first);
      }
      _powerUps.removeAt(0);
    }
  }

  void _cleanUpElement(List<dynamic> elements){
    while (elements.isNotEmpty && elements.first.position.y > _screenBottom()) {
      remove(elements.first);
      elements.removeAt(0);
    }
  }

  double _screenBottom(){
    return gameRef.player.position.y +
        (gameRef.size.x / 2) +
        gameRef.screenBufferSpace;
  }
}
