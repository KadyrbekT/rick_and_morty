import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/episode.dart';
import '../../domain/repositories/episode_repository.dart';
import '../datasources/episode_local_datasource.dart';
import '../datasources/episode_remote_datasource.dart';

class EpisodeRepositoryImpl implements EpisodeRepository {
  final EpisodeRemoteDataSource remoteDataSource;
  final EpisodeLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  EpisodeRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, ({List<Episode> episodes, bool hasMore})>> getEpisodes(
    int page, {
    String? name,
    String? episodeCode,
  }) async {
    final hasFilters = (name != null && name.isNotEmpty) ||
        (episodeCode != null && episodeCode.isNotEmpty);

    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getEpisodes(
          page,
          name: name,
          episodeCode: episodeCode,
        );
        if (!hasFilters) {
          await localDataSource.cacheEpisodes(page, result.episodes);
        }
        return Right((episodes: result.episodes, hasMore: result.hasMore));
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      try {
        final cached = await localDataSource.getCachedEpisodes(page);
        final filtered = hasFilters
            ? cached.where((e) {
                if (name != null && name.isNotEmpty) {
                  if (!e.name.toLowerCase().contains(name.toLowerCase())) {
                    return false;
                  }
                }
                if (episodeCode != null && episodeCode.isNotEmpty) {
                  if (!e.episode
                      .toLowerCase()
                      .contains(episodeCode.toLowerCase())) {
                    return false;
                  }
                }
                return true;
              }).toList()
            : cached;
        return Right((episodes: filtered, hasMore: false));
      } on CacheException catch (e) {
        return Left(NetworkFailure(e.message));
      }
    }
  }

  @override
  Future<Either<Failure, Episode>> getEpisodeById(int id) async {
    try {
      final model = await remoteDataSource.getEpisodeById(id);
      return Right(model);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Episode>>> getMultipleEpisodes(
      List<int> ids) async {
    try {
      final models = await remoteDataSource.getMultipleEpisodes(ids);
      return Right(models);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
