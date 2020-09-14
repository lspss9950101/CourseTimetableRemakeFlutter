import 'package:flutter/cupertino.dart';

import 'Course.dart';
import 'Session.dart';

class Timetable extends StatefulWidget {
  final List<Course> courses;
  final List<Session> sessions;

  Timetable({this.courses, this.sessions, Key key}) : super(key: key);

  @override
  State createState() => _TimetableState();
}

class _TimetableState extends State<Timetable> {
  Widget getSessionCell(Session session) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [Text(session.name)],
    );
  }

  Widget getCourseCell(Course course) {
    return Expanded(
      child: Text(course.name),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        itemCount: widget.sessions.length * 8,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
        itemBuilder: (
          BuildContext context,
          int index,
        ) {
          int offset = index % 8;
          int row = (index / 8).floor();
          if (offset == 0)
            return getSessionCell(widget.sessions[row]);
          else
            return getCourseCell(widget.courses[7 * row + offset - 1]);
        });
  }
}
