import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/character.dart';
import '../../domain/repositories/character_repository.dart';
import '../datasources/character_local_datasource.dart';
import '../datasources/character_remote_datasource.dart';

class CharacterRepositoryImpl implements CharacterRepository {
  final CharacterRemoteDataSource remoteDataSource;
  final CharacterLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  CharacterRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, Character>> getCharacterById(int id) async {
    try {
      final model = await remoteDataSource.getCharacterById(id);
      return Right(model);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, ({List<Character> characters, bool hasMore})>>
      getCharacters(
    int page, {
    String? name,
    String? status,
    String? species,
    String? type,
    String? gender,
  }) async {
    final hasFilters = (name != null && name.isNotEmpty) ||
        (status != null && status.isNotEmpty) ||
        (species != null && species.isNotEmpty) ||
        (type != null && type.isNotEmpty) ||
        (gender != null && gender.isNotEmpty);

    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getCharacters(
          page,
          name: name,
          status: status,
          species: species,
          type: type,
          gender: gender,
        );
        if (!hasFilters) {
          await localDataSource.cacheCharacters(page, result.characters);
        }
        return Right((characters: result.characters, hasMore: result.hasMore));
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      try {
        final cached = await localDataSource.getCachedCharacters(page);
        final filtered = hasFilters
            ? cached.where((c) {
                if (name != null && name.isNotEmpty) {
                  if (!c.name.toLowerCase().contains(name.toLowerCase())) return false;
                }
                if (status != null && status.isNotEmpty) {
                  if (!c.status.toLowerCase().contains(status.toLowerCase())) return false;
                }
                if (species != null && species.isNotEmpty) {
                  if (!c.species.toLowerCase().contains(species.toLowerCase())) return false;
                }
                if (type != null && type.isNotEmpty) {
                  if (!c.type.toLowerCase().contains(type.toLowerCase())) return false;
                }
                if (gender != null && gender.isNotEmpty) {
                  if (!c.gender.toLowerCase().contains(gender.toLowerCase())) return false;
                }
                return true;
              }).toList()
            : cached;
        return Right((characters: filtered, hasMore: false));
      } on CacheException catch (e) {
        return Left(NetworkFailure(e.message));
      }
    }
  }

  @override
  Future<Either<Failure, List<Character>>> getMultipleCharacters(
      List<int> ids) async {
    try {
      final models = await remoteDataSource.getMultipleCharacters(ids);
      return Right(models);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
