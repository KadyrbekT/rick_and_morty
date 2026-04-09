import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../home/domain/entities/character.dart';
import '../repositories/favorite_repository.dart';

class ToggleFavorite implements UseCase<bool, Character> {
  final FavoriteRepository repository;

  const ToggleFavorite(this.repository);

  /// Returns [Right(true)] when the character was added,
  /// [Right(false)] when removed, [Left] on storage error.
  @override
  Future<Either<Failure, bool>> call(Character params) async {
    try {
      final alreadyFavorite = await repository.isFavorite(params.id);
      if (alreadyFavorite) {
        await repository.removeFavorite(params.id);
      } else {
        await repository.addFavorite(params);
      }
      return Right(!alreadyFavorite);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
