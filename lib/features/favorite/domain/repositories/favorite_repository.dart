import '../../../home/domain/entities/character.dart';

abstract class FavoriteRepository {
  Future<Set<int>> getFavoriteIds();
  Future<List<Character>> getFavorites();
  Future<void> addFavorite(Character character);
  Future<void> removeFavorite(int id);
  Future<bool> isFavorite(int id);
}
