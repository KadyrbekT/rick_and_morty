import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../entities/location.dart';
import '../repositories/location_repository.dart';

class LocationParams extends Equatable {
  final int page;
  final String? name;
  final String? type;
  final String? dimension;

  const LocationParams({
    required this.page,
    this.name,
    this.type,
    this.dimension,
  });

  @override
  List<Object?> get props => [page, name, type, dimension];
}

class GetLocations {
  final LocationRepository repository;

  const GetLocations(this.repository);

  Future<Either<Failure, ({List<Location> locations, bool hasMore})>> call(
    LocationParams params,
  ) =>
      repository.getLocations(
        params.page,
        name: params.name,
        type: params.type,
        dimension: params.dimension,
      );
}
