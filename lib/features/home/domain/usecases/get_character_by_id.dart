import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/character.dart';
import '../repositories/character_repository.dart';

class GetCharacterById implements UseCase<Character, IdParam> {
  final CharacterRepository repository;

  const GetCharacterById(this.repository);

  @override
  Future<Either<Failure, Character>> call(IdParam params) =>
      repository.getCharacterById(params.id);
}
