import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Resources {
  static final ThemeLight = ThemeData(
    brightness: Brightness.light,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    primarySwatch: Colors.deepPurple,
    accentColor: Colors.purpleAccent,
    iconTheme: IconThemeData(color: Color.fromARGB(255, 70, 70, 70)),
  );
}

class CourseLayout {
  final Color primaryColor;
  final Color secondaryColor;
  const CourseLayout.light({this.primaryColor=const Color.fromARGB(255, 250, 250, 250), this.secondaryColor=const Color.fromARGB(255, 70, 70, 70,)});
  const CourseLayout.dark({this.primaryColor=const Color.fromARGB(255, 70, 70, 70), this.secondaryColor=const Color.fromARGB(255, 250, 250, 250)});
}

enum MainPageCallBackMSG {
  SET_DARK_MODE,
}