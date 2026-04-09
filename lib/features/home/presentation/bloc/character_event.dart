import 'package:equatable/equatable.dart';
import '../../domain/entities/character.dart';

enum SortBy { none, nameAsc, nameDesc, statusAlive, statusDead }

/// Immutable filter value object for character API queries.
class CharacterFilter extends Equatable {
  final String? status;  // alive | dead | unknown
  final String? species;
  final String? type;
  final String? gender;  // female | male | genderless | unknown

  const CharacterFilter({this.status, this.species, this.type, this.gender});

  static const empty = CharacterFilter();

  bool get isActive =>
      (status != null && status!.isNotEmpty) ||
      (species != null && species!.isNotEmpty) ||
      (type != null && type!.isNotEmpty) ||
      (gender != null && gender!.isNotEmpty);

  int get activeCount => [status, species, type, gender]
      .where((v) => v != null && v.isNotEmpty)
      .length;

  @override
  List<Object?> get props => [status, species, type, gender];
}

sealed class CharacterEvent extends Equatable {
  const CharacterEvent();

  @override
  List<Object?> get props => [];
}

final class FetchCharacters extends CharacterEvent {
  const FetchCharacters();
}

final class FetchMoreCharacters extends CharacterEvent {
  const FetchMoreCharacters();
}

final class RefreshCharacters extends CharacterEvent {
  const RefreshCharacters();
}

final class SearchCharacters extends CharacterEvent {
  final String query;
  const SearchCharacters(this.query);

  @override
  List<Object?> get props => [query];
}

final class ApplyCharacterFilter extends CharacterEvent {
  final CharacterFilter filter;
  const ApplyCharacterFilter(this.filter);

  @override
  List<Object?> get props => [filter];
}

final class SortCharactersEvent extends CharacterEvent {
  final SortBy sortBy;
  const SortCharactersEvent(this.sortBy);

  @override
  List<Object?> get props => [sortBy];
}

final class ToggleFavoriteEvent extends CharacterEvent {
  final Character character;
  const ToggleFavoriteEvent(this.character);

  @override
  List<Object?> get props => [character.id];
}
