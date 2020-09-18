import 'package:course_timetable_remake/Resources.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MessageSnackBar {
  static void showSnackBar(BuildContext context, String message, CourseLayout courseLayout, {Duration duration=const Duration(seconds: 1,)}) {
    SnackBar snackBar = SnackBar(content: Text(message), backgroundColor: courseLayout.secondaryColor, duration: duration,);
    Scaffold.of(context).showSnackBar(snackBar);
  }
}