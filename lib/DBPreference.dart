import 'Preference.dart';
import 'package:sqflite/sqflite.dart';

const String COLUMN_PREF_NAME = 'name';
const String COLUMN_PREF_VALUE = 'value';

const String _TABLE_NAME = 'preferences';
const String _COLUMN_ID = '_id';
const int _DB_VERSION = 2;

class PreferenceProvider {
  Database db;
  void Function() refreshTimetable;

  PreferenceProvider();

  void _onCreate(Database db, int version) async {
    await db.execute('''
        create table $_TABLE_NAME (
        $_COLUMN_ID integer primary key autoincrement,
        $COLUMN_PREF_NAME text not null,
        $COLUMN_PREF_VALUE text not null)
      ''');
    var batch = db.batch();
    for(PREF_TYPE prefType in PREF_TYPE.values)
      batch.insert(_TABLE_NAME, Preference(prefType).toMap());
    await batch.commit();
  }

  void _onUpgrade(Database db, int versionOld, int version) async {
    await db.execute('''
        drop table if exists $_TABLE_NAME
      ''');
    _onCreate(db, version);
  }

  Future open(String path) async {
    db = await openDatabase(path, version: _DB_VERSION, onCreate: _onCreate, onUpgrade: _onUpgrade, onDowngrade: _onUpgrade);
  }

  Future<Map<PREF_TYPE, Preference>> getPreferences() async {
    List<Map> maps = await db.query(_TABLE_NAME, columns: [COLUMN_PREF_NAME, COLUMN_PREF_VALUE,]);
    return await maps.map((e) {
      PREF_TYPE type = PREF_TYPE.values.firstWhere((element) => getPrefName(element) == e[COLUMN_PREF_NAME]);
      return {'TYPE' :type, 'VALUE': Preference.fromMap(e)};
    }).fold(Map<PREF_TYPE, Preference>(), (previousValue, element) {
      (previousValue as Map)[element['TYPE']] = element["VALUE"];
      return previousValue;
    });
  }

  Future<Preference> getPreference(PREF_TYPE type) async {
    int index = PREF_TYPE.values.indexOf(type);
    List<Map> maps = await db.query(_TABLE_NAME, columns: [_COLUMN_ID, COLUMN_PREF_NAME, COLUMN_PREF_VALUE,], where: '$_COLUMN_ID = ?', whereArgs: [index+1]);
    return Preference.fromMap(maps.first);
  }

  Future setPreference(Preference preference) async {
    int index = PREF_TYPE.values.indexWhere((element) => getPrefName(element) == preference.name);
    await db.update(_TABLE_NAME, preference.toMap(), where: '$_COLUMN_ID = ?', whereArgs: [index+1]);

    PREF_TYPE type = PREF_TYPE.values[index];
    if(type == PREF_TYPE.CONFIG_ROOM_COLOR || type == PREF_TYPE.CONFIG_NAME_SIZE || type == PREF_TYPE.CONFIG_ROOM_SIZE || type == PREF_TYPE.CONFIG_WEEK_SIZE)
      refreshTimetable?.call();
  }

  Future close() async => db.close();
}