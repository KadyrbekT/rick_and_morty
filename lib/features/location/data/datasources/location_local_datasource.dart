import 'dart:convert';
import '../../../../core/error/exceptions.dart';
import '../../../../core/local/local_storage_service.dart';
import '../models/location_model.dart';

abstract class LocationLocalDataSource {
  Future<List<LocationModel>> getCachedLocations(int page);
  Future<void> cacheLocations(int page, List<LocationModel> locations);
}

class LocationLocalDataSourceImpl implements LocationLocalDataSource {
  final LocalStorageService _storage;

  static const _keyPrefix = 'locations_page_';

  const LocationLocalDataSourceImpl(this._storage);

  @override
  Future<List<LocationModel>> getCachedLocations(int page) async {
    final json = await _storage.getString('$_keyPrefix$page');
    if (json == null) {
      throw const CacheException(message: 'No cached locations for this page');
    }
    final list = jsonDecode(json) as List<dynamic>;
    return list
        .map((e) => LocationModel.fromCacheJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> cacheLocations(
    int page,
    List<LocationModel> locations,
  ) async {
    final json = jsonEncode(locations.map((l) => l.toJson()).toList());
    await _storage.setString('$_keyPrefix$page', json);
  }
}
