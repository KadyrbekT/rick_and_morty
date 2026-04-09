import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/character.dart';

abstract class CharacterRepository {
  Future<Either<Failure, ({List<Character> characters, bool hasMore})>>
      getCharacters(
    int page, {
    String? name,
    String? status,
    String? species,
    String? type,
    String? gender,
  });

  Future<Either<Failure, Character>> getCharacterById(int id);

  Future<Either<Failure, List<Character>>> getMultipleCharacters(List<int> ids);
}
