import '../../../home/domain/entities/character.dart';
import '../repositories/favorite_repository.dart';

class ToggleFavorite {
  final FavoriteRepository repository;

  const ToggleFavorite(this.repository);

  Future<bool> call(Character character) async {
    final alreadyFavorite = await repository.isFavorite(character.id);
    if (alreadyFavorite) {
      await repository.removeFavorite(character.id);
    } else {
      await repository.addFavorite(character);
    }
    return !alreadyFavorite;
  }
}
