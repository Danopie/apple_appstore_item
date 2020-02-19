import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SwipeController extends ChangeNotifier {
  final maxSwipeDistance = 38.0;
  final minSwipeDistance = 0.0;
  final edgeOffset = 50;

  double _distance = 0;

  set distance(double distance) {
    if(distance == null) return;
    if(distance >maxSwipeDistance){
      _distance = maxSwipeDistance;
    } else if(distance < -maxSwipeDistance){
      _distance = - maxSwipeDistance;
    } else {
      _distance = distance;
    }
    notifyListeners();
  }

  double get distance => _distance;

  double get distanceFraction => (_distance / maxSwipeDistance).abs();
}

enum SwipeStatus {
  Expanded,
  Shrunk
}

class SwipeView extends StatefulWidget {
  final SwipeController controller;
  final Function onUserSwipe;
  final Widget child;

  const SwipeView({Key key, this.onUserSwipe, this.child, this.controller})
      : super(key: key);

  @override
  _SwipeViewState createState() => _SwipeViewState();
}

class _SwipeViewState extends State<SwipeView>
    with SingleTickerProviderStateMixin {
  final scaleTween = Tween<double>(begin: 1.0, end: .85);
  final radiusTween = Tween<double>(begin: 0, end: 16);

  AnimationController _animationController;
  bool gestureIsFromEdge = false;
  bool userSwipeCalled = false;

  SwipeController _swipeController;

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _swipeController = widget.controller ?? SwipeController();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, widget) {
        return NotificationListener<ScrollUpdateNotification>(
          onNotification: (noti) {
            _handleSwipeFromScrollPosition(noti);

            return false;
          },
          child: GestureDetector(
            child: Transform.scale(
              child: Container(
                child: widget,
              ),
              scale: scaleTween.evaluate(CurvedAnimation(
                  curve: Curves.easeIn, parent: _animationController)),
            ),
            onHorizontalDragStart: (details) {
              gestureIsFromEdge = _isGestureFromEdge(
                  context, details.globalPosition.dx, Axis.horizontal);
              _swipeController.distance = 0;
            },
            onVerticalDragStart: (details) {
              gestureIsFromEdge = _isGestureFromEdge(
                  context, details.globalPosition.dy, Axis.vertical);
              _swipeController.distance = 0;
            },
            onHorizontalDragUpdate: (details) {
              _onDragUpdate(details);
            },
            onVerticalDragUpdate: (details) {
              _onDragUpdate(details);
            },
            onHorizontalDragEnd: (details) {
              _reset();
            },
            onHorizontalDragCancel: () {
              _reset();
            },
            onVerticalDragEnd: (details) {
              _reset();
            },
            onVerticalDragCancel: () {
              _reset();
            },
          ),
        );
      },
      child: widget.child,
    );
  }

  void _handleSwipeFromScrollPosition(ScrollUpdateNotification noti) {
    _swipeController.distance = noti.metrics.pixels;

    if (_swipeController.distance < _swipeController.minSwipeDistance) {
      if (_swipeController.distance <=
          -_swipeController.maxSwipeDistance) {
        _handleUserSwipeCall();
      } else {
        final positiveDistance = -noti.metrics.pixels;
        _animationController.value =
            positiveDistance / _swipeController.maxSwipeDistance;
      }
    }
  }

  void _handleUserSwipeCall() {
    if (!userSwipeCalled) {
      userSwipeCalled = true;
      widget.onUserSwipe();
    }
  }

  bool _isGestureFromEdge(BuildContext context, double position, Axis axis) {
    final screenSize = MediaQuery.of(context).size;
    final length =
    axis == Axis.horizontal ? screenSize.width : screenSize.height;
    return position < _swipeController.edgeOffset ||
        position > length - _swipeController.edgeOffset;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (gestureIsFromEdge) {
      final positiveDistance = _swipeController.distance > 0
          ? _swipeController.distance
          : -_swipeController.distance;
      if (positiveDistance < _swipeController.maxSwipeDistance) {
        _swipeController.distance += details.primaryDelta;
        final positiveDistance = _swipeController.distance > 0
            ? _swipeController.distance
            : -_swipeController.distance;
        _animationController.value =
            positiveDistance / _swipeController.maxSwipeDistance;
      } else {
        _handleUserSwipeCall();
      }
    }
  }

  void _reset() {
    _swipeController.distance = 0;
    _animationController.reverse();
    gestureIsFromEdge = false;
  }
}