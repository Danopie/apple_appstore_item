import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lorem/flutter_lorem.dart';
import 'package:flutter_statusbar_manager/flutter_statusbar_manager.dart';
import 'package:google_fonts/google_fonts.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          primarySwatch: Colors.blue,
          brightness: Brightness.dark,
          textTheme: Theme.of(context)
              .textTheme
              .apply(fontFamily: GoogleFonts.lato().fontFamily)),
      home: MyHome(),
    );
  }
}

class MyHome extends StatefulWidget {
  @override
  _MyHomeState createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: AppList(),
      ),
    );
  }
}

class AppList extends StatefulWidget {
  @override
  _AppListState createState() => _AppListState();
}

class _AppListState extends State<AppList> {
  final appModels = List<AppModel>.generate(
      10,
      (index) => AppModel(
          "NEW ON APPLE ARCADE",
          "Ultimate Rivals:\nThe Rink",
          "https://nxl.nxfs.nexon.com/media/2383/vn_home_bg.jpg",
          lorem(paragraphs: 8, words: 200),
          "Dive into the vast world of Thoros",
          index.toString()));

  final _borderTween = Tween<double>(begin: 14, end: 0);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) {
        final appModel = appModels[index];
        return Container(
          margin: EdgeInsets.all(20),
          child: Hero(
            tag: "AppModel${appModel.id}",
            createRectTween: (begin, end) {
              return SrcRectTween(a: begin, b: end);
            },
            flightShuttleBuilder: (flightContext, anim, flightDirection,
                fromHeroContext, toHeroContext) {
              Hero hero;
              if (flightDirection == HeroFlightDirection.pop) {
                hero = fromHeroContext.widget;
              } else {
                hero = toHeroContext.widget;
              }

              return AnimatedBuilder(
                child: hero.child,
                builder: (context, widget) {
                  return ClipRRect(
                    borderRadius:
                        BorderRadius.circular(_borderTween.evaluate(anim)),
                    child: widget,
                  );
                },
                animation: anim,
              );
            },
            child: AppStoreItem(
              appModel: appModel,
              onTap: (context) {
                Navigator.of(context).push(PageRouteBuilder(
                    pageBuilder: (_, anim, secondAnim) {
                      return FadeTransition(
                        opacity: CurvedAnimation(
                          curve: Curves.easeInOut,
                          parent: anim,
                        ),
                        child: AppListingPage(
                          appModel: appModel,
                        ),
                      );
                    },
                    transitionDuration: Duration(milliseconds: 700),
                    opaque: false));
              },
            ),
          ),
        );
      },
      itemCount: appModels.length,
    );
  }
}

class SrcRectTween extends RectTween {
  SrcRectTween({this.a, this.b}) : super(begin: a, end: b);
  final Rect a;
  final Rect b;

  @override
  Rect lerp(double t) {
    final verticalCurve = Cubic(.49, -0.3, .96, 1.9);
    final rect = Rect.fromLTRB(
      _transformWithCurve(a.left, b.left, t, verticalCurve),
      _transformWithCurve(a.top, b.top, t, Curves.easeInOutBack),
      _transformWithCurve(a.right, b.right, t, verticalCurve),
      _transformWithCurve(a.bottom, b.bottom, t, Curves.linear),
    );
    return rect;
  }

  double _transformWithCurve(num a, num b, double t, Curve curve) {
    final curveValue = curve.transform(t);

    final tween = Tween<num>(begin: a, end: b);
    return tween.lerp(curveValue);
  }
}

class DestRectTween extends RectTween {
  DestRectTween({this.a, this.b}) : super(begin: a, end: b);
  final Rect a;
  final Rect b;

  @override
  Rect lerp(double t) {
    final verticalCurve = Cubic(.19, .18, .33, 1.72);
    final horizontalCurve = Cubic(.19, .18, .59, 1.32);
    return Rect.fromLTRB(
      _transformWithCurve(a.left, b.left, t, horizontalCurve),
      _transformWithCurve(a.top, b.top, t, verticalCurve),
      _transformWithCurve(a.right, b.right, t, horizontalCurve),
      _transformWithCurve(a.bottom, b.bottom, t, verticalCurve),
    );
  }

  double _transformWithCurve(num a, num b, double t, Curve curve) {
    final curveValue = curve.transform(t);

    final tween = Tween<num>(begin: a, end: b);
    return tween.lerp(curveValue);
  }
}

class AppStoreItem extends StatefulWidget {
  static const TAG = "AppStoreItem";
  final AppModel appModel;
  final bool expanded;
  final Function(BuildContext) onTap;
  final Function onClose;
  final SwipeController swipeController;

  const AppStoreItem({
    Key key,
    this.appModel,
    this.onTap,
    this.expanded = false,
    this.onClose,
    this.swipeController,
  }) : super(key: key);

