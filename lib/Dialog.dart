import 'package:course_timetable_remake/DBCourse.dart';

import 'DBPath.dart';
import 'DBPreference.dart';
import 'MaterialColorPicker.dart';
import 'Preference.dart';
import 'Resources.dart';
import 'TimeOfDayRange.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:reorderables/reorderables.dart';

import 'Course.dart';
import 'Session.dart';

class TimetableDialog {
  static Future<Course> showAddEditCourseDialog(
      BuildContext context, CourseLayout courseLayout, Course defaultCourse) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SingleChildScrollView(
        child: _CourseConfigDialog(
          courseLayout: courseLayout,
          defaultCourse: defaultCourse,
        ),
      ),
    );
  }

  static Future showContextSettingDialog(
      BuildContext context,
      void Function(MainPageCallBackMSG msg, dynamic arg) mainPageCallback,
      CourseLayout courseLayout) async {
    Map prefs = await PreferenceProvider.getInstance().getPreferences();
    double dbNameSize = prefs[PREF_TYPE.CONFIG_NAME_SIZE].value;
    double dbRoomSize = prefs[PREF_TYPE.CONFIG_ROOM_SIZE].value;
    double dbDayOfWeekSize = prefs[PREF_TYPE.CONFIG_WEEK_SIZE].value;
    COLOR_MODE dbRoomColor = prefs[PREF_TYPE.CONFIG_ROOM_COLOR].value;

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SingleChildScrollView(
        child: _ContextSettingDialog(
          courseLayout: courseLayout,
          defaultNameSize: dbNameSize,
          defaultRoomSize: dbRoomSize,
          defaultDayOfWeekSize: dbDayOfWeekSize,
          defaultRoomColor: dbRoomColor,
          callback: (
              {double nameSize,
              double roomSize,
              double dayOfWeekSize,
              COLOR_MODE roomColor}) {
            mainPageCallback(MainPageCallBackMSG.SET_CONFIG_APPEARANCE, {
              'nameSize': nameSize,
              'roomSize': roomSize,
              'dayOfWeekSize': dayOfWeekSize,
              'roomColor': roomColor
            });
            dbNameSize = nameSize ?? dbNameSize;
            dbRoomSize = roomSize ?? dbRoomSize;
            dbDayOfWeekSize = dayOfWeekSize ?? dbDayOfWeekSize;
            dbRoomColor = roomColor ?? dbRoomColor;
          },
        ),
      ),
    );
  }

  static Future showPathConfigDialog(
      BuildContext context, CourseLayout courseLayout,
      [Function(MainPageCallBackMSG, [dynamic]) callback,]) async {

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PathConfigDialog(
        callback: callback,
        courseLayout: courseLayout,
      ),
    );
  }

  static Future showSessionSettingDialog(
      BuildContext context, CourseLayout courseLayout) async {
    List<Session> sessions = await CourseProvider.getInstance().getSessions();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SessionSettingDialog(
        courseLayout: courseLayout,
        defaultSessions: sessions,
      ),
    );
  }

  static Future showWidgetSettingDialog(
      BuildContext context, CourseLayout courseLayout) async {
    Map prefs = await PreferenceProvider.getInstance().getPreferences();

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SingleChildScrollView(
        child: _WidgetSettingDialog(
          courseLayout: courseLayout,
          defaultNameSize: prefs[PREF_TYPE.WIDGET_NAME_SIZE].value,
          defaultRoomSize: prefs[PREF_TYPE.WIDGET_ROOM_SIZE].value,
          defaultDayOfWeekSize: prefs[PREF_TYPE.WIDGET_WEEK_SIZE].value,
          defaultNameColor: prefs[PREF_TYPE.WIDGET_CONTEXT_COLOR].value,
          defaultDayOfWeekColor: prefs[PREF_TYPE.WIDGET_WEEK_COLOR].value,
          defaultBackgroundOpacity:
              (prefs[PREF_TYPE.WIDGET_CONTEXT_BACKGROUND].value as Color)
                  .opacity,
          defaultDayOfWeekBackground:
              prefs[PREF_TYPE.WIDGET_WEEK_BACKGROUND].value,
          defaultTimetableBackground:
              (prefs[PREF_TYPE.WIDGET_CONTEXT_BACKGROUND].value as Color)
                  .withOpacity(1),
        ),
      ),
    );
  }
}

