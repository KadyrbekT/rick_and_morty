import 'package:equatable/equatable.dart';

/// Immutable filter value object.
/// [episodeCode] accepts full or partial codes: "S01", "S01E03", etc.
class EpisodeFilter extends Equatable {
  final String? episodeCode;

  const EpisodeFilter({this.episodeCode});

  static const empty = EpisodeFilter();

  bool get isActive => episodeCode != null && episodeCode!.isNotEmpty;

  int get activeCount => isActive ? 1 : 0;

  @override
  List<Object?> get props => [episodeCode];
}

sealed class EpisodeEvent extends Equatable {
  const EpisodeEvent();

  @override
  List<Object?> get props => [];
}

final class FetchEpisodes extends EpisodeEvent {
  const FetchEpisodes();
}

final class FetchMoreEpisodes extends EpisodeEvent {
  const FetchMoreEpisodes();
}

final class RefreshEpisodes extends EpisodeEvent {
  const RefreshEpisodes();
}

final class SearchEpisodes extends EpisodeEvent {
  final String query;
  const SearchEpisodes(this.query);

  @override
  List<Object?> get props => [query];
}

final class ApplyEpisodeFilter extends EpisodeEvent {
  final EpisodeFilter filter;
  const ApplyEpisodeFilter(this.filter);

  @override
  List<Object?> get props => [filter];
}
