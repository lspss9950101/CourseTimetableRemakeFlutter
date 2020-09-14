import 'package:flutter/material.dart';

class Course {
  String name, room;
  Color color;
  Course(this.name, {this.room, this.color});
  Course.dummy() {
    this.name = 'dummy';
  }
}