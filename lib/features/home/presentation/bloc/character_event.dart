import 'package:equatable/equatable.dart';
import '../../domain/entities/character.dart';

enum SortBy { none, nameAsc, nameDesc, statusAlive, statusDead }

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
