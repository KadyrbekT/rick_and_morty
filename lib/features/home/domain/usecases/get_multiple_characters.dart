import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/character.dart';
import '../repositories/character_repository.dart';

class GetMultipleCharacters implements UseCase<List<Character>, IdsParam> {
  final CharacterRepository repository;

  const GetMultipleCharacters(this.repository);

  @override
  Future<Either<Failure, List<Character>>> call(IdsParam params) =>
      repository.getMultipleCharacters(params.ids);
}
