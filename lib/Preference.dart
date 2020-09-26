import 'package:course_timetable_remake/DBPreference.dart';
import 'package:course_timetable_remake/Dialog.dart';
import 'package:course_timetable_remake/TimeOfDayRange.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

enum PREF_TYPE {
  DARK_MODE,
  CONFIG_WEEK_SIZE,
  CONFIG_NAME_SIZE,
  CONFIG_ROOM_SIZE,
  CONFIG_ROOM_COLOR,
  WIDGET_WEEK_SIZE,
  WIDGET_WEEK_COLOR,
  WIDGET_WEEK_BACKGROUND,
  WIDGET_NAME_SIZE,
  WIDGET_ROOM_SIZE,
  WIDGET_CONTEXT_COLOR,
  WIDGET_CONTEXT_BACKGROUND,
  SYNC_ENABLED,
  SYNC_SESSION,
  SYNC_EVENT_ID,
  SYNC_CALENDAR_ID,
  SESSION_NAME,
  SESSION_TIME,
}

enum _PREF_TYPE_ATTR {
  DEFAULT_VALUE,
  PARSE_FUNCTION,
  TO_STRING_FUNCTION,
}

bool _parseBool(String s) => s.toLowerCase() == 'true';

Color _parseColor(String s) => Color(int.parse(s));

COLOR_MODE _parseColorMode(String s) => COLOR_MODE.values[int.parse(s)];

DateTimeRange _parseDateTimeRange(String s) => DateTimeRange(start: DateTime.parse(s.split('-')[0]), end: DateTime.parse(s.split('-')[1]));

List<String> _parseStringList(String s) => s.length == 0 ? [] : s.split('\n');

List<TimeOfDayRange> _parseTimeOfDayRangeList(String s) => _parseStringList(s).map((e) {
      List<int> parsedString = e.split(RegExp(r'[-:]')).map((e) => int.parse(e)).toList();
      return TimeOfDayRange(start: TimeOfDay(hour: parsedString[0], minute: parsedString[1]), end: TimeOfDay(hour: parsedString[2], minute: parsedString[3]));
    }).toList();

String _primitiveToString(Object o) => o.toString();

String _color_modeToString(COLOR_MODE c) => COLOR_MODE.values.indexOf(c).toString();

String _colorToString(Color c) => c.value.toString();

String _dateTimeRangeToString(DateTimeRange d) => DateFormat('yyyyMMdd HH:mm').format(d.start) + '-' + DateFormat('yyyyMMdd HH:mm').format(d.end);

String _stringListToString(List<String> ss) => ss.join('\n');

String _timeOfDayRangeListToString(List<TimeOfDayRange> ts) => ts.join('\n');

