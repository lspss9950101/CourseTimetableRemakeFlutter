import 'package:course_timetable_remake/Dialog.dart';
import 'package:course_timetable_remake/Preference.dart';
import 'package:course_timetable_remake/TimeOfDayRange.dart';

import 'Course.dart';
import 'DBPath.dart';
import 'DBPreference.dart';
import 'Session.dart';
import 'Timetable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'DBCourse.dart';
import 'generated/l10n.dart';
import 'MainPageDrawer.dart';
import 'Resources.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
      [
        DeviceOrientation.portraitUp,
      ],
    );
    return MaterialApp(
      title: 'Flutter Demo',
      theme: Resources.ThemeLight,
      home: MainPage(),
      localizationsDelegates: [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', ''),
        const Locale('zh', ''),
      ],
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  State createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with WidgetsBindingObserver {
  CourseProvider _courseProvider;
  PreferenceProvider _preferenceProvider;
  PathProvider _pathProvider;
  bool darkMode = false;
  List<Session> sessions = List();
  List<Course> courses = List();
  void Function({double nameSize, double roomSize, double dayOfWeekSize, COLOR_MODE roomColor}) refreshTimetable;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initDB();
  }

  Future initDB() async {
    _pathProvider = PathProvider.getInstance();
    _courseProvider = CourseProvider.getInstance();
    _preferenceProvider = PreferenceProvider.getInstance();
    Map map = await _pathProvider.getPathInUse();
    await CourseProvider.open(map[PATH_TYPE.COURSE]);
    await PreferenceProvider.open(map[PATH_TYPE.PREF]);

    refreshTimetable();

    darkMode =
        (await _preferenceProvider.getPreference(PREF_TYPE.DARK_MODE)).value;
    List sessionName =
        (await _preferenceProvider.getPreference(PREF_TYPE.SESSION_NAME)).value;
    List sessionTime =
        (await _preferenceProvider.getPreference(PREF_TYPE.SESSION_TIME)).value;
    sessions = sessionName
        .asMap()
        .entries
        .map((e) => Session(name: e.value, timeOfDayRange: sessionTime[e.key]))
        .toList();

    reloadCourse();
  }

  Future reloadCourse() async {
    courses = await _courseProvider.getCourses();
    setState(() {});
  }

  Future reloadSession() async {
    Map<PREF_TYPE, Preference> map = await _preferenceProvider.getPreferencesFromType([PREF_TYPE.SESSION_NAME, PREF_TYPE.SESSION_TIME]);
    sessions = (map[PREF_TYPE.SESSION_NAME].value as List<String>).asMap().entries.map((e) => Session(name: e.value, timeOfDayRange: map[PREF_TYPE.SESSION_TIME].value[e.key])).toList();
    await _courseProvider.applySession(sessions.length);
    reloadCourse();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _courseProvider.close();
    _pathProvider.close();
    _preferenceProvider.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _courseProvider.setCourses(courses);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).appTitle)),
      drawer: MainPageDrawer(
        preferenceProvider: _preferenceProvider,
        courseLayout: darkMode ? CourseLayout.dark() : CourseLayout.light(),
        darkMode: darkMode,
        callback: (msg, [arg]) async {
          switch (msg) {
            case MainPageCallBackMSG.SET_DARK_MODE:
              setState(() {
                darkMode = arg;
              });
              await _preferenceProvider
                  .setPreference(Preference(PREF_TYPE.DARK_MODE, arg));
              break;
            case MainPageCallBackMSG.SET_CONFIG_APPEARANCE:
              refreshTimetable(nameSize: arg['nameSize'], roomSize: arg['roomSize'], dayOfWeekSize: arg['dayOfWeekSize'], roomColor: arg['roomColor'],);
              break;
            case MainPageCallBackMSG.SET_SESSION:
              reloadSession();
              break;
          }
        },
      ),
      body: Timetable(
        courses: courses,
        sessions: sessions,
        courseLayout: darkMode ? CourseLayout.dark() : CourseLayout.light(),
        saveCourseToDB: () async {
          await _courseProvider.setCourses(courses);
          await reloadCourse();
        },
        refresh: (refresh) {
          refreshTimetable = refresh;
        },
      ),
    );
  }
}
