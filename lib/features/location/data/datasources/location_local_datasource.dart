import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exceptions.dart';
import '../models/location_model.dart';

abstract class LocationLocalDataSource {
  Future<List<LocationModel>> getCachedLocations(int page);
  Future<void> cacheLocations(int page, List<LocationModel> locations);
}

class LocationLocalDataSourceImpl implements LocationLocalDataSource {
  final SharedPreferences prefs;

  static const _keyPrefix = 'locations_page_';

  LocationLocalDataSourceImpl(this.prefs);

  @override
  Future<List<LocationModel>> getCachedLocations(int page) async {
    final json = prefs.getString('$_keyPrefix$page');
    if (json == null) {
      throw const CacheException(message: 'No cached locations for this page');
    }

    final list = jsonDecode(json) as List<dynamic>;
    return list
        .map((e) => LocationModel.fromCacheJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> cacheLocations(int page, List<LocationModel> locations) async {
    final json = jsonEncode(locations.map((l) => l.toJson()).toList());
    await prefs.setString('$_keyPrefix$page', json);
  }
}
