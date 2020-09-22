import 'package:course_timetable_remake/DBPreference.dart';
import 'package:course_timetable_remake/Dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const String PREF_DARK_MODE = 'DARK_MODE';
const String PREF_CONFIG_WEEK_SIZE = "CONFIG_WEEK_SIZE";
const String PREF_CONFIG_NAME_SIZE = 'CONFIG_NAME_SIZE';
const String PREF_CONFIG_ROOM_SIZE = 'CONFIG_ROOM_SIZE';
const String PREF_CONFIG_ROOM_COLOR = 'CONFIG_ROOM_COLOR';
const String PREF_WIDGET_WEEK_SIZE = 'WIDGET_WEEK_SIZE';
const String PREF_WIDGET_WEEK_COLOR = 'WIDGET_WEEK_COLOR';
const String PREF_WIDGET_WEEK_BACKGROUND = 'WIDGET_WEEK_BACKGROUND';
const String PREF_WIDGET_NAME_SIZE = 'WIDGET_NAME_SIZE';
const String PREF_WIDGET_ROOM_SIZE = 'WIDGET_ROOM_SIZE';
const String PREF_WIDGET_CONTEXT_COLOR = 'WIDGET_CONTEXT_COLOR';
const String PREF_WIDGET_CONTEXT_BACKGROUND = 'WIDGET_CONTEXT_BACKGROUND';
const String PREF_SYNC_ENABLED = 'SYNC_ENABLED';
const String PREF_SYNC_SESSION = 'SYNC_SESSION';
const String PREF_SYNC_EVENT_ID = 'SYNC_EVENT_ID';
const String PREF_SYNC_CALENDAR_ID = 'SYNC_CALENDAR_ID';
const String PREF_SESSION_NAME = 'SESSION_NAME';
const String PREF_SESSION_TIME = 'SESSION_TIME';

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

static const Map<Map<_PREF_TYPE_ATTR, Object>> _PREF_DEFINITIONS = {};

String getPrefDefault(PREF_TYPE type) {
  switch(type) {
    case PREF_TYPE.DARK_MODE:
      return 'false';
      break;
    case PREF_TYPE.CONFIG_WEEK_SIZE:
      return '1.0';
      break;
    case PREF_TYPE.CONFIG_NAME_SIZE:
      return '1.0';
      break;
    case PREF_TYPE.CONFIG_ROOM_SIZE:
      return '1.0';
      break;
    case PREF_TYPE.WIDGET_WEEK_SIZE:
      return '1.0';
      break;
    case PREF_TYPE.WIDGET_WEEK_COLOR:
      return '0';
      break;
    case PREF_TYPE.WIDGET_WEEK_BACKGROUND:
      return Colors.pink.value.toString();
      break;
    case PREF_TYPE.WIDGET_NAME_SIZE:
      return '1.0';
      break;
    case PREF_TYPE.WIDGET_ROOM_SIZE:
      return '1.0';
      break;
    case PREF_TYPE.WIDGET_CONTEXT_COLOR:
      return '0';
      break;
    case PREF_TYPE.WIDGET_CONTEXT_BACKGROUND:
      return Colors.grey.shade50.value.toString();
      break;
    case PREF_TYPE.SYNC_ENABLED:
      return 'false';
      break;
    case PREF_TYPE.SYNC_SESSION:
      return DateTime.now().year.toString() + '0101 00:00-' + DateTime.now().year.toString() + '1231 23:59';
      break;
    case PREF_TYPE.SYNC_EVENT_ID:
      return '-1';
      break;
    case PREF_TYPE.SYNC_CALENDAR_ID:
      return '-1';
      break;
    case PREF_TYPE.SESSION_NAME:
      return 'A\nB\nC\nD\nX\nE\nF\nG\nH\nY\nI\nJ\nK';
      break;
    case PREF_TYPE.SESSION_TIME:
      return '''
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
      20:30-21:20''';
      break;
    case PREF_TYPE.CONFIG_ROOM_COLOR:
      return '0';
      break;
  }
  return null;
}

dynamic castPreference(PREF_TYPE type, String data) {
  switch(type) {
    case PREF_TYPE.DARK_MODE:
      return data.toLowerCase() == 'true';
      break;
    case PREF_TYPE.CONFIG_WEEK_SIZE:
      return double.parse(data);
      break;
    case PREF_TYPE.CONFIG_NAME_SIZE:
      return double.parse(data);
      break;
    case PREF_TYPE.CONFIG_ROOM_SIZE:
      return double.parse(data);
      break;
    case PREF_TYPE.WIDGET_WEEK_SIZE:
      return double.parse(data);
      break;
    case PREF_TYPE.WIDGET_WEEK_COLOR:
      return COLOR_MODE.values[int.parse(data)];
      break;
    case PREF_TYPE.WIDGET_WEEK_BACKGROUND:
      return Color(int.parse(data));
      break;
    case PREF_TYPE.WIDGET_NAME_SIZE:
      return double.parse(data);
      break;
    case PREF_TYPE.WIDGET_ROOM_SIZE:
      return double.parse(data);
      break;
    case PREF_TYPE.WIDGET_CONTEXT_COLOR:
      return COLOR_MODE.values[int.parse(data)];
      break;
    case PREF_TYPE.WIDGET_CONTEXT_BACKGROUND:
      return Color(int.parse(data));
      break;
    case PREF_TYPE.SYNC_ENABLED:
      return data.toLowerCase() == 'true';
      break;
    case PREF_TYPE.SYNC_SESSION:
      String begin = data.split('-')[0];
      String end = data.split('-')[1];
      return DateTimeRange(start: DateTime.parse(begin), end: DateTime.parse(end),);
      break;
    case PREF_TYPE.SYNC_EVENT_ID:
      return int.parse(data);
      break;
    case PREF_TYPE.SYNC_CALENDAR_ID:
      return int.parse(data);
      break;
    case PREF_TYPE.SESSION_NAME:
      return data.split('\n');
      break;
    case PREF_TYPE.SESSION_TIME:
      List<String> s = data.split('\n');
      return s.map((e) {
        e = e.replaceAll(' ', '');
        DateTime start = DateTime.parse('0000-01-01 ' + e.split('-')[0]);
        DateTime end = DateTime.parse('0000-01-01 ' + e.split('-')[1]);
        return DateTimeRange(start: start, end: end);
      },).toList();
      break;
    case PREF_TYPE.CONFIG_ROOM_COLOR:
      return COLOR_MODE.values[int.parse(data)];
      break;
  }
}

