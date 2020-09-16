import 'package:course_timetable_remake/Resources.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'Course.dart';
import 'Session.dart';

class Timetable extends StatefulWidget {
  final List<Course> courses;
  final List<Session> sessions;
  final List<bool> chosen;
  final CourseLayout courseLayout;

  Timetable({this.courses = const [], this.sessions = const [], this.chosen = const [], this.courseLayout = const CourseLayout.light(), Key key})
      : super(key: key);

  @override
  State createState() => _TimetableState();
}

class _TimetableState extends State<Timetable> {
  bool editMode = false;

  Widget getSessionCell(Session session) {
    return Container(
      color: widget.courseLayout.primaryColor,
      width: 40,
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
              style: Theme.of(context).textTheme.bodyText2.apply(color: widget.courseLayout.secondaryColor),
            ),
            Text(
              DateFormat('kk:mm').format(session.begin),
              style: Theme.of(context).textTheme.caption.apply(color: widget.courseLayout.secondaryColor),
            ),
            RotatedBox(
              quarterTurns: 1,
              child: Text(
                '~',
                style: Theme.of(context).textTheme.caption.apply(color: widget.courseLayout.secondaryColor),
              ),
            ),
            Text(
              DateFormat('kk:mm').format(session.end),
              style: Theme.of(context).textTheme.caption.apply(color: widget.courseLayout.secondaryColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget getCourseCell(Course course, int index) {
    return Expanded(
      child: GestureDetector(
        onLongPress: editMode
            ? null
            : () {
                setState(() {
                  widget.chosen[index] = true;
                  editMode = true;
                });
              },
        onTap: editMode
            ? () {
                setState(() {
                  widget.chosen[index] = !widget.chosen[index];
                });
              }
            : null,
        child: Stack(
          children: [
            Transform(
              transform: Matrix4.identity()..translate(0.1),
              child: Container(
                color: widget.chosen[index] ? Colors.transparent : widget.courseLayout.primaryColor,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: widget.chosen[index] ? Colors.transparent : widget.courseLayout.primaryColor,
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
                      style: Theme.of(context)
                          .textTheme
                          .caption
                          .apply(color: widget.chosen[index] ? widget.courseLayout.primaryColor : widget.courseLayout.secondaryColor),
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
                          style: Theme.of(context).textTheme.caption.apply(color: Colors.white),
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
  }

  Widget getRow(Session session, int sessionIndex, bool isLast, List<Course> courses) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 0, 0, isLast ? 0 : 2.5),
      child: Container(
        child: IntrinsicHeight(
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              getSessionCell(session),
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
              colors: [widget.courseLayout.secondaryColor, widget.courseLayout.primaryColor],
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
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: editMode
          ? () async {
              setState(() {
                widget.chosen.fillRange(0, widget.chosen.length, false);
                editMode = false;
              });
              return false;
            }
          : null,
      child: Stack(
        children: [
          getMainBody(),
          _WeekBar(),
        ],
      ),
    );
  }
}

class _TimetableListViewBehaviour extends ScrollBehavior {
  @override
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

class _WeekBar extends StatelessWidget {
  final CourseLayout courseLayout;
  _WeekBar({this.courseLayout = const CourseLayout.light(), Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<String> week = "SUN,MON,TUE,WED,THU,FRI,SAT".split(',');
    return Container(
      /*decoration: BoxDecoration(
        color: courseLayout.primaryColor,
        boxShadow: [
          BoxShadow(
            offset: Offset(3.0, 3.0),
            blurRadius: 5,
            spreadRadius: 2,
          ),
        ],
      ),*/
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 40,
          ),
          for (String day in week)
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(2, 8, 0, 1),
                child: Text(
                  day,
                  style: Theme.of(context).textTheme.subtitle2.apply(
                        color: courseLayout.secondaryColor,
                      ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _EditToolBar extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _EditToolBarState();
}

class _EditToolBarState extends State<_EditToolBar> {
  @override
  Widget build(BuildContext context) {}
}