  @override
  _AppStoreItemState createState() => _AppStoreItemState();
}

class _AppStoreItemState extends State<AppStoreItem>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return _buildChild();
  }

  Widget _buildChild() {
    return ClipRRect(
      borderRadius:
          widget.expanded ? BorderRadius.zero : BorderRadius.circular(14),
      child: Material(
        color: Colors.grey[700],
        child: Stack(children: <Widget>[
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              GestureDetector(
                child: _buildTopItem(),
                onTap: widget.onTap != null
                    ? () {
                        widget.onTap(context);
                      }
                    : null,
              ),
              if (widget.expanded) Flexible(child: _buildBottomItem())
            ],
          ),
          if (widget.swipeController != null)
            AnimatedBuilder(
              animation: widget.swipeController,
              child: _buildCloseButton(),
              builder: (context, child) {
                double opacity = widget.swipeController.distance /
                    widget.swipeController.maxSwipeDistance;
                if (opacity > 1)
                  opacity = 1;
                else if (opacity < 0) opacity = 0;

                return Opacity(
                  opacity: 1 - opacity,
                  child: child,
                );
              },
            )
        ]),
      ),
    );
  }

  Widget _buildCloseButton() {
    return Align(
      alignment: Alignment.topRight,
      child: Container(
        margin: EdgeInsets.only(right: 20, top: 25),
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () async {
            if (widget.expanded) {
              if (widget.onClose != null) {
                await widget.onClose();
              }
              Navigator.of(context).pop();
            }
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
    );
  }

  Widget _buildTopItem() {
    return AspectRatio(
      aspectRatio: 4 / 5,
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Image.network(
              widget.appModel.image,
              fit: BoxFit.cover,
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              margin: EdgeInsets.only(left: 20, top: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    widget.appModel.title,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.grey[200].withOpacity(0.6)),
                  ),
                  Container(
                    height: 6,
                  ),
                  Text(
                    widget.appModel.header,
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 24,
                        color: Colors.grey[200]),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              margin: EdgeInsets.only(left: 20, bottom: 20),
              child: Text(
                widget.appModel.bottomHeader,
                style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 14,
                    color: Colors.grey[200]),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBottomItem() {
    return Container(
      height: widget.expanded ? null : 0,
      padding: EdgeInsets.all(20),
      child: Text(
        widget.appModel.description,
        overflow: TextOverflow.fade,
        style: TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 14,
            color: Colors.grey[200]),
      ),
    );
  }
}

class AppListingPage extends StatefulWidget {
  final AppModel appModel;

  const AppListingPage({Key key, this.appModel}) : super(key: key);

  @override
  _AppListingPageState createState() => _AppListingPageState();
}

class _AppListingPageState extends State<AppListingPage> {
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
        onUserSwipe: () {
          Navigator.of(context).pop();
        },
        child: SingleChildScrollView(
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
              swipeController: _swipeController,
              onClose: () async {
                await FlutterStatusbarManager.setHidden(false,
                    animation: StatusBarAnimation.SLIDE);
              },
            ),
          ),
        ),
      ),
    );
  }
}

class BouncingButton extends StatefulWidget {
  final Widget child;
  final Function onTap;

  const BouncingButton({Key key, this.child, this.onTap}) : super(key: key);

  @override
  _BouncingButtonState createState() => _BouncingButtonState();
}

class _BouncingButtonState extends State<BouncingButton>
    with SingleTickerProviderStateMixin {
  final scaleTween = Tween<double>(begin: 1.0, end: 0.95);
  AnimationController _controller;

  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 100));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) {
        _controller.forward();
      },
      onTapUp: (details) {
        _controller.reverse();
      },
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: scaleTween.animate(
            CurvedAnimation(curve: Curves.easeIn, parent: _controller)),
        child: widget.child,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class SwipeController extends ChangeNotifier {
  final maxSwipeDistance = 30.0;
  final edgeOffset = 50;

  double _distance = 0;

  set distance(double distance) {
    _distance = distance;
    notifyListeners();
  }

  double get distance => _distance;
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
            _swipeController.distance = noti.metrics.pixels;
            if (_swipeController.distance < 0) {
              if (_swipeController.distance <=
                  -_swipeController.maxSwipeDistance) {
                _handleUserSwipeCall();
              } else {
                final positiveDistance = -noti.metrics.pixels;
                _animationController.value =
                    positiveDistance / _swipeController.maxSwipeDistance;
              }
            }

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
      if (positiveDistance <= _swipeController.maxSwipeDistance) {
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

class AppModel {
  final String title;
  final String header;
  final String image;
  final String bottomHeader;
  final String description;
  final String id;

  AppModel(this.title, this.header, this.image, this.description,
      this.bottomHeader, this.id);
}
