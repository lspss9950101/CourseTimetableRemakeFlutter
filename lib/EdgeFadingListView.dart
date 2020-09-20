import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EdgeFadingListView extends StatefulWidget {
  final List<Widget> children;
  final bool enabled;
  EdgeFadingListView({Key key, this.children, this.enabled = true}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _EdgeFadingListViewState();
}

class _EdgeFadingListViewState extends State<EdgeFadingListView> {
  double stopPointBegin = 0.0;
  double stopPointEnd = 0.9;
  ScrollController _scrollController;

  void updateFading() {
    if(!widget.enabled) {
      stopPointBegin = 0;
      stopPointEnd = 1;
      return;
    }
    double progress = _scrollController.position.pixels / _scrollController.position.maxScrollExtent;
    if (progress.isNaN) progress = 0;
    stopPointBegin = progress <= 0.1 ? progress : 0.1;
    stopPointEnd = progress >= 0.9 ? progress : 0.9;
  }

  @override
  void initState() {
    super.initState();
    _scrollController = new ScrollController(initialScrollOffset: 0);
    _scrollController.addListener(() {
      setState(() {
        updateFading();
      });
    });
  }

  @override
  void didUpdateWidget(EdgeFadingListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    updateFading();
  }

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (bounds) => LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, stopPointBegin, stopPointEnd, 1.0],
          colors: [Colors.transparent, Colors.white, Colors.white, Colors.transparent]).createShader(bounds),
      child: ScrollConfiguration(
        behavior: _EdgeFadingListViewBehaviour(),
        child: Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: widget.children,
            ),
          ),
        ),
      ),
    );
  }
}

class _EdgeFadingListViewBehaviour extends ScrollBehavior {
  @override
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
