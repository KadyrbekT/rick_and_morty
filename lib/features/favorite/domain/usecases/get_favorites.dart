import '../../../home/domain/entities/character.dart';
import '../repositories/favorite_repository.dart';

class GetFavorites {
  final FavoriteRepository repository;

  const GetFavorites(this.repository);

  Future<List<Character>> call() => repository.getFavorites();
}
