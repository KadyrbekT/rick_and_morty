import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/character.dart';
import '../repositories/character_repository.dart';

class GetCharacterById {
  final CharacterRepository repository;

  const GetCharacterById(this.repository);

  Future<Either<Failure, Character>> call(int id) =>
      repository.getCharacterById(id);
}
