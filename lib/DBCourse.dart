import 'Preference.dart';
import 'TimeOfDayRange.dart';
import 'package:sqflite/sqflite.dart';

import 'Course.dart';
import 'Session.dart';

const String _TABLE_NAME = 'courses';
const String _TABLE_NAME_SESSION = 'sessions';
const String _COLUMN_ID = '_id';
const String COLUMN_COURSE_NAME = 'name';
const String COLUMN_COURSE_ROOM = 'room';
const String COLUMN_COURSE_COLOR = 'color';

const String COLUMN_PREF_TYPE = 'type';
const String COLUMN_PREF_VALUE = 'value';

const int _DB_VERSION = 300;

class CourseProvider {
  static CourseProvider instance;

  static CourseProvider getInstance() => instance ?? (instance = CourseProvider());

  Database db;

  static void _onCreate(Database db, int version) async {
    await db.execute('''
        create table $_TABLE_NAME (
        $_COLUMN_ID integer primary key,
        $COLUMN_COURSE_NAME text not null,
        $COLUMN_COURSE_ROOM text not null,
        $COLUMN_COURSE_COLOR integer not null)
      ''');
    await db.execute('''
        create table $_TABLE_NAME_SESSION (
        $_COLUMN_ID integer primary key,
        $COLUMN_PREF_TYPE text not null,
        $COLUMN_PREF_VALUE text not null)
    ''');
    var batch = db.batch();
    for(int i = 0; i < 7*13; i++)
      batch.insert(_TABLE_NAME, Course.empty().toMap()..addEntries([MapEntry(_COLUMN_ID, i+1)]));
    batch.insert(_TABLE_NAME_SESSION, Preference.byDefault(PREF_TYPE.SESSION_NAME).toMap());
    batch.insert(_TABLE_NAME_SESSION, Preference.byDefault(PREF_TYPE.SESSION_TIME).toMap());
    await batch.commit();
  }

  static void _onUpgrade(Database db, int versionOld, int version) async {
    await db.execute('''
        drop table if exists $_TABLE_NAME
      ''');
    await db.execute('''
        drop table if exists $_TABLE_NAME_SESSION
      ''');
    _onCreate(db, version);
  }

  static Future open(String path) async {
    getInstance();
    if(instance.db != null) await instance.close();
    instance.db = await openDatabase(path, version: _DB_VERSION, onCreate: _onCreate, onUpgrade: _onUpgrade, onDowngrade: _onUpgrade);
  }

  Future<List<Course>> getCourses() async {
    List<Map> maps = await db.query(_TABLE_NAME, columns: [COLUMN_COURSE_NAME, COLUMN_COURSE_ROOM, COLUMN_COURSE_COLOR]);
    return maps.map((e) => Course.fromMap(e)).toList();
  }
  
  Future setCourses(List<Course> courses) async {
    var batch = db.batch();
    batch.delete(_TABLE_NAME);
    courses.asMap().entries.forEach((e) {
      batch.insert(_TABLE_NAME, e.value.toMap()
        ..addEntries([MapEntry(_COLUMN_ID, e.key+1)]));
    });
    await batch.commit();
  }

  Future<List<Session>> getSessions() async {
    List<Preference> prefs = (await db.query(_TABLE_NAME_SESSION, columns: [COLUMN_PREF_TYPE, COLUMN_PREF_VALUE])).map((e) => Preference.fromMap(e)).toList();
    Preference name = prefs.firstWhere((element) => element.type==PREF_TYPE.SESSION_NAME);
    Preference value = prefs.firstWhere((element) => element.type==PREF_TYPE.SESSION_TIME);
    return List.generate(name.value.length, (index) => Session(name: name.value[index], timeOfDayRange: value.value[index]));
  }

  Future setSessions(List<Session> sessions) async {
    List<String> names = sessions.map((e) => e.name).toList();
    List<TimeOfDayRange> times = sessions.map((e) => e.timeOfDayRange).toList();
    await db.update(_TABLE_NAME_SESSION, Preference(PREF_TYPE.SESSION_NAME, names).toMap(), where: '$COLUMN_PREF_TYPE = ?', whereArgs: [PREF_TYPE.SESSION_NAME.toString()]);
    await db.update(_TABLE_NAME_SESSION, Preference(PREF_TYPE.SESSION_TIME, times).toMap(), where: '$COLUMN_PREF_TYPE = ?', whereArgs: [PREF_TYPE.SESSION_TIME.toString()]);
  }

  Future applySession(int sessionCnt) async {
    int currentCnt = Sqflite.firstIntValue(await db.rawQuery("""
    SELECT COUNT(*)
    FROM $_TABLE_NAME
    """));
    var batch = db.batch();
    while(currentCnt > sessionCnt*7) {
      batch.delete(_TABLE_NAME, where: '$_COLUMN_ID = ?', whereArgs: [currentCnt--]);
    }
    while(currentCnt < sessionCnt*7) {
      batch.insert(_TABLE_NAME, Course.empty().toMap()..addEntries([MapEntry(_COLUMN_ID, ++currentCnt)]));
    }
    await batch.commit();
  }
  
  Future close() async => db.close();
}