/*extension PrefExtension on PREF_TYPE {
  String toString() {
    _PREF_DEFINITION[this][_PREF_TYPE_ATTR.TO_STRING_FUNCTION];
  }
}*/

class Preference {
  String name;
  dynamic value;

  Preference(PREF_TYPE type) {
    this.name = getPrefName(type);
    this.value = castPreference(type, getPrefDefault(type));
  }

  Preference.raw(PREF_TYPE type, dynamic value) {
    this.name = getPrefName(type);
    this.value = value;
  }

  Preference.fromMap(Map<String, dynamic> map) {
    this.name = map[COLUMN_PREF_NAME];
    this.value = castPreference(PREF_TYPE.values.firstWhere((element) => getPrefName(element) == this.name), map[COLUMN_PREF_VALUE]);
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      COLUMN_PREF_NAME: this.name,
      COLUMN_PREF_VALUE: valueToString(),
    };
    return map;
  }

  String valueToString() {
    PREF_TYPE type = PREF_TYPE.values.firstWhere((element) => getPrefName(element) == this.name);
    String valueString;
    if(type == PREF_TYPE.WIDGET_WEEK_BACKGROUND || type == PREF_TYPE.WIDGET_CONTEXT_BACKGROUND)
      valueString = (value as Color).value.toString();
    else if(type == PREF_TYPE.CONFIG_ROOM_COLOR || type == PREF_TYPE.WIDGET_CONTEXT_COLOR || type == PREF_TYPE.WIDGET_WEEK_COLOR)
      valueString = value == COLOR_MODE.LIGHT ? '0' : value == COLOR_MODE.DARK ? '1' : '2';
    else if(type == PREF_TYPE.SYNC_SESSION)
      valueString = DateFormat('yyyyMMdd HH:mm').format((value as DateTimeRange).start) + '-' + DateFormat('yyyyMMdd HH:mm').format((value as DateTimeRange).end);
    else if(type == PREF_TYPE.SESSION_NAME)
      valueString = (value as List<String>).join('\n');
    else if(type == PREF_TYPE.SESSION_TIME)
      valueString = (value as List<DateTimeRange>).map((e) => DateFormat('HH:mm').format(e.start) + '-' + DateFormat('HH:mm').format(e.end)).join('\n');
    else
      valueString = value.toString();
    return valueString;
  }

  String toString() {
    String valueString = valueToString();
    return 'Preference(name: $name, value: $valueString)';
  }

  static String getPrefName(PREF_TYPE type) {
    switch(type) {
      case PREF_TYPE.DARK_MODE:
        return PREF_DARK_MODE;
        break;
      case PREF_TYPE.CONFIG_WEEK_SIZE:
        return PREF_CONFIG_WEEK_SIZE;
        break;
      case PREF_TYPE.CONFIG_NAME_SIZE:
        return PREF_CONFIG_NAME_SIZE;
        break;
      case PREF_TYPE.CONFIG_ROOM_SIZE:
        return PREF_CONFIG_ROOM_SIZE;
        break;
      case PREF_TYPE.WIDGET_WEEK_SIZE:
        return PREF_WIDGET_WEEK_SIZE;
        break;
      case PREF_TYPE.WIDGET_WEEK_COLOR:
        return PREF_WIDGET_WEEK_COLOR;
        break;
      case PREF_TYPE.WIDGET_WEEK_BACKGROUND:
        return PREF_WIDGET_WEEK_BACKGROUND;
        break;
      case PREF_TYPE.WIDGET_NAME_SIZE:
        return PREF_WIDGET_NAME_SIZE;
        break;
      case PREF_TYPE.WIDGET_ROOM_SIZE:
        return PREF_WIDGET_ROOM_SIZE;
        break;
      case PREF_TYPE.WIDGET_CONTEXT_COLOR:
        return PREF_WIDGET_CONTEXT_COLOR;
        break;
      case PREF_TYPE.WIDGET_CONTEXT_BACKGROUND:
        return PREF_WIDGET_CONTEXT_BACKGROUND;
        break;
      case PREF_TYPE.SYNC_ENABLED:
        return PREF_SYNC_ENABLED;
        break;
      case PREF_TYPE.SYNC_SESSION:
        return PREF_SYNC_SESSION;
        break;
      case PREF_TYPE.SYNC_EVENT_ID:
        return PREF_SYNC_EVENT_ID;
        break;
      case PREF_TYPE.SYNC_CALENDAR_ID:
        return PREF_SYNC_CALENDAR_ID;
        break;
      case PREF_TYPE.SESSION_NAME:
        return PREF_SESSION_NAME;
        break;
      case PREF_TYPE.SESSION_TIME:
        return PREF_SESSION_TIME;
        break;
      case PREF_TYPE.CONFIG_ROOM_COLOR:
        return PREF_CONFIG_ROOM_COLOR;
        break;
    }
    return null;
  }

}