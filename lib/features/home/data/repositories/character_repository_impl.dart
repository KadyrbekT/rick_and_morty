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
  Future<Either<Failure, ({List<Character> characters, bool hasMore})>>
      getCharacters(int page, {String? name}) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getCharacters(page, name: name);
        // Cache only main list (no search queries)
        if (name == null || name.isEmpty) {
          await localDataSource.cacheCharacters(page, result.characters);
        }
        return Right((characters: result.characters, hasMore: result.hasMore));
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      try {
        final cached = await localDataSource.getCachedCharacters(page);
        // Filter cached results if searching offline
        final filtered = (name != null && name.isNotEmpty)
            ? cached
                .where((c) =>
                    c.name.toLowerCase().contains(name.toLowerCase()))
                .toList()
            : cached;
        return Right((characters: filtered, hasMore: false));
      } on CacheException catch (e) {
        return Left(NetworkFailure(e.message));
      }
    }
  }
}
