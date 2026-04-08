import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../home/data/models/character_model.dart';
import '../../../home/domain/entities/character.dart';
import '../../domain/repositories/favorite_repository.dart';

class FavoriteRepositoryImpl implements FavoriteRepository {
  final SharedPreferences prefs;

  static const _favoriteIdsKey = 'favorite_ids';
  static const _favoriteDataKey = 'favorite_data';

  FavoriteRepositoryImpl(this.prefs);

  @override
  Future<Set<int>> getFavoriteIds() async {
    final ids = prefs.getStringList(_favoriteIdsKey) ?? [];
    return ids.map(int.parse).toSet();
  }

  @override
  Future<List<Character>> getFavorites() async {
    final json = prefs.getString(_favoriteDataKey);
    if (json == null) return [];
    final list = jsonDecode(json) as List<dynamic>;
    return list
        .map((e) => CharacterModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> addFavorite(Character character) async {
    final ids = await getFavoriteIds();
    ids.add(character.id);
    await prefs.setStringList(
      _favoriteIdsKey,
      ids.map((id) => id.toString()).toList(),
    );

    final favorites = await getFavorites();
    if (!favorites.any((c) => c.id == character.id)) {
      favorites.add(character);
      await _saveFavoriteData(favorites);
    }
  }

  @override
  Future<void> removeFavorite(int id) async {
    final ids = await getFavoriteIds();
    ids.remove(id);
    await prefs.setStringList(
      _favoriteIdsKey,
      ids.map((i) => i.toString()).toList(),
    );

    final favorites = await getFavorites();
    favorites.removeWhere((c) => c.id == id);
    await _saveFavoriteData(favorites);
  }

  @override
  Future<bool> isFavorite(int id) async {
    final ids = await getFavoriteIds();
    return ids.contains(id);
  }

  Future<void> _saveFavoriteData(List<Character> characters) async {
    final json = jsonEncode(
      characters
          .map((c) => CharacterModel.fromEntity(c).toJson())
          .toList(),
    );
    await prefs.setString(_favoriteDataKey, json);
  }
}