Map<PREF_TYPE, Map<_PREF_TYPE_ATTR, Object>> _PREF_DEFINITIONS = {
  PREF_TYPE.DARK_MODE: {
    _PREF_TYPE_ATTR.DEFAULT_VALUE: false,
    _PREF_TYPE_ATTR.PARSE_FUNCTION: _parseBool,
    _PREF_TYPE_ATTR.TO_STRING_FUNCTION: _primitiveToString,
  },
  PREF_TYPE.CONFIG_WEEK_SIZE: {
    _PREF_TYPE_ATTR.DEFAULT_VALUE: 1.0,
    _PREF_TYPE_ATTR.PARSE_FUNCTION: double.parse,
    _PREF_TYPE_ATTR.TO_STRING_FUNCTION: _primitiveToString,
  },
  PREF_TYPE.CONFIG_NAME_SIZE: {
    _PREF_TYPE_ATTR.DEFAULT_VALUE: 1.0,
    _PREF_TYPE_ATTR.PARSE_FUNCTION: double.parse,
    _PREF_TYPE_ATTR.TO_STRING_FUNCTION: _primitiveToString,
  },
  PREF_TYPE.CONFIG_ROOM_SIZE: {
    _PREF_TYPE_ATTR.DEFAULT_VALUE: 1.0,
    _PREF_TYPE_ATTR.PARSE_FUNCTION: double.parse,
    _PREF_TYPE_ATTR.TO_STRING_FUNCTION: _primitiveToString,
  },
  PREF_TYPE.CONFIG_ROOM_COLOR: {
    _PREF_TYPE_ATTR.DEFAULT_VALUE: COLOR_MODE.LIGHT,
    _PREF_TYPE_ATTR.PARSE_FUNCTION: _parseColorMode,
    _PREF_TYPE_ATTR.TO_STRING_FUNCTION: _color_modeToString,
  },
  PREF_TYPE.WIDGET_WEEK_SIZE: {
    _PREF_TYPE_ATTR.DEFAULT_VALUE: 1.0,
    _PREF_TYPE_ATTR.PARSE_FUNCTION: double.parse,
    _PREF_TYPE_ATTR.TO_STRING_FUNCTION: _primitiveToString,
  },
  PREF_TYPE.WIDGET_WEEK_COLOR: {
    _PREF_TYPE_ATTR.DEFAULT_VALUE: COLOR_MODE.LIGHT,
    _PREF_TYPE_ATTR.PARSE_FUNCTION: _parseColorMode,
    _PREF_TYPE_ATTR.TO_STRING_FUNCTION: _color_modeToString,
  },
  PREF_TYPE.WIDGET_WEEK_BACKGROUND: {
    _PREF_TYPE_ATTR.DEFAULT_VALUE: Colors.pink,
    _PREF_TYPE_ATTR.PARSE_FUNCTION: _parseColor,
    _PREF_TYPE_ATTR.TO_STRING_FUNCTION: _colorToString,
  },
  PREF_TYPE.WIDGET_NAME_SIZE: {
    _PREF_TYPE_ATTR.DEFAULT_VALUE: 1.0,
    _PREF_TYPE_ATTR.PARSE_FUNCTION: double.parse,
    _PREF_TYPE_ATTR.TO_STRING_FUNCTION: _primitiveToString,
  },
  PREF_TYPE.WIDGET_ROOM_SIZE: {
    _PREF_TYPE_ATTR.DEFAULT_VALUE: 1.0,
    _PREF_TYPE_ATTR.PARSE_FUNCTION: double.parse,
    _PREF_TYPE_ATTR.TO_STRING_FUNCTION: _primitiveToString,
  },
  PREF_TYPE.WIDGET_CONTEXT_COLOR: {
    _PREF_TYPE_ATTR.DEFAULT_VALUE: COLOR_MODE.LIGHT,
    _PREF_TYPE_ATTR.PARSE_FUNCTION: _parseColorMode,
    _PREF_TYPE_ATTR.TO_STRING_FUNCTION: _color_modeToString,
  },
  PREF_TYPE.WIDGET_CONTEXT_BACKGROUND: {
    _PREF_TYPE_ATTR.DEFAULT_VALUE: Colors.grey.shade50,
    _PREF_TYPE_ATTR.PARSE_FUNCTION: _parseColor,
    _PREF_TYPE_ATTR.TO_STRING_FUNCTION: _colorToString,
  },
  PREF_TYPE.SYNC_ENABLED: {
    _PREF_TYPE_ATTR.DEFAULT_VALUE: false,
    _PREF_TYPE_ATTR.PARSE_FUNCTION: _parseBool,
    _PREF_TYPE_ATTR.TO_STRING_FUNCTION: _primitiveToString,
  },
  PREF_TYPE.SYNC_SESSION: {
    _PREF_TYPE_ATTR.DEFAULT_VALUE: DateTimeRange(start: DateTime.now(), end: DateTime.now()),
    _PREF_TYPE_ATTR.PARSE_FUNCTION: _parseDateTimeRange,
    _PREF_TYPE_ATTR.TO_STRING_FUNCTION: _dateTimeRangeToString,
  },
  PREF_TYPE.SYNC_EVENT_ID: {
    _PREF_TYPE_ATTR.DEFAULT_VALUE: 0,
    _PREF_TYPE_ATTR.PARSE_FUNCTION: int.parse,
    _PREF_TYPE_ATTR.TO_STRING_FUNCTION: _primitiveToString,
  },
  PREF_TYPE.SYNC_CALENDAR_ID: {
    _PREF_TYPE_ATTR.DEFAULT_VALUE: 0,
    _PREF_TYPE_ATTR.PARSE_FUNCTION: int.parse,
    _PREF_TYPE_ATTR.TO_STRING_FUNCTION: _primitiveToString,
  },
  PREF_TYPE.SESSION_NAME: {
    _PREF_TYPE_ATTR.DEFAULT_VALUE: _parseStringList('A\nB\nC\nD\nX\nE\nF\nG\nH\nY\nI\nJ\nK'),
    _PREF_TYPE_ATTR.PARSE_FUNCTION: _parseStringList,
    _PREF_TYPE_ATTR.TO_STRING_FUNCTION: _stringListToString,
  },
  PREF_TYPE.SESSION_TIME: {
    _PREF_TYPE_ATTR.DEFAULT_VALUE: _parseTimeOfDayRangeList('''
      08:00-08:50
      09:00-09:50
      10:10-11:00
      11:10-12:00
      12:20-13:10
      13:20-14:10
      14:20-15:10
      15:30-16:20
      16:30-17:20
      17:30-18:20
      18:30-19:20
      19:30-20:20
      20:30-21:20'''),
    _PREF_TYPE_ATTR.PARSE_FUNCTION: _parseTimeOfDayRangeList,
    _PREF_TYPE_ATTR.TO_STRING_FUNCTION: _timeOfDayRangeListToString,
  },
};

extension PrefExtension on PREF_TYPE {
  dynamic getDefaultValue() {
    return _PREF_DEFINITIONS[this][_PREF_TYPE_ATTR.DEFAULT_VALUE];
  }

  dynamic Function(String) getParseFunction() {
    return _PREF_DEFINITIONS[this][_PREF_TYPE_ATTR.PARSE_FUNCTION];
  }

  dynamic getToStringFunction() {
    return _PREF_DEFINITIONS[this][_PREF_TYPE_ATTR.TO_STRING_FUNCTION];
  }
}

class Preference {
  PREF_TYPE type;
  dynamic value;

  Preference(this.type, this.value);

  Preference.byDefault(this.type) {
    value = type.getDefaultValue();
  }

  Preference.fromMap(Map<String, dynamic> map) {
    type = PREF_TYPE.values.firstWhere((element) => element.toString() == map[COLUMN_PREF_TYPE]);
    value = type.getParseFunction().call(map[COLUMN_PREF_VALUE]);
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      COLUMN_PREF_TYPE: type.toString(),
      COLUMN_PREF_VALUE: type.getToStringFunction().call(value),
    };
    return map;
  }

  String toString() {
    String valueString = type.getToStringFunction().call(value);
    return 'Preference(name: $type, value: $valueString)';
  }
}
