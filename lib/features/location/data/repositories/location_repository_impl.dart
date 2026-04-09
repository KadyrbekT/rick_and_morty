import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/location.dart';
import '../../domain/repositories/location_repository.dart';
import '../datasources/location_local_datasource.dart';
import '../datasources/location_remote_datasource.dart';

class LocationRepositoryImpl implements LocationRepository {
  final LocationRemoteDataSource remoteDataSource;
  final LocationLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  LocationRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, ({List<Location> locations, bool hasMore})>>
      getLocations(
    int page, {
    String? name,
    String? type,
    String? dimension,
  }) async {
    final hasFilters = (name != null && name.isNotEmpty) ||
        (type != null && type.isNotEmpty) ||
        (dimension != null && dimension.isNotEmpty);

    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getLocations(
          page,
          name: name,
          type: type,
          dimension: dimension,
        );
        if (!hasFilters) {
          await localDataSource.cacheLocations(page, result.locations);
        }
        return Right((locations: result.locations, hasMore: result.hasMore));
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      try {
        final cached = await localDataSource.getCachedLocations(page);
        final filtered = hasFilters
            ? cached.where((l) {
                if (name != null && name.isNotEmpty) {
                  if (!l.name.toLowerCase().contains(name.toLowerCase())) return false;
                }
                if (type != null && type.isNotEmpty) {
                  if (!l.type.toLowerCase().contains(type.toLowerCase())) return false;
                }
                if (dimension != null && dimension.isNotEmpty) {
                  if (!l.dimension.toLowerCase().contains(dimension.toLowerCase())) return false;
                }
                return true;
              }).toList()
            : cached;
        return Right((locations: filtered, hasMore: false));
      } on CacheException catch (e) {
        return Left(NetworkFailure(e.message));
      }
    }
  }

  @override
  Future<Either<Failure, Location>> getLocationById(int id) async {
    try {
      final model = await remoteDataSource.getLocationById(id);
      return Right(model);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Location>>> getMultipleLocations(
      List<int> ids) async {
    try {
      final models = await remoteDataSource.getMultipleLocations(ids);
      return Right(models);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
