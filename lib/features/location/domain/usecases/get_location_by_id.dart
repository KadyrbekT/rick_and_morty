import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/location.dart';
import '../repositories/location_repository.dart';

class GetLocationById implements UseCase<Location, IdParam> {
  final LocationRepository repository;

  const GetLocationById(this.repository);

  @override
  Future<Either<Failure, Location>> call(IdParam params) =>
      repository.getLocationById(params.id);
}
