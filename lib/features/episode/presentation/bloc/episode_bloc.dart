import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/episode.dart';
import '../../domain/usecases/get_episodes.dart';
import 'episode_event.dart';
import 'episode_state.dart';

class EpisodeBloc extends Bloc<EpisodeEvent, EpisodeState> {
  final GetEpisodes getEpisodes;

  EpisodeBloc({required this.getEpisodes}) : super(const EpisodeState()) {
    on<FetchEpisodes>(_onFetch);
    on<FetchMoreEpisodes>(_onFetchMore);
    on<RefreshEpisodes>(_onRefresh);
    on<SearchEpisodes>(_onSearch);
    on<ApplyEpisodeFilter>(_onApplyFilter);
  }

  // ─── Handlers ────────────────────────────────────────────────────────────────

  Future<void> _onFetch(
    FetchEpisodes event,
    Emitter<EpisodeState> emit,
  ) async {
    emit(state.copyWith(status: EpisodeStatus.loading, clearError: true));

    final result = await _fetch(page: 1, query: '', filter: EpisodeFilter.empty);

    result.fold(
      (failure) => emit(state.copyWith(
        status: EpisodeStatus.failure,
        errorMessage: failure.message,
      )),
      (data) => emit(state.copyWith(
        status: EpisodeStatus.success,
        episodes: data.episodes,
        currentPage: 1,
        hasMore: data.hasMore,
        searchQuery: '',
        filter: EpisodeFilter.empty,
      )),
    );
  }

  Future<void> _onFetchMore(
    FetchMoreEpisodes event,
    Emitter<EpisodeState> emit,
  ) async {
    if (state.isLoadingMore || !state.hasMore) return;

    emit(state.copyWith(isLoadingMore: true));

    final nextPage = state.currentPage + 1;
    final result = await _fetch(
      page: nextPage,
      query: state.searchQuery,
      filter: state.filter,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        isLoadingMore: false,
        errorMessage: failure.message,
      )),
      (data) => emit(state.copyWith(
        status: EpisodeStatus.success,
        episodes: <Episode>[...state.episodes, ...data.episodes],
        currentPage: nextPage,
        hasMore: data.hasMore,
        isLoadingMore: false,
        clearError: true,
      )),
    );
  }

  Future<void> _onRefresh(
    RefreshEpisodes event,
    Emitter<EpisodeState> emit,
  ) async {
    final query = state.searchQuery;
    final filter = state.filter;

    emit(state.copyWith(
      status: EpisodeStatus.loading,
      episodes: [],
      currentPage: 1,
      hasMore: true,
      isLoadingMore: false,
      clearError: true,
    ));

    final result = await _fetch(page: 1, query: query, filter: filter);

    result.fold(
      (failure) => emit(state.copyWith(
        status: EpisodeStatus.failure,
        errorMessage: failure.message,
      )),
      (data) => emit(state.copyWith(
        status: EpisodeStatus.success,
        episodes: data.episodes,
        currentPage: 1,
        hasMore: data.hasMore,
      )),
    );
  }

  Future<void> _onSearch(
    SearchEpisodes event,
    Emitter<EpisodeState> emit,
  ) async {
    final query = event.query.trim();
    emit(state.copyWith(
      searchQuery: query,
      status: EpisodeStatus.loading,
      episodes: [],
      currentPage: 1,
      clearError: true,
    ));

    final result = await _fetch(page: 1, query: query, filter: state.filter);

    result.fold(
      (failure) => emit(state.copyWith(
        status: EpisodeStatus.failure,
        errorMessage: failure.message,
      )),
      (data) => emit(state.copyWith(
        status: EpisodeStatus.success,
        episodes: data.episodes,
        hasMore: data.hasMore,
        currentPage: 1,
      )),
    );
  }

  Future<void> _onApplyFilter(
    ApplyEpisodeFilter event,
    Emitter<EpisodeState> emit,
  ) async {
    emit(state.copyWith(
      filter: event.filter,
      status: EpisodeStatus.loading,
      episodes: [],
      currentPage: 1,
      clearError: true,
    ));

    final result = await _fetch(
      page: 1,
      query: state.searchQuery,
      filter: event.filter,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: EpisodeStatus.failure,
        errorMessage: failure.message,
      )),
      (data) => emit(state.copyWith(
        status: EpisodeStatus.success,
        episodes: data.episodes,
        hasMore: data.hasMore,
        currentPage: 1,
      )),
    );
  }

  // ─── Helper ──────────────────────────────────────────────────────────────────

  Future<dynamic> _fetch({
    required int page,
    required String query,
    required EpisodeFilter filter,
  }) {
    return getEpisodes(EpisodeParams(
      page: page,
      name: query.isEmpty ? null : query,
      episodeCode: filter.episodeCode,
    ));
  }
}
