import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exceptions.dart';
import '../models/episode_model.dart';

abstract class EpisodeLocalDataSource {
  Future<List<EpisodeModel>> getCachedEpisodes(int page);
  Future<void> cacheEpisodes(int page, List<EpisodeModel> episodes);
}

class EpisodeLocalDataSourceImpl implements EpisodeLocalDataSource {
  final SharedPreferences prefs;

  static const _keyPrefix = 'episodes_page_';

  EpisodeLocalDataSourceImpl(this.prefs);

  @override
  Future<List<EpisodeModel>> getCachedEpisodes(int page) async {
    final json = prefs.getString('$_keyPrefix$page');
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
    await prefs.setString('$_keyPrefix$page', json);
  }
}