class _CourseConfigDialog extends StatefulWidget {
  final CourseLayout courseLayout;
  final Course defaultCourse;
  _CourseConfigDialog(
      {this.defaultCourse,
      this.courseLayout = const CourseLayout.light(),
      Key key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _CourseConfigDialogState();
}

class _CourseConfigDialogState extends State<_CourseConfigDialog> {
  TextEditingController _textEditingControllerName;
  TextEditingController _textEditingControllerRoom;
  Color _color;

  @override
  void initState() {
    super.initState();
    _textEditingControllerName = TextEditingController();
    _textEditingControllerRoom = TextEditingController();
    _color = widget.defaultCourse.color;
    _textEditingControllerName.text = widget.defaultCourse.name;
    _textEditingControllerRoom.text = widget.defaultCourse.room;
  }

  @override
  void dispose() {
    super.dispose();
    _textEditingControllerName.dispose();
    _textEditingControllerRoom.dispose();
  }

  Widget getOption(title, controller, isTextField) => Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.subtitle1.apply(
                    color: widget.courseLayout.secondaryColor,
                  ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.5,
              height: 60,
              child: isTextField
                  ? TextField(
                      controller: controller,
                      style: Theme.of(context)
                          .textTheme
                          .subtitle1
                          .apply(color: widget.courseLayout.secondaryColor),
                      decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: widget.courseLayout.secondaryColor,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color.lerp(
                              widget.courseLayout.primaryColor,
                              widget.courseLayout.secondaryColor,
                              0.5,
                            ),
                          ),
                        ),
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(4),
                        ),
                        border: Border.all(
                          color: Color.lerp(widget.courseLayout.primaryColor,
                              widget.courseLayout.secondaryColor, 0.5),
                        ),
                      ),
                      child: FlatButton(
                        color: _color,
                        onPressed: () async {
                          FocusScope.of(context).unfocus();
                          Color newColorTemp;
                          _color = await showDialog(
                                context: context,
                                child: AlertDialog(
                                  backgroundColor:
                                      widget.courseLayout.primaryColor,
                                  content: MaterialColorPicker(_color,
                                      courseLayout: widget.courseLayout,
                                      onColorChanged: (newColor) {
                                    newColorTemp = newColor;
                                  }),
                                  actions: [
                                    FlatButton(
                                      onPressed: () {
                                        Navigator.pop(context, _color);
                                      },
                                      child: Text('CANCEL'),
                                    ),
                                    FlatButton(
                                      onPressed: () {
                                        Navigator.pop(context, newColorTemp);
                                      },
                                      child: Text('CONFIRM'),
                                    ),
                                  ],
                                ),
                              ) ??
                              _color;
                          setState(() {});
                        },
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(4, 0, 0, 0),
                            child: Text(
                              '#' +
                                  _color.value
                                      .toRadixString(16)
                                      .padLeft(8, '0')
                                      .substring(2)
                                      .toUpperCase(),
                              style: Theme.of(context)
                                  .textTheme
                                  .headline6
                                  .apply(
                                      color: useWhiteForeground(_color)
                                          ? Colors.white
                                          : Colors.black),
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.courseLayout.primaryColor,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 8),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: FlatButton(
                      color: Colors.green.shade700,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(5),
                        ),
                      ),
                      onPressed: () {
                        Course course = Course(
                            _textEditingControllerName.value.text,
                            room: _textEditingControllerRoom.value.text,
                            color: _color);
                        Navigator.pop(context, course);
                      },
                      child: Text(
                        '確認',
                        style: Theme.of(context)
                            .textTheme
                            .subtitle1
                            .apply(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            getOption('COURSE NAME', _textEditingControllerName, true),
            getOption('COURSE ROOM', _textEditingControllerRoom, true),
            getOption('TINT COLOUR', null, false),
          ],
        ),
      ),
    );
  }
}

class _ContextSettingDialog extends StatefulWidget {
  final CourseLayout courseLayout;
  final double defaultNameSize;
  final double defaultRoomSize;
  final double defaultDayOfWeekSize;
  final COLOR_MODE defaultRoomColor;
  final Function(
      {double nameSize,
      double roomSize,
      double dayOfWeekSize,
      COLOR_MODE roomColor}) callback;
  _ContextSettingDialog(
      {Key key,
      this.callback,
      this.defaultRoomColor = COLOR_MODE.LIGHT,
      this.defaultNameSize = 0,
      this.defaultRoomSize = 0,
      this.defaultDayOfWeekSize = 0,
      this.courseLayout})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _ContextSettingDialogState();
}

class _ContextSettingDialogState extends State<_ContextSettingDialog> {
  double nameSize = 0;
  double roomSize = 0;
  double dayOfWeekSize = 0;
  COLOR_MODE roomColor = COLOR_MODE.LIGHT;
  List<bool> _isSelectedRoomColor = [true, false, false];

