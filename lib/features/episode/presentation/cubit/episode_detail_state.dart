import 'package:equatable/equatable.dart';
import '../../../home/domain/entities/character.dart';
import '../../domain/entities/episode.dart';

sealed class EpisodeDetailState extends Equatable {
  const EpisodeDetailState();

  @override
  List<Object?> get props => [];
}

/// Emitted immediately — uses the episode data from the list for instant UI.
final class EpisodeDetailLoading extends EpisodeDetailState {
  final Episode episode;

  const EpisodeDetailLoading({required this.episode});

  @override
  List<Object?> get props => [episode];
}

/// Fresh episode + full character list loaded successfully.
final class EpisodeDetailLoaded extends EpisodeDetailState {
  final Episode episode;
  final List<Character> characters;

  const EpisodeDetailLoaded({
    required this.episode,
    required this.characters,
  });

  @override
  List<Object?> get props => [episode, characters];
}

/// Network/data error; episode may still be available for partial display.
final class EpisodeDetailError extends EpisodeDetailState {
  final String message;
  final Episode? episode;

  const EpisodeDetailError({required this.message, this.episode});

  @override
  List<Object?> get props => [message, episode];
}
