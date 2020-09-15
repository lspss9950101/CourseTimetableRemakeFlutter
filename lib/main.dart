import 'package:course_timetable_remake/Course.dart';
import 'package:course_timetable_remake/Session.dart';
import 'package:course_timetable_remake/Timetable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'generated/l10n.dart';
import 'MainPageDrawer.dart';
import 'Resources.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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

class _MainPageState extends State<MainPage> {
  bool darkMode = false;
  List<Session> sessions = List.filled(3, Session.dummy());
  List<Course> courses = List.filled(21, Course.dummy());
  List<bool> chosen = List.filled(21, false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).appTitle)),
      drawer: MainPageDrawer(courseLayout: darkMode ? CourseLayout.dark() : CourseLayout.light(), darkMode: darkMode, callback: (msg, arg) {
        switch(msg) {
          case MainPageCallBackMSG.SET_DARK_MODE:
            setState(() {
              darkMode = arg;
            });
            break;
        }
      },),
      body: Timetable(courses: courses, sessions: sessions, chosen: chosen, courseLayout: darkMode ? CourseLayout.dark() : CourseLayout.light(),),
    );
  }
}