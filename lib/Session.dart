import 'package:course_timetable_remake/TimeOfDayRange.dart';
import 'package:flutter/material.dart';

class Session {
  String name;
  TimeOfDayRange timeOfDayRange;
  Session({@required this.name, @required this.timeOfDayRange});
  Session.dummy() {
    name = 'S';
    timeOfDayRange = TimeOfDayRange.nowToNow();
  }
}