import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/character.dart';
import '../repositories/character_repository.dart';

class GetMultipleCharacters {
  final CharacterRepository repository;

  const GetMultipleCharacters(this.repository);

  Future<Either<Failure, List<Character>>> call(List<int> ids) {
    return repository.getMultipleCharacters(ids);
  }
}
