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

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).appTitle)),
      drawer: MainPageDrawer(),
      body: Timetable(courses: [for(int i = 0; i < 7; i++) Course.dummy()], sessions: [Session.dummy()],),
    );
  }
}