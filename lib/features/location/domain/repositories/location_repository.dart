import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/location.dart';

abstract class LocationRepository {
  Future<Either<Failure, ({List<Location> locations, bool hasMore})>>
      getLocations(
    int page, {
    String? name,
    String? type,
    String? dimension,
  });

  Future<Either<Failure, Location>> getLocationById(int id);

  Future<Either<Failure, List<Location>>> getMultipleLocations(List<int> ids);
}