  Widget getLabeledSlider(String title, double value,
      Function(double) onChanged, Function(double) onChangeEnd) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          flex: 5,
          child: Text(
            title,
            style: Theme.of(context)
                .textTheme
                .bodyText2
                .apply(color: widget.courseLayout.secondaryColor),
          ),
        ),
        Expanded(
          flex: 12,
          child: Slider(
            activeColor: Colors.purple.shade400,
            inactiveColor: Colors.purple.shade700.withOpacity(0.5),
            onChanged: onChanged,
            onChangeEnd: onChangeEnd,
            min: 0,
            max: 2,
            value: value,
          ),
        ),
      ],
    );
  }

  Widget getLabeledRadioButton(String title, COLOR_MODE color,
      List<bool> isSelected, Function(COLOR_MODE) onChanged) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            flex: 5,
            child: Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .bodyText2
                  .apply(color: widget.courseLayout.secondaryColor),
            ),
          ),
          Expanded(
            flex: 12,
            child: Align(
              alignment: Alignment.center,
              child: ToggleButtons(
                fillColor: Colors.purple.shade200.withOpacity(0.5),
                borderColor: widget.courseLayout.secondaryColor,
                selectedBorderColor: widget.courseLayout.secondaryColor,
                isSelected: isSelected,
                children: [
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        'LIGHT',
                        style: Theme.of(context)
                            .textTheme
                            .bodyText2
                            .apply(color: widget.courseLayout.secondaryColor),
                      )),
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        'DARK',
                        style: Theme.of(context)
                            .textTheme
                            .bodyText2
                            .apply(color: widget.courseLayout.secondaryColor),
                      )),
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        'ADAPTIVE',
                        style: Theme.of(context)
                            .textTheme
                            .bodyText2
                            .apply(color: widget.courseLayout.secondaryColor),
                      )),
                ],
                onPressed: (index) {
                  for (int idx = 0; idx < 3; idx++) {
                    if (idx == index)
                      isSelected[idx] = true;
                    else
                      isSelected[idx] = false;
                  }
                  onChanged(COLOR_MODE.values[index]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    nameSize = widget.defaultNameSize;
    roomSize = widget.defaultRoomSize;
    dayOfWeekSize = widget.defaultDayOfWeekSize;
    roomColor = widget.defaultRoomColor;
    _isSelectedRoomColor = List.filled(3, false);
    _isSelectedRoomColor[COLOR_MODE.values.indexOf(roomColor)] = true;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.courseLayout.primaryColor,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(
          children: [
            Text(
              'TEXT SIZE',
              style: Theme.of(context)
                  .textTheme
                  .subtitle1
                  .apply(color: widget.courseLayout.secondaryColor),
            ),
            getLabeledSlider('DAY OF WEEK', dayOfWeekSize, (value) {
              setState(() {
                dayOfWeekSize = value;
                widget.callback(dayOfWeekSize: value);
              });
            }, (value) {
              PreferenceProvider.getInstance()
                  .setPreference(Preference(PREF_TYPE.CONFIG_WEEK_SIZE, value));
            }),
            getLabeledSlider('NAME', nameSize, (value) {
              setState(() {
                nameSize = value;
                widget.callback(nameSize: value);
              });
            }, (value) {
              PreferenceProvider.getInstance()
                  .setPreference(Preference(PREF_TYPE.CONFIG_NAME_SIZE, value));
            }),
            getLabeledSlider('ROOM', roomSize, (value) {
              setState(() {
                roomSize = value;
                widget.callback(roomSize: value);
              });
            }, (value) {
              PreferenceProvider.getInstance()
                  .setPreference(Preference(PREF_TYPE.CONFIG_ROOM_SIZE, value));
            }),
            Container(
              height: 16,
            ),
            Text(
              'TEXT COLOR',
              style: Theme.of(context)
                  .textTheme
                  .subtitle1
                  .apply(color: widget.courseLayout.secondaryColor),
            ),
            getLabeledRadioButton('ROOM', roomColor, _isSelectedRoomColor,
                (value) {
              setState(() {
                roomColor = value;
                widget.callback(roomColor: value);
                PreferenceProvider.getInstance().setPreference(
                    Preference(PREF_TYPE.CONFIG_ROOM_COLOR, value));
              });
            }),
            Container(
              height: 16,
            ),
            Text(
              'SYNC TO GOOGLE CALENDAR',
              style: Theme.of(context)
                  .textTheme
                  .subtitle1
                  .apply(color: widget.courseLayout.secondaryColor),
            ),
          ],
        ),
      ),
    );
  }
}

enum COLOR_MODE {
  LIGHT,
  DARK,
  ADAPTIVE,
}

