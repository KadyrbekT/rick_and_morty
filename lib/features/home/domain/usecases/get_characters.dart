import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../entities/character.dart';
import '../repositories/character_repository.dart';

class CharacterParams extends Equatable {
  final int page;
  final String? name;

  const CharacterParams({required this.page, this.name});

  @override
  List<Object?> get props => [page, name];
}

class GetCharacters {
  final CharacterRepository repository;

  const GetCharacters(this.repository);

  Future<Either<Failure, ({List<Character> characters, bool hasMore})>> call(
      CharacterParams params) {
    return repository.getCharacters(params.page, name: params.name);
  }
}
