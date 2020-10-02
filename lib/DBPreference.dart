import 'Preference.dart';
import 'package:sqflite/sqflite.dart';

const String COLUMN_PREF_TYPE = 'type';
const String COLUMN_PREF_VALUE = 'value';

const String _TABLE_NAME = 'preferences';
const String _COLUMN_ID = '_id';
const int _DB_VERSION = 200;

class PreferenceProvider {
  static PreferenceProvider instance;

  static PreferenceProvider getInstance() => instance ?? (instance = PreferenceProvider());

  Database db;

  PreferenceProvider();

  static void _onCreate(Database db, int version) async {
    await db.execute('''
        create table $_TABLE_NAME (
        $_COLUMN_ID integer primary key autoincrement,
        $COLUMN_PREF_TYPE text not null,
        $COLUMN_PREF_VALUE text not null)
      ''');
    var batch = db.batch();
    for(PREF_TYPE prefType in PREF_TYPE.values)
      if(prefType != PREF_TYPE.SESSION_NAME && prefType != PREF_TYPE.SESSION_TIME)
        batch.insert(_TABLE_NAME, Preference.byDefault(prefType).toMap());
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
    if(instance.db != null) await instance.db.close();
    instance.db = await openDatabase(path, version: _DB_VERSION, onCreate: _onCreate, onUpgrade: _onUpgrade, onDowngrade: _onUpgrade);
  }

  Future<Map<PREF_TYPE, Preference>> getPreferences() async {
    List<Map> maps = await db.query(_TABLE_NAME, columns: [COLUMN_PREF_TYPE, COLUMN_PREF_VALUE,]);
    Map<PREF_TYPE, Preference> result = Map();
    maps.forEach((element) {
      Preference preference = Preference.fromMap(element);
      result[preference.type] = preference;
    });
    return result;
  }

  Future<Preference> getPreference(PREF_TYPE type) async {
    List<Map> maps = await db.query(_TABLE_NAME, columns: [COLUMN_PREF_TYPE, COLUMN_PREF_VALUE,], where: '$COLUMN_PREF_TYPE = ?', whereArgs: [type.toString()]);
    return Preference.fromMap(maps.first);
  }

  Future<Map<PREF_TYPE, Preference>> getPreferencesFromType(List<PREF_TYPE> types) async {
    List<Map> maps = (await db.query(_TABLE_NAME, columns: [COLUMN_PREF_TYPE, COLUMN_PREF_VALUE])).where((pref) => types.any((type) => type.toString() == pref[COLUMN_PREF_TYPE])).toList();
    Map<PREF_TYPE, Preference> result = Map();
    maps.forEach((element) {
      Preference preference = Preference.fromMap(element);
      result[preference.type] = preference;
    });
    return result;
  }

  Future setPreference(Preference preference) async {
    await db.update(_TABLE_NAME, preference.toMap(), where: '$COLUMN_PREF_TYPE = ?', whereArgs: [preference.type.toString()]);
  }

  Future setPreferences(List<Preference> preferences) async {
    var batch = db.batch();
    for(Preference preference in preferences) {
      batch.update(_TABLE_NAME, preference.toMap(), where: '$COLUMN_PREF_TYPE = ?', whereArgs: [preference.type.toString()]);
    }
    await batch.commit();
  }

  Future close() async => db.close();
}