class _WidgetSettingDialog extends StatefulWidget {
  final CourseLayout courseLayout;
  final double defaultDayOfWeekSize;
  final double defaultBackgroundOpacity;
  final double defaultNameSize;
  final double defaultRoomSize;
  final COLOR_MODE defaultDayOfWeekColor;
  final COLOR_MODE defaultNameColor;
  final Color defaultDayOfWeekBackground;
  final Color defaultTimetableBackground;
  _WidgetSettingDialog(
      {this.defaultDayOfWeekSize = 0,
      this.defaultBackgroundOpacity = 0,
      this.defaultNameSize = 0,
      this.defaultRoomSize = 0,
      this.defaultDayOfWeekColor = COLOR_MODE.LIGHT,
      this.defaultNameColor = COLOR_MODE.LIGHT,
      this.defaultDayOfWeekBackground = const Color(0x00796B),
      this.defaultTimetableBackground = const Color(0xFAFAFA),
      this.courseLayout,
      Key key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _WidgetSettingDialogState();
}

class _WidgetSettingDialogState extends State<_WidgetSettingDialog> {
  double dayOfWeekSize = 0;
  double backgroundOpacity = 1;
  double nameSize = 0;
  double roomSize = 0;
  COLOR_MODE dayOfWeekColor = COLOR_MODE.LIGHT;
  List<bool> _isSelectedDayOfWeekColor = [true, false, false];
  COLOR_MODE nameColor = COLOR_MODE.LIGHT;
  List<bool> _isSelectedNameColor = [true, false, false];
  Color dayOfWeekBackground = Colors.teal[700];
  Color timetableBackground = Colors.grey.shade50;

  @override
  void initState() {
    super.initState();
    dayOfWeekSize = widget.defaultDayOfWeekSize;
    backgroundOpacity = widget.defaultBackgroundOpacity;
    nameSize = widget.defaultNameSize;
    roomSize = widget.defaultRoomSize;
    dayOfWeekColor = widget.defaultDayOfWeekColor;
    nameColor = widget.defaultNameColor;
    dayOfWeekBackground = widget.defaultDayOfWeekBackground;
    timetableBackground = widget.defaultTimetableBackground;

    _isSelectedDayOfWeekColor = List.filled(3, false);
    _isSelectedNameColor = List.filled(3, false);
    _isSelectedDayOfWeekColor[COLOR_MODE.values.indexOf(dayOfWeekColor)] = true;
    _isSelectedNameColor[COLOR_MODE.values.indexOf(nameColor)] = true;
  }

  Widget getLabeledSlider(String title, double value,
      Function(double) onChanged, Function(double) onChangeEnd) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            flex: 5,
            child: Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .bodyText2
                  .apply(color: widget.courseLayout.secondaryColor),
            ),
          ),
          Expanded(
            flex: 12,
            child: Slider(
              activeColor: Colors.purple.shade400,
              inactiveColor: Colors.purple.shade700.withOpacity(0.5),
              onChanged: onChanged,
              onChangeEnd: onChangeEnd,
              min: 0,
              max: 2,
              value: value,
            ),
          ),
        ],
      ),
    );
  }

  Widget getLabeledRadioButton(String title, COLOR_MODE color,
      List<bool> isSelected, Function(COLOR_MODE) onChanged) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            flex: 5,
            child: Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .bodyText2
                  .apply(color: widget.courseLayout.secondaryColor),
            ),
          ),
          Expanded(
            flex: 12,
            child: Align(
              alignment: Alignment.center,
              child: ToggleButtons(
                fillColor: Colors.purple.shade200.withOpacity(0.5),
                borderColor: widget.courseLayout.secondaryColor,
                selectedBorderColor: widget.courseLayout.secondaryColor,
                isSelected: isSelected,
                children: [
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        'LIGHT',
                        style: Theme.of(context)
                            .textTheme
                            .bodyText2
                            .apply(color: widget.courseLayout.secondaryColor),
                      )),
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        'DARK',
                        style: Theme.of(context)
                            .textTheme
                            .bodyText2
                            .apply(color: widget.courseLayout.secondaryColor),
                      )),
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        'ADAPTIVE',
                        style: Theme.of(context)
                            .textTheme
                            .bodyText2
                            .apply(color: widget.courseLayout.secondaryColor),
                      )),
                ],
                onPressed: (index) {
                  for (int idx = 0; idx < 3; idx++) {
                    if (idx == index)
                      isSelected[idx] = true;
                    else
                      isSelected[idx] = false;
                  }
                  onChanged(COLOR_MODE.values[index]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget getLabeledColorPicker(
      String title, Color color, Function(Color) onChanged) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            flex: 5,
            child: Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .bodyText2
                  .apply(color: widget.courseLayout.secondaryColor),
            ),
          ),
          Expanded(
            flex: 12,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.all(
                    Radius.circular(4),
                  ),
                  border: Border.all(
                    color: Color.lerp(widget.courseLayout.primaryColor,
                        widget.courseLayout.secondaryColor, 0.5),
                  ),
                ),
                child: FlatButton(
                  onPressed: () async {
                    Color newColorTemp;
                    color = await showDialog(
                          context: context,
                          child: AlertDialog(
                            backgroundColor: widget.courseLayout.primaryColor,
                            content: MaterialColorPicker(color,
                                courseLayout: widget.courseLayout,
                                onColorChanged: (newColor) {
                              newColorTemp = newColor;
                            }),
                            actions: [
                              FlatButton(
                                onPressed: () {
                                  Navigator.pop(context, color);
                                },
                                child: Text('CANCEL'),
                              ),
                              FlatButton(
                                onPressed: () {
                                  Navigator.pop(context, newColorTemp);
                                },
                                child: Text('CONFIRM'),
                              ),
                            ],
                          ),
                        ) ??
                        color;
                    onChanged(color);
                  },
                  child: Container(
                    height: 50,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(4, 0, 0, 0),
                        child: Text(
                          '#' +
                              color.value
                                  .toRadixString(16)
                                  .padLeft(8, '0')
                                  .substring(2)
                                  .toUpperCase(),
                          style: Theme.of(context).textTheme.headline6.apply(
                              color: useWhiteForeground(color)
                                  ? Colors.white
                                  : Colors.black),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.courseLayout.primaryColor,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(
          children: [
            Text(
              'TEXT SIZE',
              style: Theme.of(context)
                  .textTheme
                  .subtitle1
                  .apply(color: widget.courseLayout.secondaryColor),
            ),
            getLabeledSlider('DAY OF WEEK', dayOfWeekSize, (value) {
              setState(() {
                dayOfWeekSize = value;
              });
            }, (value) {
              PreferenceProvider.getInstance()
                  .setPreference(Preference(PREF_TYPE.WIDGET_WEEK_SIZE, value));
            }),
            getLabeledSlider('NAME', nameSize, (value) {
              setState(() {
                nameSize = value;
              });
            }, (value) {
              PreferenceProvider.getInstance()
                  .setPreference(Preference(PREF_TYPE.WIDGET_NAME_SIZE, value));
            }),
            getLabeledSlider('ROOM', roomSize, (value) {
              setState(() {
                roomSize = value;
              });
            }, (value) {
              PreferenceProvider.getInstance()
                  .setPreference(Preference(PREF_TYPE.WIDGET_ROOM_SIZE, value));
            }),
            Container(
              height: 16,
            ),
            Text(
              'DAY OF WEEK COLOR',
              style: Theme.of(context)
                  .textTheme
                  .subtitle1
                  .apply(color: widget.courseLayout.secondaryColor),
            ),
            getLabeledRadioButton(
                'TEXT', dayOfWeekColor, _isSelectedDayOfWeekColor, (value) {
              setState(() {
                dayOfWeekColor = value;
                PreferenceProvider.getInstance().setPreference(
                    Preference(PREF_TYPE.WIDGET_WEEK_COLOR, value));
              });
            }),
            getLabeledColorPicker('BACKGROUND', dayOfWeekBackground, (value) {
              setState(() {
                dayOfWeekBackground = value;
                PreferenceProvider.getInstance().setPreference(
                    Preference(PREF_TYPE.WIDGET_WEEK_BACKGROUND, value));
              });
            }),
            Container(
              height: 16,
            ),
            Text(
              'TIMETABLE COLOR',
              style: Theme.of(context)
                  .textTheme
                  .subtitle1
                  .apply(color: widget.courseLayout.secondaryColor),
            ),
            getLabeledRadioButton('TEXT', nameColor, _isSelectedNameColor,
                (value) {
              setState(() {
                dayOfWeekColor = value;
                PreferenceProvider.getInstance().setPreference(
                    Preference(PREF_TYPE.WIDGET_CONTEXT_COLOR, value));
              });
            }),
            getLabeledColorPicker('BACKGROUND', timetableBackground, (value) {
              setState(() {
                timetableBackground = value;
                PreferenceProvider.getInstance().setPreference(Preference(
                    PREF_TYPE.WIDGET_CONTEXT_BACKGROUND,
                    timetableBackground.withOpacity(backgroundOpacity)));
              });
            }),
            getLabeledSlider('OPACITY', backgroundOpacity, (value) {
              setState(() {
                backgroundOpacity = value;
              });
            }, (value) {
              PreferenceProvider.getInstance().setPreference(Preference(
                  PREF_TYPE.WIDGET_CONTEXT_BACKGROUND,
                  timetableBackground.withOpacity(value)));
            }),
          ],
        ),
      ),
    );
  }
}

