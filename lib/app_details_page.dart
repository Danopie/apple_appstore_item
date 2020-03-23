import 'dart:ui';

import 'package:appstore_item/app_model.dart';
import 'package:appstore_item/app_store_item.dart';
import 'package:appstore_item/main.dart';
import 'package:appstore_item/swipe_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_statusbar_manager/flutter_statusbar_manager.dart';

class AppDetailsPage extends StatefulWidget {
  final AppModel appModel;

  const AppDetailsPage({Key key, this.appModel}) : super(key: key);

  @override
  _AppDetailsPageState createState() => _AppDetailsPageState();
}

class _AppDetailsPageState extends State<AppDetailsPage> {
  final _scrollController = ScrollController();
  final _swipeController = SwipeController();

  @override
  void initState() {
    FlutterStatusbarManager.setHidden(true,
        animation: StatusBarAnimation.SLIDE);
    _scrollController.addListener(() {
      if (_scrollController.offset < -_swipeController.maxSwipeDistance) {
        _scrollController.jumpTo(-_swipeController.maxSwipeDistance);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
      child: SwipeView(
        controller: _swipeController,
        onUserSwipe: () async {
          await FlutterStatusbarManager.setHidden(false,
              animation: StatusBarAnimation.SLIDE);
          Navigator.of(context).pop();
        },
        child: Stack(
          children: <Widget>[
            SingleChildScrollView(
              controller: _scrollController,
              physics: BouncingScrollPhysics(),
              child: Hero(
                createRectTween: (begin, end) {
                  return DestRectTween(a: begin, b: end);
                },
                tag: "AppModel${widget.appModel.id}",
                child: AppStoreItem(
                  appModel: widget.appModel,
                  expanded: true,
                ),
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              child: _buildCloseButton(context),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildCloseButton(BuildContext context) {
  return AnimatedBuilder(
    child: Align(
      alignment: Alignment.topRight,
      child: Container(
        margin: EdgeInsets.only(right: 20, top: 25),
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () async {
            await FlutterStatusbarManager.setHidden(false,
                animation: StatusBarAnimation.SLIDE);
            Navigator.of(context).pop();
          },
          child: Container(
            padding: EdgeInsets.all(12),
            child: Icon(
              Icons.cancel,
              color: Colors.grey[200],
              size: 36,
            ),
          ),
        ),
      ),
    ),
    animation: ModalRoute.of(context).animation,
    builder: (BuildContext context, Widget child) {
      return Opacity(
        child: child,
        opacity: ModalRoute.of(context).animation.value,
      );
    },
  );
}
