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

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) {
        final appModel = appModels[index];
        return Container(
          margin: EdgeInsets.all(20),
          child: Hero(
            tag: "AppModel${appModel.id}",
//            flightShuttleBuilder: (flightContext, anim, direction,
//                fromHeroContext, toHeroContext) {
//              return Container(
//                color: Colors.red,
//              );
//            },
            createRectTween: (begin, end) {
//              print('_AppListingPageState.build 1');
//              print('_AppListState.build: $begin $end');
              return SrcRectTween(a: begin, b: end);
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
                    transitionDuration: Duration(milliseconds: 600),
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

  const AppStoreItem(
      {Key key, this.appModel, this.onTap, this.expanded = false, this.onClose})
      : super(key: key);

  @override
  _AppStoreItemState createState() => _AppStoreItemState();
}

class _AppStoreItemState extends State<AppStoreItem>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: _buildChild(),
      physics: widget.expanded
          ? ClampingScrollPhysics()
          : NeverScrollableScrollPhysics(),
    );
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
              _buildBottomItem()
            ],
          ),
          AnimatedPositioned(
            duration: Duration(milliseconds: 300),
            right: widget.expanded ? 20 : 40,
            top: widget.expanded ? 14 : 40,
            child: AnimatedOpacity(
              duration: Duration(milliseconds: 300),
              opacity: widget.expanded ? 1.0 : 0,
              child: _buildCloseButton(),
            ),
          )
        ]),
      ),
    );
  }

  Widget _buildCloseButton() {
    return GestureDetector(
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
  @override
  void initState() {
    FlutterStatusbarManager.setHidden(true,
        animation: StatusBarAnimation.SLIDE);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
          backgroundColor: Colors.transparent,
          body: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: SwipeHandler(
                onUserSwipe: () {
                  Navigator.of(context).pop();
                },
                child: SingleChildScrollView(
                  physics: ClampingScrollPhysics(),
                  child: Hero(
                    createRectTween: (begin, end) {
                      return DestRectTween(a: begin, b: end);
                    },
                    tag: "AppModel${widget.appModel.id}",
                    child: AppStoreItem(
                      appModel: widget.appModel,
                      expanded: true,
                      onClose: () async {
                        await FlutterStatusbarManager.setHidden(false,
                            animation: StatusBarAnimation.SLIDE);
                      },
                    ),
                  ),
                ),
              ),
            ),
          )),
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

class SwipeHandler extends StatefulWidget {
  final Function onUserSwipe;
  final Widget child;

  const SwipeHandler({Key key, this.onUserSwipe, this.child}) : super(key: key);

  @override
  _SwipeHandlerState createState() => _SwipeHandlerState();
}

class _SwipeHandlerState extends State<SwipeHandler>
    with SingleTickerProviderStateMixin {
  static const kMaxDistance = 30;
  static const kEdgeOffset = 50;
  final scaleTween = Tween<double>(begin: 1.0, end: .85);
  final radiusTween = Tween<double>(begin: 0, end: 16);

  double distance = 0;

  AnimationController controller;
  bool gestureIsFromEdge = false;

  @override
  void initState() {
    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    controller.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Transform.scale(
        child: ClipRRect(
          child: widget.child,
          borderRadius: BorderRadius.circular(radiusTween.evaluate(controller)),
        ),
        scale: scaleTween.evaluate(
            CurvedAnimation(curve: Curves.easeIn, parent: controller)),
      ),
      onHorizontalDragStart: (details) {
        gestureIsFromEdge = _isGestureFromEdge(
            context, details.globalPosition.dx, Axis.horizontal);
        distance = 0;
      },
      onVerticalDragStart: (details) {
        gestureIsFromEdge = _isGestureFromEdge(
            context, details.globalPosition.dy, Axis.vertical);
        distance = 0;
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
    );
  }

  bool _isGestureFromEdge(BuildContext context, double position, Axis axis) {
    final screenSize = MediaQuery.of(context).size;
    final length =
        axis == Axis.horizontal ? screenSize.width : screenSize.height;
    return position < kEdgeOffset || position > length - kEdgeOffset;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (gestureIsFromEdge) {
      final positiveDistance = distance > 0 ? distance : -distance;
      if (positiveDistance <= kMaxDistance) {
        distance += details.primaryDelta;
        final positiveDistance = distance > 0 ? distance : -distance;
        controller.value = positiveDistance / kMaxDistance;
      } else {
        widget.onUserSwipe();
      }
    }
  }

  void _reset() {
    distance = 0;
    controller.reverse();
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
