import 'package:flutter/material.dart';

import 'DBCourse.dart';

class Course {
  String name, room;
  Color color;
  Course(this.name, {this.room, this.color});
  Course.dummy() {
    this.name = 'dummy123456';
    this.room = 'EE000';
    this.color = Colors.pink.shade700;
  }
  Course.nullValue();
  Course.empty() {
    this.name = '';
    this.room = '';
    this.color = Colors.pink.shade700;
  }
  Course.fromMap(Map<String, dynamic> map) {
    this.name = map[COLUMN_COURSE_NAME];
    this.room = map[COLUMN_COURSE_ROOM];
    this.color = Color(map[COLUMN_COURSE_COLOR]);
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      COLUMN_COURSE_NAME: this.name,
      COLUMN_COURSE_ROOM: this.room,
      COLUMN_COURSE_COLOR: this.color.value,
    };
    return map;
  }
}