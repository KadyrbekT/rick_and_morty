import 'package:equatable/equatable.dart';
import '../../domain/entities/character.dart';

sealed class CharacterDetailState extends Equatable {
  const CharacterDetailState();

  @override
  List<Object?> get props => [];
}

final class CharacterDetailLoading extends CharacterDetailState {
  const CharacterDetailLoading();
}

final class CharacterDetailLoaded extends CharacterDetailState {
  final Character character;
  const CharacterDetailLoaded(this.character);

  @override
  List<Object?> get props => [character];
}

final class CharacterDetailError extends CharacterDetailState {
  final String message;
  const CharacterDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
