import 'dart:ui';

import 'package:course_timetable_remake/DBPreference.dart';
import 'package:course_timetable_remake/Dialog.dart';
import 'package:course_timetable_remake/Preference.dart';
import 'package:course_timetable_remake/Resources.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:intl/intl.dart';

import 'Course.dart';
import 'MessageSnackBar.dart';
import 'Session.dart';
import 'generated/l10n.dart';

class Timetable extends StatefulWidget {
  final List<Course> courses;
  final List<Session> sessions;
  final CourseLayout courseLayout;
  final PreferenceProvider preferenceProvider;
  final void Function() saveCourseToDB;
  final void Function(Function()) refresh;

  Timetable(
      {this.refresh,
      this.saveCourseToDB,
      this.preferenceProvider,
      this.courses = const [],
      this.sessions = const [],
      this.courseLayout = const CourseLayout.light(),
      Key key})
      : super(key: key);

  @override
  State createState() => _TimetableState();
}

class _TimetableState extends State<Timetable> with TickerProviderStateMixin {
  bool editMode = false;
  GlobalKey _sessionKey = GlobalKey();
  GlobalKey _courseKey = GlobalKey();
  AnimationController _animationController;
  double _sessionWidth = 40;
  Size _courseSize = Size(40, 40);
  double _barHeight = 35;
  List<bool> chosen;
  Course copiedCourse;
  Map prefs = Map<PREF_TYPE, Preference>();

  void setEditMode(bool val) {
    if (val == editMode) return;
    copiedCourse = null;
    if (val) {
      _animationController.forward();
      HapticFeedback.vibrate();
    } else {
      _animationController.reverse();
      widget.saveCourseToDB?.call();
    }
    editMode = val;
  }

