import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/location.dart';
import '../repositories/location_repository.dart';

class GetMultipleLocations implements UseCase<List<Location>, IdsParam> {
  final LocationRepository repository;

  const GetMultipleLocations(this.repository);

  @override
  Future<Either<Failure, List<Location>>> call(IdsParam params) =>
      repository.getMultipleLocations(params.ids);
}
