import 'package:course_timetable_remake/Dialog.dart';
import 'package:course_timetable_remake/Preference.dart';

import 'Course.dart';
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
  String dbCoursePath = 'course.db';
  String dbPreferencePath = 'preference.db';
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
    _courseProvider = CourseProvider();
    _preferenceProvider = PreferenceProvider();
    await _courseProvider.open(dbCoursePath);
    await _preferenceProvider.open(dbPreferencePath);

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
        .map((e) => Session.fromDateTimeRange(e.value, sessionTime[e.key]))
        .toList();

    reloadCourse();
  }

  Future reloadCourse() async {
    courses = await _courseProvider.getCourses();
    setState(() {});
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _courseProvider.close();
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
        callback: (msg, arg) async {
          switch (msg) {
            case MainPageCallBackMSG.SET_DARK_MODE:
              setState(() {
                darkMode = arg;
              });
              await _preferenceProvider
                  .setPreference(Preference.raw(PREF_TYPE.DARK_MODE, arg));
              break;
            case MainPageCallBackMSG.SET_CONFIG_APPEARANCE:
              refreshTimetable(nameSize: arg['nameSize'], roomSize: arg['roomSize'], dayOfWeekSize: arg['dayOfWeekSize'], roomColor: arg['roomColor'],);
              break;
          }
        },
      ),
      body: Timetable(
        courses: courses,
        sessions: sessions,
        courseLayout: darkMode ? CourseLayout.dark() : CourseLayout.light(),
        preferenceProvider: _preferenceProvider,
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
