import 'dart:ui';

import 'package:appstore_item/app_model.dart';
import 'package:appstore_item/swipe_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppStoreItem extends StatefulWidget {
  static const TAG = "AppStoreItem";
  final AppModel appModel;
  final bool expanded;
  final Function(BuildContext) onTap;

  const AppStoreItem({
    Key key,
    this.appModel,
    this.onTap,
    this.expanded = false,
  }) : super(key: key);

  @override
  _AppStoreItemState createState() => _AppStoreItemState();
}

class _AppStoreItemState extends State<AppStoreItem>
    with TickerProviderStateMixin {

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
        ]),
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

  @override
  void dispose() {
    super.dispose();
  }
}