
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

  Timetable(
      {this.courses = const [],
      this.sessions = const [],
      this.chosen = const [],
      this.courseLayout = const CourseLayout.light(),
      Key key})
      : super(key: key);

  @override
  State createState() => _TimetableState();
}

class _TimetableState extends State<Timetable> {
  Widget getSessionCell(Session session) {
    return Container(
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
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            widget.chosen[index] = !widget.chosen[index];
          });
        },
        child: Padding(
          padding: EdgeInsets.fromLTRB(2, 0, 0, 0),
          child: Container(
            color: widget.chosen[index]
                ? widget.courseLayout.secondaryColor
                : widget.courseLayout.primaryColor,
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
                        color: widget.chosen[index]
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
        ),
      ),
    );
  }

  Widget getRow(
      Session session, int sessionIndex, bool isLast, List<Course> courses) {
    return Container(
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: widget.courseLayout.secondaryColor,
                  width: 2,
                ),
              ),
      ),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.courseLayout.primaryColor,
      child: ScrollConfiguration(
        behavior: _TimetableListViewBehaviour(),
        child: ListView(
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
