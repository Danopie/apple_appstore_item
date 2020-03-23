import 'dart:ui';

import 'package:appstore_item/app_details_page.dart';
import 'package:appstore_item/app_model.dart';
import 'package:appstore_item/app_store_item.dart';
import 'package:appstore_item/swipe_view.dart';
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
                        child: AppDetailsPage(
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