  Widget getSessionCell(Session session, bool asConstraint) {
    return Container(
      key: asConstraint ? _sessionKey : null,
      color: widget.courseLayout.primaryColor,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              session.name,
              softWrap: false,
              overflow: TextOverflow.fade,
              style: Theme.of(context).textTheme.bodyText2.apply(color: widget.courseLayout.secondaryColor),
            ),
            Container(height: 6,),
            Text(
              DateFormat('HH:mm').format(session.begin),
              style: Theme.of(context).textTheme.caption.apply(color: widget.courseLayout.secondaryColor),
            ),
            Container(height: 2,),
            RotatedBox(
              quarterTurns: 1,
              child: Text(
                '~',
                style: Theme.of(context).textTheme.caption.apply(color: widget.courseLayout.secondaryColor),
              ),
            ),
            Container(height: 2,),
            Text(
              DateFormat('HH:mm').format(session.end),
              style: Theme.of(context).textTheme.caption.apply(color: widget.courseLayout.secondaryColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget getCourseCell(Course course, int index, {bool asConstraint = false}) {
    Widget main = Padding(
      padding: EdgeInsets.fromLTRB(4, 8, 4, 12),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            course.name,
            softWrap: false,
            maxLines: 2,
            style: Theme.of(context).textTheme.caption.apply(color: chosen[index] ? widget.courseLayout.primaryColor : widget.courseLayout.secondaryColor, fontSizeFactor: prefs[PREF_TYPE.CONFIG_NAME_SIZE].value),
            overflow: TextOverflow.ellipsis,
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (course.room.isNotEmpty)
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: course.color,
                      borderRadius: BorderRadius.all(
                        Radius.circular(5),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(2, 2, 2, 2),
                      child: Text(
                        course.room,
                        textAlign: TextAlign.center,
                        softWrap: false,
                        style: Theme.of(context).textTheme.caption.apply(color: prefs[PREF_TYPE.CONFIG_ROOM_COLOR].value == COLOR_MODE.LIGHT ? Colors.white : prefs[PREF_TYPE.CONFIG_ROOM_COLOR].value == COLOR_MODE.DARK ? Colors.black : useWhiteForeground(course.color) ? Colors.white : Colors.black, fontSizeFactor: prefs[PREF_TYPE.CONFIG_ROOM_SIZE].value),
                        overflow: TextOverflow.fade,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );

    Widget bodyNormal = Expanded(
      key: asConstraint ? _courseKey : null,
      child: GestureDetector(
        onLongPress: editMode
            ? null
            : () {
                setState(() {
                  chosen[index] = true;
                  setEditMode(true);
                });
              },
        onTap: editMode
            ? () {
                setState(() {
                  chosen[index] = !chosen[index];
                  if (chosen.every((element) => !element)) setEditMode(false);
                });
              }
            : null,
        child: Stack(
          children: [
            Transform(
              transform: Matrix4.identity()
                ..translate(0.2)
                ..scale(1.2, 1, 1),
              child: Container(
                color: chosen[index] ? Colors.transparent : widget.courseLayout.primaryColor,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: chosen[index] ? Colors.transparent : widget.courseLayout.primaryColor,
                border: Border(
                  left: BorderSide(
                    color: widget.courseLayout.primaryColor,
                    width: 4,
                  ),
                ),
              ),
              child: main,
            ),
          ],
        ),
      ),
    );

    Widget Function(bool) body = (highlight) => GestureDetector(
          onLongPress: editMode
              ? null
              : () {
                  setState(() {
                    chosen[index] = true;
                    setEditMode(true);
                  });
                },
          onTap: editMode
              ? () {
                  setState(() {
                    chosen[index] = !chosen[index];
                    if (chosen.every((element) => !element)) setEditMode(false);
                  });
                }
              : null,
          child: Stack(
            children: [
              Transform(
                transform: Matrix4.identity()..translate(0.2),
                child: Container(
                  color: chosen[index] ? Colors.transparent : widget.courseLayout.primaryColor,
                ),
              ),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: highlight
                      ? Color.lerp(widget.courseLayout.primaryColor, widget.courseLayout.secondaryColor, 0.5)
                      : chosen[index] ? Colors.transparent : widget.courseLayout.primaryColor,
                  border: Border(
                    left: BorderSide(
                      color: widget.courseLayout.primaryColor,
                      width: 4,
                    ),
                  ),
                ),
                child: main,
              ),
            ],
          ),
        );

    Widget bodyFeedback = Container(
      width: _courseSize.width,
      height: _courseSize.height,
      decoration: BoxDecoration(
        color: chosen[index] ? widget.courseLayout.secondaryColor : widget.courseLayout.primaryColor,
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(150, 0, 0, 0),
            spreadRadius: 5,
            blurRadius: 5,
          )
        ],
      ),
      child: main,
    );

    return editMode
        ? Expanded(
            child: DragTarget<int>(
                builder: (context, candidates, rejects) => LongPressDraggable(
                      child: body(candidates.length > 0),
                      feedback: bodyFeedback,
                      childWhenDragging: Transform(
                        transform: Matrix4.identity()
                          ..scale(1.05, 1, 1)
                          ..translate(-0.1),
                        child: Container(color: widget.courseLayout.primaryColor),
                      ),
                      data: index,
                    ),
                onWillAccept: (data) {
                  return true;
                },
                onAccept: (data) {
                  setState(() {
                    Course course = widget.courses[data];
                    bool chosenStatus = chosen[data];
                    widget.courses[data] = widget.courses[index];
                    chosen[data] = chosen[index];
                    widget.courses[index] = course;
                    chosen[index] = chosenStatus;
                  });
                }),
          )
        : bodyNormal;
  }

  Widget getRow(Session session, int sessionIndex, bool isLast, List<Course> courses) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 0, 0, isLast ? 0 : 2.5),
      child: Container(
        child: IntrinsicHeight(
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              getSessionCell(session, sessionIndex == 0),
              ...courses.asMap().entries.map(
                (e) {
                  int rowIndex = e.key;
                  Course course = e.value;
                  int courseIndex = sessionIndex * 7 + rowIndex;
                  return getCourseCell(course, courseIndex, asConstraint: courseIndex == 0);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getMainBody() {
    return Stack(
      children: [
        Container(
          color: widget.courseLayout.primaryColor,
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(0.5, 0.99),
              end: Alignment(0.5, 1),
              colors: [widget.courseLayout.secondaryColor, widget.courseLayout.primaryColor],
            ),
          ),
          child: ScrollConfiguration(
            behavior: _TimetableListViewBehaviour(),
            child: ListView(
              shrinkWrap: true,
              children: [
                ...widget.sessions.asMap().entries.map((e) {
                  int index = e.key;
                  Session session = e.value;
                  return getRow(
                    session,
                    index,
                    index == widget.sessions.length - 1,
                    widget.courses.sublist(7 * index, 7 * index + 7),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void updateWidgetSize() {
    RenderBox renderBox = _sessionKey.currentContext?.findRenderObject();
    double width = renderBox?.size?.width;
    if (width != null && _sessionWidth != width)
      setState(() {
        _sessionWidth = width;
      });
    renderBox = _courseKey.currentContext?.findRenderObject();
    Size size = renderBox?.size;
    if (size != null && size != _courseSize)
      setState(() {
        size = Size(size.width - 4, size.height);
        _courseSize = size;
      });
  }

  @override
  void initState() {
    super.initState();
    chosen = List();
    chosen.addAll(List.filled(widget.sessions.length * 7, false));
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
      reverseDuration: Duration(milliseconds: 400),
    );
    updateWidgetSize();
    widget.refresh(() {
      setState(() {
        fetchDB();
      });
    });
    PREF_TYPE.values.forEach((element) {
      prefs[element] = Preference(element);
    });
  }

  void fetchDB() async {
    prefs = await widget.preferenceProvider?.getPreferences();
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
  }

  @override
  void didUpdateWidget(Timetable oldWidget) {
    super.didUpdateWidget(oldWidget);
    updateWidgetSize();
  }

  @override
  Widget build(BuildContext context) {
    while (chosen.length < widget.sessions.length * 7) chosen.add(false);
    while (chosen.length > widget.sessions.length * 7) chosen.removeLast();
    updateWidgetSize();
    return WillPopScope(
      onWillPop: editMode
          ? () async {
              setState(() {
                chosen.fillRange(0, chosen.length, false);
                setEditMode(false);
              });
              return false;
            }
          : null,
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(0, _barHeight, 0, 0),
            child: getMainBody(),
          ),
          _WeekBar(
            courseLayout: widget.courseLayout,
            blankWidth: _sessionWidth,
            height: _barHeight,
            dayOfWeekSize: prefs[PREF_TYPE.CONFIG_WEEK_SIZE].value,
          ),
          _EditToolBar(
            animationController: _animationController,
            courseLayout: widget.courseLayout,
            height: _barHeight,
            chosenCount: chosen.where((element) => element).toList().length,
            hasCopied: copiedCourse != null,
            callback: (EditToolType editToolType) async {
              switch (editToolType) {
                case EditToolType.ADD:
                  int chosenCount = chosen.where((element) => element).toList().length;
                  if (chosenCount < 1)
                    MessageSnackBar.showSnackBar(
                      context,
                      "Please choose at least one course.",
                      widget.courseLayout,
                      duration: Duration(milliseconds: 750),
                    );
                  else {
                    List<int> chosenIndex = chosen.asMap().entries.where((element) => element.value).map((e) => e.key).toList();
                    Course defaultCourse = chosenIndex.map((e) => widget.courses[e]).fold(Course.nullValue(), (value, element) {
                      if (value.name == null)
                        value.name = element.name;
                      else if (value.name != element.name) value.name = '';
                      if (value.room == null)
                        value.room = element.room;
                      else if (value.room != element.room) value.room = '';
                      if (value.color == null)
                        value.color = element.color;
                      else if (value.color.value != element.color.value) value.color = Colors.pink.shade700;
                      if (value.color == null) value.color = Colors.pink.shade700;
                      return value;
                    });

                    if (defaultCourse == null) defaultCourse = Course.dummy();
                    Course course = await TimetableDialog.showAddEditCourseDialog(context, widget.courseLayout, defaultCourse);
                    if (course == null) return;
                    if (course.room.isEmpty) course.color = Colors.pink.shade700;
                    chosen.asMap().entries.forEach((element) {
                      int index = element.key;
                      bool val = element.value;
                      if (val) widget.courses[index] = course;
                    });
                    chosen.setAll(
                      0,
                      List.filled(
                        chosen.length,
                        false,
                      ),
                    );
                  }
                  break;
                case EditToolType.COPY:
                  int chosenCount = chosen.where((element) => element).toList().length;
                  if (chosenCount < 1)
                    MessageSnackBar.showSnackBar(
                      context,
                      "Please choose at least one course.",
                      widget.courseLayout,
                      duration: Duration(milliseconds: 750),
                    );
                  else if (chosenCount > 1)
                    MessageSnackBar.showSnackBar(
                      context,
                      "Please choose exactly one course.",
                      widget.courseLayout,
                      duration: Duration(milliseconds: 750),
                    );
                  else {
                    copiedCourse = widget.courses[chosen.indexOf(true)];
                    chosen.setAll(
                      0,
                      List.filled(
                        chosen.length,
                        false,
                      ),
                    );
                  }
                  break;
                case EditToolType.PASTE:
                  int chosenCount = chosen.where((element) => element).toList().length;
                  if (chosenCount <= 0)
                    MessageSnackBar.showSnackBar(context, 'Please choose at least one course.', widget.courseLayout);
                  else {
                    chosen.asMap().entries.forEach((element) {
                      int index = element.key;
                      bool val = element.value;
                      if (val) widget.courses[index] = copiedCourse;
                    });
                    chosen.setAll(
                      0,
                      List.filled(
                        chosen.length,
                        false,
                      ),
                    );
                  }
                  break;
                case EditToolType.DELETE:
                  int chosenCount = chosen.where((element) => element).toList().length;
                  if (chosenCount <= 0)
                    MessageSnackBar.showSnackBar(context, 'Please choose at least one course.', widget.courseLayout);
                  else {
                    chosen.asMap().entries.forEach((element) {
                      int index = element.key;
                      bool val = element.value;
                      if (val) widget.courses[index] = Course.empty();
                    });
                    chosen.setAll(
                      0,
                      List.filled(
                        chosen.length,
                        false,
                      ),
                    );
                  }
                  break;
                case EditToolType.DELETE_ALL:
                  widget.courses.setAll(
                    0,
                    List.filled(
                      widget.courses.length,
                      Course.empty(),
                    ),
                  );
                  chosen.setAll(
                    0,
                    List.filled(
                      chosen.length,
                      false,
                    ),
                  );
                  break;
              }
              setState(() {});
            },
          ),
        ],
      ),
    );
  }
}

class _TimetableListViewBehaviour extends ScrollBehavior {
  @override
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

class _WeekBar extends StatelessWidget {
  final CourseLayout courseLayout;
  final double blankWidth;
  final double height;
  final double dayOfWeekSize;
  _WeekBar({this.dayOfWeekSize, this.courseLayout = const CourseLayout.light(), this.blankWidth, this.height, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<String> week = S.of(context).weekDays.split(',');
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        decoration: BoxDecoration(
          color: courseLayout.primaryColor,
          boxShadow: [
            BoxShadow(
              color: Color.fromARGB(100, 10, 10, 10),
              offset: Offset(0.0, 1.0),
              blurRadius: 3,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              width: blankWidth,
              height: height,
            ),
            for (String day in week)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(4, 8, 0, 4),
                  child: Text(
                    day,
                    style: Theme.of(context).textTheme.caption.apply(
                          color: courseLayout.secondaryColor,
                          fontSizeFactor: dayOfWeekSize,
                        ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

enum EditToolType {
  ADD,
  COPY,
  PASTE,
  DELETE,
  DELETE_ALL,
}

class _EditToolBar extends StatefulWidget {
  final CourseLayout courseLayout;
  final double height;
  final bool hasCopied;
  final int chosenCount;
  final AnimationController animationController;
  final void Function(EditToolType) callback;
  _EditToolBar({this.hasCopied, this.chosenCount, this.courseLayout, this.callback, this.height, this.animationController, Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _EditToolBarState();
}

class _EditToolBarState extends State<_EditToolBar> {
  Animation _animation;

  Widget getOperationButton(IconData icon, String tooltip, EditToolType editToolType) => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          child: IconButton(
            icon: Icon(
              icon,
              color: widget.courseLayout.secondaryColor,
            ),
            tooltip: tooltip,
            onPressed: () {
              widget.callback(editToolType);
            },
          ),
        ),
      );

  List<Widget> getOperationButtons() {
    List<Widget> result = [
      getOperationButton(
        Icons.edit,
        widget.chosenCount > 1 ? S.of(context).mainPageDrawerAddEdit : S.of(context).mainPageDrawerAddEditSingle,
        EditToolType.ADD,
      ),
      getOperationButton(
        Icons.content_copy,
        S.of(context).mainPageDrawerCopy,
        EditToolType.COPY,
      ),
      getOperationButton(
        Icons.content_paste,
        widget.chosenCount > 1 ? S.of(context).mainPageDrawerPaste : S.of(context).mainPageDrawerPasteSingle,
        EditToolType.PASTE,
      ),
      getOperationButton(
        Icons.delete,
        widget.chosenCount > 1 ? S.of(context).mainPageDrawerDelete : S.of(context).mainPageDrawerDeleteSingle,
        EditToolType.DELETE,
      ),
      getOperationButton(Icons.delete_forever, S.of(context).mainPageDrawerDeleteAll, EditToolType.DELETE_ALL),
    ];

    if (!widget.hasCopied) result.removeAt(2);
    return result;
  }

  @override
  void initState() {
    super.initState();
    _animation = Tween<double>(begin: -widget.height, end: 0).chain(CurveTween(curve: Curves.fastOutSlowIn)).animate(widget.animationController)
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: _animation.value,
      left: 0,
      right: 0,
      child: Container(
        height: widget.height,
        decoration: BoxDecoration(
          color: widget.courseLayout.primaryColor,
          boxShadow: [
            BoxShadow(
              color: Color.fromARGB(100, 10, 10, 10),
              offset: Offset(0.0, 1.0),
              blurRadius: 3,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: getOperationButtons(),
        ),
      ),
    );
  }
}
