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