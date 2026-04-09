import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/location.dart';
import '../repositories/location_repository.dart';

class GetLocationById {
  final LocationRepository repository;

  const GetLocationById(this.repository);

  Future<Either<Failure, Location>> call(int id) {
    return repository.getLocationById(id);
  }
}
