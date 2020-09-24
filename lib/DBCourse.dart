import 'package:sqflite/sqflite.dart';

import 'Course.dart';

const String _TABLE_NAME = 'courses';
const String _COLUMN_ID = '_id';
const String COLUMN_COURSE_NAME = 'name';
const String COLUMN_COURSE_ROOM = 'room';
const String COLUMN_COURSE_COLOR = 'color';
const int _DB_VERSION = 2;

class CourseProvider {
  static CourseProvider instance;

  static CourseProvider getInstance() => instance ?? (instance = CourseProvider());

  Database db;

  static void _onCreate(Database db, int version) async {
    await db.execute('''
        create table $_TABLE_NAME (
        $_COLUMN_ID integer primary key autoincrement,
        $COLUMN_COURSE_NAME text not null,
        $COLUMN_COURSE_ROOM text not null,
        $COLUMN_COURSE_COLOR integer not null)
      ''');
    var batch = db.batch();
    for(int i = 0; i < 7*13; i++)
      batch.insert(_TABLE_NAME, Course.empty().toMap());
    await batch.commit();
  }

  static void _onUpgrade(Database db, int versionOld, int version) async {
    await db.execute('''
        drop table if exists $_TABLE_NAME
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
    for(Course course in courses)
      batch.insert(_TABLE_NAME, course.toMap());
    await batch.commit();
  }
  
  Future close() async => db.close();
}