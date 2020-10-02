import 'dart:io';

import 'package:sqflite/sqflite.dart';

const String _COLUMN_ID = '_id';
const String COLUMN_PATH_IN_USE = 'in_use';
const String COLUMN_PATH_NAME = 'name';
const String COLUMN_PATH_TYPE = 'type';
const String _TABLE_NAME = 'path';
const int _DB_VERSION = 100;

enum PATH_TYPE {
  COURSE,
  PREF,
}

class PathProvider {
  static PathProvider instance;

  static PathProvider getInstance() => instance ?? (instance = PathProvider());

  Database db;

  PathProvider();

  void _onCreate(Database db, int version) async {
    await db.execute('''
        create table $_TABLE_NAME (
        $_COLUMN_ID integer primary key autoincrement,
        $COLUMN_PATH_TYPE text not null,
        $COLUMN_PATH_IN_USE integer not null,
        $COLUMN_PATH_NAME text not null)
      ''');
    db.insert(_TABLE_NAME, {COLUMN_PATH_NAME: 'Courses.db', COLUMN_PATH_TYPE: PATH_TYPE.COURSE.toString(), COLUMN_PATH_IN_USE: 1});
    db.insert(_TABLE_NAME, {COLUMN_PATH_NAME: 'Preferences.db', COLUMN_PATH_TYPE: PATH_TYPE.PREF.toString(), COLUMN_PATH_IN_USE: 1});
  }

  void _onUpgrade(Database db, int versionOld, int version) async {
    await db.execute('''
        drop table if exists $_TABLE_NAME
      ''');
    _onCreate(db, version);
  }

  Future<void> open() async {
    if(db != null) return;
    db = await openDatabase('path.db',
        version: _DB_VERSION,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onDowngrade: _onUpgrade);
  }

  Future<List<Map>> getPathByType(PATH_TYPE type) async {
    if(db == null) await open();
    return await db.query(_TABLE_NAME,
        columns: [
          _COLUMN_ID,
          COLUMN_PATH_NAME,
          COLUMN_PATH_IN_USE,
        ],
        where: '$COLUMN_PATH_TYPE = ?',
        whereArgs: [type.toString()]);
  }

  Future<Map<PATH_TYPE, String>> getPathInUse() async {
    if(db == null) await open();
    List<Map> maps = await db.query(_TABLE_NAME, columns: [COLUMN_PATH_TYPE, COLUMN_PATH_NAME, _COLUMN_ID], where: '$COLUMN_PATH_IN_USE = ?', whereArgs: [1]);
    Map<PATH_TYPE, String> result = Map();
    for(PATH_TYPE type in PATH_TYPE.values)
      result[type] = maps.firstWhere((element) => element[COLUMN_PATH_TYPE] == type.toString())[COLUMN_PATH_NAME];
    return result;
  }

  Future<bool> createPath(PATH_TYPE type, String name) async {
    if(db == null) await open();
    int cnt = Sqflite.firstIntValue(await db.rawQuery('''
      SELECT COUNT(*)
      FROM $_TABLE_NAME
      WHERE $COLUMN_PATH_NAME = '$name' AND $COLUMN_PATH_TYPE = '$type'
    '''));
    if (cnt == 0) {
      await db.insert(_TABLE_NAME, {
        COLUMN_PATH_TYPE: type.toString(),
        COLUMN_PATH_NAME: name,
        COLUMN_PATH_IN_USE: 0
      });
      return true;
    } else {
      await db.rawDelete("""
        DELETE FROM $_TABLE_NAME
        WHERE $COLUMN_PATH_TYPE = '$type' AND $COLUMN_PATH_NAME = '$name'
      """);
      await createPath(type, name);
      return false;
    }
  }

  Future setInUse(PATH_TYPE type, String name) async {
    if(db == null) await open();
    var batch = db.batch();
    batch.rawUpdate("""
      UPDATE $_TABLE_NAME
      SET $COLUMN_PATH_IN_USE=0
      WHERE $COLUMN_PATH_TYPE = '$type' AND $COLUMN_PATH_NAME != '$name'
    """);
    batch.rawUpdate("""
      UPDATE $_TABLE_NAME
      SET $COLUMN_PATH_IN_USE=1
      WHERE $COLUMN_PATH_TYPE = '$type' AND $COLUMN_PATH_NAME = '$name'
    """);
    await batch.commit();
  }

  Future deletePath(PATH_TYPE type, String name) async {
    if(db == null) await open();
    bool isInUse = Sqflite.firstIntValue(await(db.rawQuery('''
      SELECT COUNT(*)
      FROM $_TABLE_NAME
      WHERE $COLUMN_PATH_TYPE = '$type' and $COLUMN_PATH_NAME = '$name' and $COLUMN_PATH_IN_USE = 1
    '''))) > 0;
    await db.rawDelete('''
      DELETE FROM $_TABLE_NAME
      WHERE $COLUMN_PATH_TYPE = '$type' AND $COLUMN_PATH_NAME = '$name'
    ''');

    String path = (await getDatabasesPath() + '/' + name);
    await deleteDatabase(path);

    int pathCount = Sqflite.firstIntValue(await(db.rawQuery('''
      SELECT COUNT(*)
      FROM $_TABLE_NAME
      WHERE $COLUMN_PATH_TYPE = '$type'
    ''')));
    if(pathCount == 0)
      await createPath(type, type == PATH_TYPE.COURSE ? 'Courses.db' : 'Preferences.db');
    if(isInUse) {
      String firstPath = (await db.query(_TABLE_NAME, columns: [COLUMN_PATH_NAME], where: '$COLUMN_PATH_TYPE = ?', whereArgs: [type.toString()]))[0][COLUMN_PATH_NAME];
      setInUse(type, firstPath);
    }
  }

  Future close() async => await db.close();
}
