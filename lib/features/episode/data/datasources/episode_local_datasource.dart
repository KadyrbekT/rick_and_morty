import 'dart:convert';
import '../../../../core/error/exceptions.dart';
import '../../../../core/local/local_storage_service.dart';
import '../models/episode_model.dart';

abstract class EpisodeLocalDataSource {
  Future<List<EpisodeModel>> getCachedEpisodes(int page);
  Future<void> cacheEpisodes(int page, List<EpisodeModel> episodes);
}

class EpisodeLocalDataSourceImpl implements EpisodeLocalDataSource {
  final LocalStorageService _storage;

  static const _keyPrefix = 'episodes_page_';

  const EpisodeLocalDataSourceImpl(this._storage);

  @override
  Future<List<EpisodeModel>> getCachedEpisodes(int page) async {
    final json = await _storage.getString('$_keyPrefix$page');
    if (json == null) {
      throw const CacheException(message: 'No cached episodes for this page');
    }
    final list = jsonDecode(json) as List<dynamic>;
    return list
        .map((e) => EpisodeModel.fromCacheJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> cacheEpisodes(int page, List<EpisodeModel> episodes) async {
    final json = jsonEncode(episodes.map((e) => e.toJson()).toList());
    await _storage.setString('$_keyPrefix$page', json);
  }
}
