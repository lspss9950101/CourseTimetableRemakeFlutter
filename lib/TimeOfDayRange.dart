import 'package:flutter/material.dart';

class TimeOfDayRange {
  TimeOfDay start, end;

  TimeOfDayRange({@required this.start, @required this.end}) {
    assert(!(start.isAfter(end)));
  }

  TimeOfDayRange.nowToNow() {
    start = end = TimeOfDay.now();
  }

  String toString() => start.toFormattedString() + '-' + end.toFormattedString();
}

extension TimeOfDayExtension on TimeOfDay {
  bool isAfter (TimeOfDay t) => this.hour * 60 + this.minute > t.hour * 60 + t.minute;

  bool isBefore (TimeOfDay t) => this.hour * 60 + this.minute < t.hour * 60 + t.minute;

  bool isSameAs (TimeOfDay t) => this.hour * 60 + this.minute == t.hour * 60 + t.minute;

  String toFormattedString() => this.hour.toString().padLeft(2, '0') + ':' + this.minute.toString().padLeft(2, '0');
}