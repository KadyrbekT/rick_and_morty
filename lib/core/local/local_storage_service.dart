import 'package:shared_preferences/shared_preferences.dart';

/// Abstract contract for key-value local storage.
///
/// All features depend on this interface, not on [SharedPreferences] directly.
/// Swap the implementation (Hive, Isar, etc.) without touching a single datasource.
abstract class LocalStorageService {
  Future<String?> getString(String key);
  Future<void> setString(String key, String value);

  Future<List<String>?> getStringList(String key);
  Future<void> setStringList(String key, List<String> values);

  Future<void> remove(String key);
  Future<void> clear();
}

/// [SharedPreferences]-backed implementation.
class LocalStorageServiceImpl implements LocalStorageService {
  final SharedPreferences _prefs;

  const LocalStorageServiceImpl(this._prefs);

  @override
  Future<String?> getString(String key) async => _prefs.getString(key);

  @override
  Future<void> setString(String key, String value) async =>
      _prefs.setString(key, value);

  @override
  Future<List<String>?> getStringList(String key) async =>
      _prefs.getStringList(key);

  @override
  Future<void> setStringList(String key, List<String> values) async =>
      _prefs.setStringList(key, values);

  @override
  Future<void> remove(String key) async => _prefs.remove(key);

  @override
  Future<void> clear() async => _prefs.clear();
}
