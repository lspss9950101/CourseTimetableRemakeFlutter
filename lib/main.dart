import 'Dialog.dart';
import 'Preference.dart';

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
  CourseProvider courseProvider;
  PreferenceProvider preferenceProvider;
  PathProvider pathProvider;
  bool darkMode = false;
  bool initDone = false;
  List<Session> sessions = List();
  List<Course> courses = List();
  void Function(
      {double nameSize,
      double roomSize,
      double dayOfWeekSize,
      COLOR_MODE roomColor}) updateTimetable;
  GlobalKey timetableKey = GlobalKey();
  GlobalKey weekBarKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    pathProvider = PathProvider.getInstance();
    courseProvider = CourseProvider.getInstance();
    preferenceProvider = PreferenceProvider.getInstance();

    openDB()
        .then((_) => Future.wait([
              loadCourses(),
              loadPreferences(),
              loadSessions(),
            ]))
        .then((_) => updateTimetable())
        .then((_) => setState(() {
              initDone = true;
            }));
  }

  Future openDB([PATH_TYPE type]) async {
    Map path = await pathProvider.getPathInUse();
    if (type == PATH_TYPE.COURSE)
      await CourseProvider.open(path[PATH_TYPE.COURSE]);
    else if (type == PATH_TYPE.PREF)
      await PreferenceProvider.open(path[PATH_TYPE.PREF]);
    else {
      await PreferenceProvider.open(path[PATH_TYPE.PREF])
          .then((_) => CourseProvider.open(path[PATH_TYPE.COURSE]));
    }
  }

  Future loadPreferences() async {
    darkMode =
        (await preferenceProvider.getPreference(PREF_TYPE.DARK_MODE)).value;
  }

  Future loadCourses() async {
    courses = await courseProvider.getCourses();
  }

  Future loadSessions() async {
    sessions = await CourseProvider.getInstance().getSessions();
    await courseProvider.applySession(sessions.length);
    await loadCourses();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    courseProvider.close();
    pathProvider.close();
    preferenceProvider.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    courseProvider.setCourses(courses);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).appTitle)),
      drawer: Builder(
        builder: (context) => MainPageDrawer(
          timetableKey: timetableKey,
          weekBarKey: weekBarKey,
          preferenceProvider: preferenceProvider,
          courseLayout: darkMode ? CourseLayout.dark() : CourseLayout.light(),
          darkMode: darkMode,
          callback: (msg, [arg]) async {
            switch (msg) {
              case MainPageCallBackMSG.SET_DARK_MODE:
                setState(() {
                  darkMode = arg;
                });
                await preferenceProvider
                    .setPreference(Preference(PREF_TYPE.DARK_MODE, arg));
                break;
              case MainPageCallBackMSG.SET_CONFIG_APPEARANCE:
                updateTimetable(
                  nameSize: arg['nameSize'],
                  roomSize: arg['roomSize'],
                  dayOfWeekSize: arg['dayOfWeekSize'],
                  roomColor: arg['roomColor'],
                );
                break;
              case MainPageCallBackMSG.SET_SESSION:
                loadSessions().then((_) => setState(() {
                      updateTimetable();
                    }));
                break;
              case MainPageCallBackMSG.RELOAD_DB:
                if (arg == PATH_TYPE.COURSE)
                  openDB(PATH_TYPE.COURSE)
                      .then((_) => Future.wait([
                            loadCourses(),
                            loadSessions(),
                          ]))
                      .then((_) => setState(() {
                            updateTimetable();
                          }));
                else if (arg == PATH_TYPE.PREF)
                  openDB(PATH_TYPE.PREF)
                      .then((_) => loadCourses())
                      .then((_) => updateTimetable());
                break;
            }
          },
        ),
      ),
      body: Timetable(
        timetableKey: timetableKey,
        weekBarKey: weekBarKey,
        courses: courses,
        sessions: initDone ? sessions : [],
        courseLayout: darkMode ? CourseLayout.dark() : CourseLayout.light(),
        saveCourseToDB: (courses) async {
          await courseProvider.setCourses(courses);
          await loadCourses();
        },
        refresh: (refresh) {
          updateTimetable = refresh;
        },
      ),
    );
  }
}
