import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../home/domain/entities/character.dart';
import '../repositories/favorite_repository.dart';

class GetFavorites implements UseCase<List<Character>, NoParams> {
  final FavoriteRepository repository;

  const GetFavorites(this.repository);

  @override
  Future<Either<Failure, List<Character>>> call(NoParams params) async {
    try {
      final favorites = await repository.getFavorites();
      return Right(favorites);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