class _SessionSettingDialog extends StatefulWidget {
  final List<Session> defaultSessions;
  final CourseLayout courseLayout;
  _SessionSettingDialog({Key key, this.courseLayout, this.defaultSessions})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _SessionSettingDialogState();
}

class _SessionSettingDialogState extends State<_SessionSettingDialog> {
  List<Session> sessions;

  Future _saveToDB() async {
    await CourseProvider.getInstance().setSessions(sessions);
  }

  @override
  void initState() {
    super.initState();
    sessions = List.of(widget.defaultSessions);
  }

  Widget getSessionRow(Session session,
      {GestureTapCallback onTap, Function(DismissDirection) onSwiped}) {
    Widget child = GestureDetector(
      onTap: onTap,
      child: Padding(
        key: Key(session.hashCode.toString()),
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: Color.lerp(
                widget.courseLayout.primaryColor, Colors.white, 0.15),
            boxShadow: [
              BoxShadow(color: Color.fromARGB(200, 70, 70, 70), blurRadius: 3),
            ],
          ),
          child: Align(
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Text(
                      session.name,
                      style: Theme.of(context)
                          .textTheme
                          .headline6
                          .apply(color: widget.courseLayout.secondaryColor),
                    ),
                  ),
                  Flexible(
                    child: Text(
                      session.timeOfDayRange.toString(),
                      style: Theme.of(context)
                          .textTheme
                          .headline6
                          .apply(color: widget.courseLayout.secondaryColor),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    return Dismissible(
      key: Key(session.hashCode.toString()),
      child: child,
      onDismissed: onSwiped,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: widget.courseLayout.primaryColor,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            24, 48, 24, MediaQuery.of(context).viewInsets.bottom + 24),
        child: ScrollConfiguration(
          behavior: _ScrollBehaviour(),
          child: ReorderableColumn(
            onReorder: (int oldIndex, int newIndex) {
              setState(() {
                Session t = sessions.removeAt(oldIndex);
                sessions.insert(newIndex, t);
                _saveToDB();
              });
            },
            children: [
              for (Session session in sessions)
                getSessionRow(
                  session,
                  onTap: () async {
                    await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: widget.courseLayout.primaryColor,
                        content: _SessionConfigDialog(
                          courseLayout: widget.courseLayout,
                          session: session,
                        ),
                      ),
                    );
                    await _saveToDB();
                    setState(() {});
                  },
                  onSwiped: (_) async {
                    sessions.remove(session);
                    await _saveToDB();
                    setState(() {});
                  },
                ),
            ],
            buildDraggableFeedback: (context, constraints, child) => Material(
              child: ConstrainedBox(
                constraints: constraints,
                child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromARGB(50, 30, 30, 30),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: child),
              ),
              color: Colors.transparent,
            ),
            footer: Padding(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: GestureDetector(
                onTap: () async {
                  Session newSession = Session.dummy();
                  bool status = await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: widget.courseLayout.primaryColor,
                      content: _SessionConfigDialog(
                        courseLayout: widget.courseLayout,
                        session: newSession,
                      ),
                      actions: [
                        FlatButton(
                          onPressed: () {
                            Navigator.pop(context, false);
                          },
                          child: Text(
                            'Cancel',
                            style: Theme.of(context).textTheme.subtitle1.apply(
                                color: widget.courseLayout.secondaryColor),
                          ),
                        ),
                        FlatButton(
                          onPressed: () {
                            Navigator.pop(context, true);
                          },
                          child: Text(
                            'CONFIRM',
                            style: Theme.of(context).textTheme.subtitle1.apply(
                                color: widget.courseLayout.secondaryColor),
                          ),
                        ),
                      ],
                    ),
                  );
                  if (status ?? false)
                    setState(() {
                      sessions.add(newSession);
                      _saveToDB();
                    });
                },
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Color.lerp(
                        widget.courseLayout.primaryColor, Colors.white, 0.15),
                    boxShadow: [
                      BoxShadow(
                          color: Color.fromARGB(200, 70, 70, 70),
                          blurRadius: 2),
                    ],
                  ),
                  width: double.infinity,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: Icon(
                            Icons.add_circle_outline,
                            color: widget.courseLayout.secondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ScrollBehaviour extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

class _SessionConfigDialog extends StatefulWidget {
  final Session session;
  final CourseLayout courseLayout;
  _SessionConfigDialog({Key key, this.courseLayout, this.session})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _SessionConfigDialogState();
}

class _SessionConfigDialogState extends State<_SessionConfigDialog> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 75,
      child: Row(
        children: [
          Expanded(
            child: FlatButton(
              child: SizedBox(
                width: double.infinity,
                child: Text(
                  widget.session.name,
                  textAlign: TextAlign.start,
                  style: Theme.of(context)
                      .textTheme
                      .headline6
                      .apply(color: widget.courseLayout.secondaryColor),
                ),
              ),
              onPressed: () async {
                TextEditingController textEditingController =
                    TextEditingController();
                String newName = await showDialog(
                  context: context,
                  child: AlertDialog(
                    backgroundColor: widget.courseLayout.primaryColor,
                    content: _TextInputDialog(
                      textEditingController: textEditingController,
                      defaultValue: widget.session.name,
                      courseLayout: widget.courseLayout,
                    ),
                    actions: [
                      FlatButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Cancel',
                          style: Theme.of(context)
                              .textTheme
                              .subtitle1
                              .apply(color: widget.courseLayout.secondaryColor),
                        ),
                      ),
                      FlatButton(
                        onPressed: () {
                          Navigator.pop(context, textEditingController.text);
                        },
                        child: Text('CONFIRM',
                            style: Theme.of(context).textTheme.subtitle1.apply(
                                color: widget.courseLayout.secondaryColor)),
                      ),
                    ],
                  ),
                );
                setState(() {
                  widget.session.name = newName ?? widget.session.name;
                });
              },
            ),
          ),
          Flexible(
            child: FlatButton(
              onPressed: () async {
                TimeOfDay time = await showTimePicker(
                  context: context,
                  initialTime: widget.session.timeOfDayRange.start,
                  helpText: "SELECT TIME",
                  cancelText: "Cancel",
                  confirmText: "CONFIRM",
                );
                if (time != null)
                  setState(() {
                    widget.session.timeOfDayRange.start = time;
                  });
              },
              child: Text(
                widget.session.timeOfDayRange.start.toFormattedString(),
                softWrap: false,
                style: Theme.of(context)
                    .textTheme
                    .headline6
                    .apply(color: widget.courseLayout.secondaryColor),
              ),
            ),
          ),
          Text(
            " - ",
            style: Theme.of(context)
                .textTheme
                .headline6
                .apply(color: widget.courseLayout.secondaryColor),
          ),
          Flexible(
            child: FlatButton(
              onPressed: () async {
                TimeOfDay time = await showTimePicker(
                    context: context,
                    initialTime: widget.session.timeOfDayRange.end,
                    helpText: "SELECT TIME",
                    cancelText: "Cancel",
                    confirmText: "CONFIRM");
                if (time != null)
                  setState(() {
                    widget.session.timeOfDayRange.end = time;
                  });
              },
              child: Text(
                widget.session.timeOfDayRange.end.toFormattedString(),
                softWrap: false,
                style: Theme.of(context)
                    .textTheme
                    .headline6
                    .apply(color: widget.courseLayout.secondaryColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TextInputDialog extends StatefulWidget {
  final CourseLayout courseLayout;
  final String defaultValue;
  final TextEditingController textEditingController;
  final List<String> blacklist;
  _TextInputDialog(
      {Key key,
      this.textEditingController,
      this.defaultValue,
      this.courseLayout,
      this.blacklist=const []})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _TextInputDialogState();
}

class _TextInputDialogState extends State<_TextInputDialog> {
  @override
  void initState() {
    super.initState();
    widget.textEditingController.text = widget.defaultValue;
    widget.textEditingController.addListener(() {
      setState(() {

      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    widget.textEditingController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [TextField(
        controller: widget.textEditingController,
        decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: widget.courseLayout.secondaryColor,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Color.lerp(
                widget.courseLayout.primaryColor,
                widget.courseLayout.secondaryColor,
                0.5,
              ),
            ),
          ),
        ),
        style: Theme.of(context)
            .textTheme
            .headline6
            .apply(color: widget.courseLayout.secondaryColor),
      ),
        Container(height: 24,),
        Text(widget.blacklist.contains(widget.textEditingController.text) ? 'File already exists.' : '', style: Theme.of(context).textTheme.subtitle1.apply(color: Colors.red),),
      ],
    );
  }
}

class _PathConfigDialog extends StatefulWidget {
  final CourseLayout courseLayout;
  final Function(MainPageCallBackMSG, [dynamic]) callback;
  _PathConfigDialog(
      {Key key,
      this.courseLayout,
      this.callback})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _PathConfigDialogState();
}

class _PathConfigDialogState extends State<_PathConfigDialog> {
  List<String> coursePathList = [];
  String coursePath = '';
  List<String> preferencePathList = [];
  String preferencePath = '';

  @override
  void initState() {
    super.initState();
    loadDB()
    .then((_) => setState(() {}));
  }

  Future loadDB() async {
    List<Map> coursePaths =
    await PathProvider.getInstance().getPathByType(PATH_TYPE.COURSE);
    coursePathList = coursePaths.map((e) => e[COLUMN_PATH_NAME] as String).toList();
    coursePath = coursePaths.firstWhere(
            (element) => element[COLUMN_PATH_IN_USE] == 1)[COLUMN_PATH_NAME];
    List<Map> preferencePaths = await PathProvider.getInstance().getPathByType(PATH_TYPE.PREF);
    preferencePathList = preferencePaths.map((e) => e[COLUMN_PATH_NAME] as String).toList();
    preferencePath = preferencePaths.firstWhere(
            (element) => element[COLUMN_PATH_IN_USE] == 1)[COLUMN_PATH_NAME];
  }

  Widget getDropDownButton(
      List<String> items, String value, Function(String) onChanged, Function() onDeleted) {
    return Row(
      children: [
        Expanded(
          child: DropdownButton<String>(
            isExpanded: true,
            dropdownColor: widget.courseLayout.primaryColor,
            value: value,
            icon: Icon(Icons.keyboard_arrow_down),
            iconSize: 24,
            elevation: 4,
            style: Theme.of(context)
                .textTheme
                .subtitle1
                .apply(color: widget.courseLayout.secondaryColor),
            underline: Container(
              height: 2,
              color: Colors.deepPurpleAccent,
            ),
            onChanged: onChanged,
            items: [
              for (String path in items)
                DropdownMenuItem(
                  value: path,
                  child: Container(
                    child: Text(
                      path,
                      style: Theme.of(context)
                          .textTheme
                          .subtitle2
                          .apply(color: widget.courseLayout.secondaryColor),
                    ),
                  ),
                ),
              DropdownMenuItem(
                value: '',
                child: Container(
                  child: Text(
                    'ADD...',
                    style: Theme.of(context)
                        .textTheme
                        .subtitle2
                        .apply(color: widget.courseLayout.secondaryColor),
                  ),
                ),
              ),
            ],
          ),
        ),
        IconButton(icon: Icon(Icons.delete), onPressed: onDeleted,),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.courseLayout.primaryColor,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            24, 48, 24, MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Course Database File',
              style: Theme.of(context)
                  .textTheme
                  .subtitle1
                  .apply(color: widget.courseLayout.secondaryColor),
            ),
            getDropDownButton(coursePathList, coursePath, (val) async {
              if (val != '')
                setState(() {
                  coursePath = val;
                  PathProvider.getInstance().setInUse(PATH_TYPE.COURSE, val);
                });
              else {
                TextEditingController textEditingController =
                    TextEditingController();
                String filename = await showDialog(
                  context: context,
                  child: AlertDialog(
                    backgroundColor: widget.courseLayout.primaryColor,
                    content: _TextInputDialog(
                      textEditingController: textEditingController,
                      blacklist: coursePathList,
                      defaultValue: 'New File',
                      courseLayout: widget.courseLayout,
                    ),
                    actions: [
                      FlatButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Cancel',
                          style: Theme.of(context)
                              .textTheme
                              .subtitle1
                              .apply(color: widget.courseLayout.secondaryColor),
                        ),
                      ),
                      FlatButton(
                        onPressed: () {
                          if (!coursePathList.contains(textEditingController.text))
                          Navigator.pop(context, textEditingController.text);
                        },
                        child: Text('CONFIRM',
                            style: Theme.of(context).textTheme.subtitle1.apply(
                                color: widget.courseLayout.secondaryColor)),
                      ),
                    ],
                  ),
                );
                if (filename != null) {
                  await PathProvider.getInstance()
                      .createPath(PATH_TYPE.COURSE, filename);
                  await PathProvider.getInstance()
                      .setInUse(PATH_TYPE.COURSE, filename);
                  coursePathList.add(filename);
                  setState(() {
                    coursePath = filename;
                  });
                }
              }
              widget.callback?.call(MainPageCallBackMSG.RELOAD_DB, PATH_TYPE.COURSE);
            }, () async {
              await CourseProvider.getInstance().close();
              await PathProvider.getInstance().deletePath(PATH_TYPE.COURSE, coursePath);
              loadDB().then((_) => setState(() {widget.callback(MainPageCallBackMSG.RELOAD_DB, PATH_TYPE.COURSE);}));
            }),
            Container(
              height: 24,
            ),
            Text(
              'Preference Database File',
              style: Theme.of(context)
                  .textTheme
                  .subtitle1
                  .apply(color: widget.courseLayout.secondaryColor),
            ),
            getDropDownButton(preferencePathList, preferencePath, (val) async {
              if (val != '')
                setState(() {
                  preferencePath = val;
                  PathProvider.getInstance().setInUse(PATH_TYPE.PREF, val);
                });
              else {
                TextEditingController textEditingController =
                TextEditingController();
                String filename = await showDialog(
                  context: context,
                  child: AlertDialog(
                    backgroundColor: widget.courseLayout.primaryColor,
                    content: _TextInputDialog(
                      textEditingController: textEditingController,
                      blacklist: preferencePathList,
                      defaultValue: 'New File',
                      courseLayout: widget.courseLayout,
                    ),
                    actions: [
                      FlatButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Cancel',
                          style: Theme.of(context)
                              .textTheme
                              .subtitle1
                              .apply(color: widget.courseLayout.secondaryColor),
                        ),
                      ),
                      FlatButton(
                        onPressed: () {
                          if (!preferencePathList.contains(textEditingController.text))
                            Navigator.pop(context, textEditingController.text);
                        },
                        child: Text('CONFIRM',
                            style: Theme.of(context).textTheme.subtitle1.apply(
                                color: widget.courseLayout.secondaryColor)),
                      ),
                    ],
                  ),
                );
                if (filename != null) {
                  await PathProvider.getInstance()
                      .createPath(PATH_TYPE.PREF, filename);
                  await PathProvider.getInstance()
                      .setInUse(PATH_TYPE.PREF, filename);
                  preferencePathList.add(filename);
                  setState(() {
                    preferencePath = filename;
                  });
                }
              }
              widget.callback?.call(MainPageCallBackMSG.RELOAD_DB, PATH_TYPE.PREF);
            }, () async {
              await PreferenceProvider.getInstance().close();
              await PathProvider.getInstance().deletePath(PATH_TYPE.PREF, preferencePath);
              loadDB().then((_) => setState(() {widget.callback(MainPageCallBackMSG.RELOAD_DB, PATH_TYPE.PREF);}));
            }),
            Container(
              height: 24,
            ),
          ],
        ),
      ),
    );
  }
}
