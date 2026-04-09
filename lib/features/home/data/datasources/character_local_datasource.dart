import 'dart:convert';
import '../../../../core/error/exceptions.dart';
import '../../../../core/local/local_storage_service.dart';
import '../models/character_model.dart';

abstract class CharacterLocalDataSource {
  Future<List<CharacterModel>> getCachedCharacters(int page);
  Future<void> cacheCharacters(int page, List<CharacterModel> characters);
}

class CharacterLocalDataSourceImpl implements CharacterLocalDataSource {
  final LocalStorageService _storage;

  static const _keyPrefix = 'characters_page_';

  const CharacterLocalDataSourceImpl(this._storage);

  @override
  Future<List<CharacterModel>> getCachedCharacters(int page) async {
    final json = await _storage.getString('$_keyPrefix$page');
    if (json == null) {
      throw const CacheException(message: 'No cached data for this page');
    }
    final list = jsonDecode(json) as List<dynamic>;
    return list
        .map((e) => CharacterModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> cacheCharacters(
    int page,
    List<CharacterModel> characters,
  ) async {
    final json = jsonEncode(characters.map((c) => c.toJson()).toList());
    await _storage.setString('$_keyPrefix$page', json);
  }
}
