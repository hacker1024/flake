import 'dart:async';
import 'dart:math';

import 'package:flake/widgets/snake_game_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:snake/snake.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flake',
      home: SnakeScreen(),
    );
  }
}

class SnakeScreen extends StatelessWidget {
  const SnakeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SnakeGameWidget(),
    );
  }
}

class SnakeGameWidget extends StatefulWidget {
  const SnakeGameWidget({Key? key}) : super(key: key);

  @override
  _SnakeGameWidgetState createState() => _SnakeGameWidgetState();
}

class _SnakeGameWidgetState extends State<SnakeGameWidget> {
  late SnakeGame _snakeGame;
  late Timer _clock;
  late List<List<SnakeItem>> _board;
  var _material = false;

  void _retrieveBoard() => _board = _snakeGame.getBoardWithSnake();

  void _render() {
    if (!mounted) return;
    setState(_retrieveBoard);
  }

  @override
  void initState() {
    super.initState();
    _start();
  }

  void _start() {
    const boardSize = 12;
    final random = Random();
    int randomXOrY() => boardSize ~/ 2; // TODO fix random generation
    _snakeGame = SnakeGame(
      renderer: _render,
      boardWidth: boardSize,
      boardHeight: boardSize,
      initialSnakeX: randomXOrY(),
      initialSnakeY: randomXOrY(),
      initialSnakeDirection:
          SnakeDirection.values[random.nextInt(SnakeDirection.values.length)],
      initialSnakeSize: 3,
      maxTicksBeforeFood: 40,
      minTicksBeforeFood: 5,
    );
    _clock = Timer.periodic(const Duration(milliseconds: 250), (clock) {
      if (_snakeGame.completed) {
        clock.cancel();
        _reset();
      } else {
        _snakeGame.tick();
      }
    });
    _retrieveBoard();
  }

  void _reset() {
    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      _start();
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    _clock.cancel();
  }

  Widget _buildMaterialSwitch({
    required bool value,
    Color? activeColor,
  }) =>
      Switch(
        value: value,
        onChanged: (_) {},
        activeColor: activeColor,
      );

  Widget _buildCupertinoSwitch({
    required bool value,
    Color? activeColor,
  }) =>
      CupertinoSwitch(
        value: value,
        onChanged: (_) {},
        activeColor: activeColor,
      );

  @override
  Widget build(BuildContext context) {
    return SnakeGameController(
      onDirection: (SnakeDirection direction) {
        if (direction != _snakeGame.directionLastTick?.opposite) {
          _snakeGame.directionNextTick = direction;
        }
      },
      onToggleStyle: () => setState(() => _material = !_material),
      child: IgnorePointer(
        child: AspectRatio(
          aspectRatio: 1,
          child: Column(
            children: [
              for (final row in _board)
                Expanded(
                  child: Row(
                    children: [
                      for (final item in row)
                        Expanded(
                          child: (_material
                              ? _buildMaterialSwitch
                              : _buildCupertinoSwitch)(
                            value: item != SnakeItem.empty,
                            activeColor: item == SnakeItem.food
                                ? Colors.lightBlue
                                : null,
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
