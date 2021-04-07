import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simple_gesture_detector/simple_gesture_detector.dart';
import 'package:snake/snake.dart';

class SnakeGameController extends StatefulWidget {
  final ValueSetter<SnakeDirection> onDirection;
  final VoidCallback onToggleStyle;
  final Widget child;

  const SnakeGameController({
    Key? key,
    required this.onDirection,
    required this.onToggleStyle,
    required this.child,
  }) : super(key: key);

  @override
  _SnakeGameControllerState createState() => _SnakeGameControllerState();
}

class _SnakeGameControllerState extends State<SnakeGameController> {
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _notifyDirection(SnakeDirection direction) =>
      widget.onDirection(direction);

  void _onKey(RawKeyEvent keyEvent) {
    if (keyEvent is! RawKeyDownEvent) return;
    final logicalKey = keyEvent.logicalKey;
    if (logicalKey == LogicalKeyboardKey.arrowUp) {
      _notifyDirection(SnakeDirection.up);
    } else if (logicalKey == LogicalKeyboardKey.arrowDown) {
      _notifyDirection(SnakeDirection.down);
    } else if (logicalKey == LogicalKeyboardKey.arrowLeft) {
      _notifyDirection(SnakeDirection.left);
    } else if (logicalKey == LogicalKeyboardKey.arrowRight) {
      _notifyDirection(SnakeDirection.right);
    }
  }

  void _onSwipe(SwipeDirection direction) {
    switch (direction) {
      case SwipeDirection.left:
        _notifyDirection(SnakeDirection.left);
        break;
      case SwipeDirection.right:
        _notifyDirection(SnakeDirection.right);
        break;
      case SwipeDirection.up:
        _notifyDirection(SnakeDirection.up);
        break;
      case SwipeDirection.down:
        _notifyDirection(SnakeDirection.down);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKey: _onKey,
      child: SimpleGestureDetector(
        behavior: HitTestBehavior.opaque,
        onDoubleTap: widget.onToggleStyle,
        swipeConfig: const SimpleSwipeConfig(
            swipeDetectionBehavior: SwipeDetectionBehavior.singular),
        onHorizontalSwipe: _onSwipe,
        onVerticalSwipe: _onSwipe,
        child: widget.child,
      ),
    );
  }
}
