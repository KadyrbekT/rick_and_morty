import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/location.dart';
import '../repositories/location_repository.dart';

class GetMultipleLocations {
  final LocationRepository repository;

  const GetMultipleLocations(this.repository);

  Future<Either<Failure, List<Location>>> call(List<int> ids) {
    return repository.getMultipleLocations(ids);
  }
}
