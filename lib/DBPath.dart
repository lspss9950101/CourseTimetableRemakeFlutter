import 'package:sqflite/sqflite.dart';

const String _COLUMN_ID = '_id';
const String COLUMN_PATH_IN_USE = 'in_use';
const String COLUMN_PATH_NAME = 'name';
const String COLUMN_PATH_TYPE = 'type';
const String _TABLE_NAME = 'path';
const int _DB_VERSION = 1;

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
  }

  void _onUpgrade(Database db, int versionOld, int version) async {
    await db.execute('''
        drop table if exists $_TABLE_NAME
      ''');
    _onCreate(db, version);
  }

  void open(String path) async {
    db = await openDatabase(path,
        version: _DB_VERSION,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onDowngrade: _onUpgrade);
  }

  Future<List<Map>> getPathByType(PATH_TYPE type) async {
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
    List<Map> maps = await db.query(_TABLE_NAME, columns: [COLUMN_PATH_TYPE, COLUMN_PATH_NAME, _COLUMN_ID], where: '$COLUMN_PATH_IN_USE = ?', whereArgs: [1]);
    Map<PATH_TYPE, String> result = Map();
    for(PATH_TYPE type in PATH_TYPE.values)
      result[type] = maps.firstWhere((element) => element[COLUMN_PATH_TYPE] == type.toString())[COLUMN_PATH_NAME];
    return result;
  }

  Future<bool> createPath(PATH_TYPE type, String name) async {
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

  void setInUse(PATH_TYPE type, String name) async {
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

  Future close() async => await db.close();
}
