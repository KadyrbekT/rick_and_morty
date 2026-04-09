import 'package:equatable/equatable.dart';
import '../../domain/entities/episode.dart';
import 'episode_event.dart';

enum EpisodeStatus { initial, loading, success, failure }

final class EpisodeState extends Equatable {
  final EpisodeStatus status;
  final List<Episode> episodes;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;
  final String searchQuery;
  final EpisodeFilter filter;
  final String? errorMessage;

  const EpisodeState({
    this.status = EpisodeStatus.initial,
    this.episodes = const [],
    this.currentPage = 1,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.searchQuery = '',
    this.filter = EpisodeFilter.empty,
    this.errorMessage,
  });

  bool get hasActiveQuery => searchQuery.isNotEmpty || filter.isActive;

  EpisodeState copyWith({
    EpisodeStatus? status,
    List<Episode>? episodes,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
    String? searchQuery,
    EpisodeFilter? filter,
    String? errorMessage,
    bool clearError = false,
  }) {
    return EpisodeState(
      status: status ?? this.status,
      episodes: episodes ?? this.episodes,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      searchQuery: searchQuery ?? this.searchQuery,
      filter: filter ?? this.filter,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        episodes,
        currentPage,
        hasMore,
        isLoadingMore,
        searchQuery,
        filter,
        errorMessage,
      ];
}
