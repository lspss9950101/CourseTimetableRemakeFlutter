import 'dart:ui';

import 'package:course_timetable_remake/Resources.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'Course.dart';
import 'MessageSnackBar.dart';
import 'Session.dart';
import 'generated/l10n.dart';

class Timetable extends StatefulWidget {
  final List<Course> courses;
  final List<Session> sessions;
  final CourseLayout courseLayout;

  Timetable(
      {this.courses = const [],
      this.sessions = const [],
      this.courseLayout = const CourseLayout.light(),
      Key key})
      : super(key: key);

  @override
  State createState() => _TimetableState();
}

class _TimetableState extends State<Timetable> with TickerProviderStateMixin {
  bool editMode = false;
  GlobalKey _sessionKey = GlobalKey();
  AnimationController _animationController;
  double _sessionWidth = 40;
  double _barHeight = 35;
  List<bool> chosen;
  Course copiedCourse;

  void setEditMode(bool val) {
    if (val == editMode) return;
    copiedCourse = null;
    if (val) {
      _animationController.forward();
      HapticFeedback.vibrate();
    } else
      _animationController.reverse();
    editMode = val;
  }

  Widget getSessionCell(Session session, bool asConstraint) {
    return Container(
      key: asConstraint ? _sessionKey : null,
      color: widget.courseLayout.primaryColor,
      child: Padding(
        padding: EdgeInsets.all(4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              session.name,
              softWrap: false,
              overflow: TextOverflow.fade,
              style: Theme.of(context)
                  .textTheme
                  .bodyText2
                  .apply(color: widget.courseLayout.secondaryColor),
            ),
            Text(
              DateFormat('kk:mm').format(session.begin),
              style: Theme.of(context)
                  .textTheme
                  .caption
                  .apply(color: widget.courseLayout.secondaryColor),
            ),
            RotatedBox(
              quarterTurns: 1,
              child: Text(
                '~',
                style: Theme.of(context)
                    .textTheme
                    .caption
                    .apply(color: widget.courseLayout.secondaryColor),
              ),
            ),
            Text(
              DateFormat('kk:mm').format(session.end),
              style: Theme.of(context)
                  .textTheme
                  .caption
                  .apply(color: widget.courseLayout.secondaryColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget getCourseCell(Course course, int index) {
    Widget bodyNormal = Expanded(
      child: GestureDetector(
        onLongPress: editMode
            ? null
            : () {
          setState(() {
            chosen[index] = true;
            setEditMode(true);
          });
        },
        onTap: editMode
            ? () {
          setState(() {
            chosen[index] = !chosen[index];
            if (chosen.every((element) => !element)) setEditMode(false);
          });
        }
            : null,
        child: Stack(
          children: [
            Transform(
              transform: Matrix4.identity()..translate(0.1),
              child: Container(
                color: chosen[index]
                    ? Colors.transparent
                    : widget.courseLayout.primaryColor,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: chosen[index]
                    ? Colors.transparent
                    : widget.courseLayout.primaryColor,
                border: Border(
                  left: BorderSide(
                    color: widget.courseLayout.primaryColor,
                    width: 4,
                  ),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(4, 12, 4, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      course.name,
                      softWrap: false,
                      style: Theme.of(context).textTheme.caption.apply(
                          color: chosen[index]
                              ? widget.courseLayout.primaryColor
                              : widget.courseLayout.secondaryColor),
                      overflow: TextOverflow.fade,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: course.color,
                        borderRadius: BorderRadius.all(
                          Radius.circular(5),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(5, 2, 5, 2),
                        child: Text(
                          course.room,
                          softWrap: false,
                          style: Theme.of(context)
                              .textTheme
                              .caption
                              .apply(color: Colors.white),
                          overflow: TextOverflow.fade,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
    Widget body = GestureDetector(
      onLongPress: editMode
          ? null
          : () {
        setState(() {
          chosen[index] = true;
          setEditMode(true);
        });
      },
      onTap: editMode
          ? () {
        setState(() {
          chosen[index] = !chosen[index];
          if (chosen.every((element) => !element)) setEditMode(false);
        });
      }
          : null,
      child: Stack(
        children: [
          Transform(
            transform: Matrix4.identity()..translate(0.1),
            child: Container(
              color: chosen[index]
                  ? Colors.transparent
                  : widget.courseLayout.primaryColor,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: chosen[index]
                  ? Colors.transparent
                  : widget.courseLayout.primaryColor,
              border: Border(
                left: BorderSide(
                  color: widget.courseLayout.primaryColor,
                  width: 4,
                ),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(4, 12, 4, 12),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    course.name,
                    softWrap: false,
                    style: Theme.of(context).textTheme.caption.apply(
                        color: chosen[index]
                            ? widget.courseLayout.primaryColor
                            : widget.courseLayout.secondaryColor),
                    overflow: TextOverflow.fade,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: course.color,
                      borderRadius: BorderRadius.all(
                        Radius.circular(5),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(5, 2, 5, 2),
                      child: Text(
                        course.room,
                        softWrap: false,
                        style: Theme.of(context)
                            .textTheme
                            .caption
                            .apply(color: Colors.white),
                        overflow: TextOverflow.fade,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
    Widget bodyFeedback = Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: chosen[index]
                ? widget.courseLayout.secondaryColor
                : widget.courseLayout.primaryColor,
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(4, 12, 4, 12),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  course.name,
                  softWrap: false,
                  style: Theme.of(context).textTheme.caption.apply(
                      color: chosen[index]
                          ? widget.courseLayout.primaryColor
                          : widget.courseLayout.secondaryColor),
                  overflow: TextOverflow.fade,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: course.color,
                    borderRadius: BorderRadius.all(
                      Radius.circular(5),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(5, 2, 5, 2),
                    child: Text(
                      course.room,
                      softWrap: false,
                      style: Theme.of(context)
                          .textTheme
                          .caption
                          .apply(color: Colors.white),
                      overflow: TextOverflow.fade,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    return editMode ? Expanded(child: LongPressDraggable(
      child: body,
      feedback: bodyFeedback,),
    ) : bodyNormal;
  }

  Widget getRow(
      Session session, int sessionIndex, bool isLast, List<Course> courses) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 0, 0, isLast ? 0 : 2.5),
      child: Container(
        child: IntrinsicHeight(
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              getSessionCell(session, sessionIndex == 0),
              ...courses.asMap().entries.map(
                (e) {
                  int rowIndex = e.key;
                  Course course = e.value;
                  int courseIndex = sessionIndex * 7 + rowIndex;
                  return getCourseCell(course, courseIndex);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getMainBody() {
    return Stack(
      children: [
        Container(
          color: widget.courseLayout.primaryColor,
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(0.5, 0.99),
              end: Alignment(0.5, 1),
              colors: [
                widget.courseLayout.secondaryColor,
                widget.courseLayout.primaryColor
              ],
            ),
          ),
          child: ScrollConfiguration(
            behavior: _TimetableListViewBehaviour(),
            child: ListView(
              shrinkWrap: true,
              children: [
                ...widget.sessions.asMap().entries.map((e) {
                  int index = e.key;
                  Session session = e.value;
                  return getRow(
                    session,
                    index,
                    index == widget.sessions.length - 1,
                    widget.courses.sublist(7 * index, 7 * index + 7),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    chosen = List.filled(widget.courses.length, false);
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
      reverseDuration: Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
  }

  @override
  void didUpdateWidget(Timetable oldWidget) {
    super.didUpdateWidget(oldWidget);
    RenderBox renderBox = _sessionKey.currentContext?.findRenderObject();
    double width = renderBox?.size?.width;
    if (width != null && _sessionWidth != width)
      setState(() {
        _sessionWidth = width;
      });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: editMode
          ? () async {
              setState(() {
                chosen.fillRange(0, chosen.length, false);
                setEditMode(false);
              });
              return false;
            }
          : null,
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(0, _barHeight, 0, 0),
            child: getMainBody(),
          ),
          _WeekBar(
            courseLayout: widget.courseLayout,
            blankWidth: _sessionWidth,
            height: _barHeight,
          ),
          _EditToolBar(
            animationController: _animationController,
            courseLayout: widget.courseLayout,
            height: _barHeight,
            chosenCount: chosen.where((element) => element).toList().length,
            hasCopied: copiedCourse != null,
            callback: (EditToolType editToolType) {
              setState(() {
              switch(editToolType) {
                case EditToolType.ADD:
                  break;
                case EditToolType.COPY:
                  int chosenCount = chosen.where((element) => element).toList().length;
                  if(chosenCount < 1) MessageSnackBar.showSnackBar(context, "Please choose one course.", widget.courseLayout, duration: Duration(milliseconds: 750),);
                  else if(chosenCount > 1) MessageSnackBar.showSnackBar(context, "Please choose exactly one course.", widget.courseLayout, duration: Duration(milliseconds: 750),);
                  else copiedCourse = widget.courses[chosen.indexOf(true)];
                  break;
                case EditToolType.PASTE:
                  break;
                case EditToolType.DELETE:
                  break;
                case EditToolType.DELETE_ALL:
                  break;
              }
              });
            },
          ),
        ],
      ),
    );
  }
}

class _TimetableListViewBehaviour extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

class _WeekBar extends StatelessWidget {
  final CourseLayout courseLayout;
  final double blankWidth;
  final double height;
  _WeekBar(
      {this.courseLayout = const CourseLayout.light(),
      this.blankWidth,
      this.height,
      Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<String> week = S.of(context).weekDays.split(',');
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        decoration: BoxDecoration(
          color: courseLayout.primaryColor,
          boxShadow: [
            BoxShadow(
              color: Color.fromARGB(100, 10, 10, 10),
              offset: Offset(0.0, 1.0),
              blurRadius: 3,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              width: blankWidth,
              height: height,
            ),
            for (String day in week)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(4, 8, 0, 4),
                  child: Text(
                    day,
                    style: Theme.of(context).textTheme.caption.apply(
                          color: courseLayout.secondaryColor,
                        ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

enum EditToolType {
  ADD,
  COPY,
  PASTE,
  DELETE,
  DELETE_ALL,
}

class _EditToolBar extends StatefulWidget {
  final CourseLayout courseLayout;
  final double height;
  final bool hasCopied;
  final int chosenCount;
  final AnimationController animationController;
  final void Function(EditToolType) callback;
  _EditToolBar(
      {this.hasCopied,
      this.chosenCount,
      this.courseLayout,
        this.callback,
      this.height,
      this.animationController,
      Key key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _EditToolBarState();
}

class _EditToolBarState extends State<_EditToolBar> {
  Animation _animation;

  Widget getOperationButton(
          IconData icon, String tooltip, EditToolType editToolType) =>
      Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          child: IconButton(
            icon: Icon(
              icon,
              color: widget.courseLayout.secondaryColor,
            ),
            tooltip: tooltip,
            onPressed: () {
              widget.callback(editToolType);
            },
          ),
        ),
      );

  List<Widget> getOperationButtons() {
    List<Widget> result = [
      getOperationButton(
          Icons.edit,
          widget.chosenCount > 1
              ? S.of(context).mainPageDrawerAddEdit
              : S.of(context).mainPageDrawerAddEditSingle,
          EditToolType.ADD,),
      getOperationButton(
          Icons.content_copy, S.of(context).mainPageDrawerCopy, EditToolType.COPY,),
      getOperationButton(
          Icons.content_paste,
          widget.chosenCount > 1
              ? S.of(context).mainPageDrawerPaste
              : S.of(context).mainPageDrawerPasteSingle,
          EditToolType.PASTE,),
      getOperationButton(
          Icons.delete,
          widget.chosenCount > 1
              ? S.of(context).mainPageDrawerDelete
              : S.of(context).mainPageDrawerDeleteSingle,
          EditToolType.DELETE,),
      getOperationButton(
          Icons.delete_forever, S.of(context).mainPageDrawerDeleteAll, EditToolType.DELETE_ALL),
    ];

    if (!widget.hasCopied) result.removeAt(2);
    return result;
  }

  @override
  void initState() {
    super.initState();
    _animation = Tween<double>(begin: -widget.height, end: 0)
        .chain(CurveTween(curve: Curves.fastOutSlowIn))
        .animate(widget.animationController)
          ..addListener(() {
            setState(() {});
          });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: _animation.value,
      left: 0,
      right: 0,
      child: Container(
        height: widget.height,
        decoration: BoxDecoration(
          color: widget.courseLayout.primaryColor,
          boxShadow: [
            BoxShadow(
              color: Color.fromARGB(100, 10, 10, 10),
              offset: Offset(0.0, 1.0),
              blurRadius: 3,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: getOperationButtons(),
        ),
      ),
    );
  }
}
