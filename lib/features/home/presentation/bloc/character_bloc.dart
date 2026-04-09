import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../features/favorite/domain/repositories/favorite_repository.dart';
import '../../../../features/favorite/domain/usecases/toggle_favorite.dart';
import '../../domain/entities/character.dart';
import '../../domain/usecases/get_characters.dart';
import 'character_event.dart';
import 'character_state.dart';

class CharacterBloc extends Bloc<CharacterEvent, CharacterState> {
  final GetCharacters getCharacters;
  final ToggleFavorite toggleFavorite;
  final FavoriteRepository favoriteRepository;

  CharacterBloc({
    required this.getCharacters,
    required this.toggleFavorite,
    required this.favoriteRepository,
  }) : super(const CharacterState()) {
    on<FetchCharacters>(_onFetch);
    on<FetchMoreCharacters>(_onFetchMore);
    on<RefreshCharacters>(_onRefresh);
    on<SearchCharacters>(_onSearch);
    on<ApplyCharacterFilter>(_onApplyFilter);
    on<SortCharactersEvent>(_onSort);
    on<ToggleFavoriteEvent>(_onToggleFavorite);
  }

  // ─── Handlers ────────────────────────────────────────────────────────────────

  Future<void> _onFetch(
    FetchCharacters event,
    Emitter<CharacterState> emit,
  ) async {
    emit(state.copyWith(status: CharacterStatus.loading, clearError: true));

    final favoriteIds = await favoriteRepository.getFavoriteIds();
    final result = await _fetch(page: 1, query: '', filter: CharacterFilter.empty);

    result.fold(
      (failure) => emit(state.copyWith(
        status: CharacterStatus.failure,
        errorMessage: failure.message,
        favoriteIds: favoriteIds,
      )),
      (data) {
        final sorted = _applySort(data.characters, state.sortBy);
        emit(state.copyWith(
          status: CharacterStatus.success,
          characters: data.characters,
          filteredCharacters: sorted,
          favoriteIds: favoriteIds,
          currentPage: 1,
          hasMore: data.hasMore,
          searchQuery: '',
          filter: CharacterFilter.empty,
        ));
      },
    );
  }

  Future<void> _onFetchMore(
    FetchMoreCharacters event,
    Emitter<CharacterState> emit,
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
      (data) {
        final allChars = <Character>[...state.characters, ...data.characters];
        final sorted = _applySort(allChars, state.sortBy);
        emit(state.copyWith(
          status: CharacterStatus.success,
          characters: allChars,
          filteredCharacters: sorted,
          currentPage: nextPage,
          hasMore: data.hasMore,
          isLoadingMore: false,
          clearError: true,
        ));
      },
    );
  }

  Future<void> _onRefresh(
    RefreshCharacters event,
    Emitter<CharacterState> emit,
  ) async {
    // Preserve active search + filter on pull-to-refresh
    final query = state.searchQuery;
    final filter = state.filter;

    emit(state.copyWith(
      status: CharacterStatus.loading,
      characters: [],
      filteredCharacters: [],
      currentPage: 1,
      hasMore: true,
      isLoadingMore: false,
      clearError: true,
    ));

    final favoriteIds = await favoriteRepository.getFavoriteIds();
    final result = await _fetch(page: 1, query: query, filter: filter);

    result.fold(
      (failure) => emit(state.copyWith(
        status: CharacterStatus.failure,
        errorMessage: failure.message,
        favoriteIds: favoriteIds,
      )),
      (data) {
        final sorted = _applySort(data.characters, state.sortBy);
        emit(state.copyWith(
          status: CharacterStatus.success,
          characters: data.characters,
          filteredCharacters: sorted,
          favoriteIds: favoriteIds,
          currentPage: 1,
          hasMore: data.hasMore,
        ));
      },
    );
  }

  Future<void> _onSearch(
    SearchCharacters event,
    Emitter<CharacterState> emit,
  ) async {
    final query = event.query.trim();
    emit(state.copyWith(
      searchQuery: query,
      status: CharacterStatus.loading,
      characters: [],
      filteredCharacters: [],
      currentPage: 1,
      clearError: true,
    ));

    final result = await _fetch(page: 1, query: query, filter: state.filter);

    result.fold(
      (failure) => emit(state.copyWith(
        status: CharacterStatus.failure,
        errorMessage: failure.message,
      )),
      (data) {
        final sorted = _applySort(data.characters, state.sortBy);
        emit(state.copyWith(
          status: CharacterStatus.success,
          characters: data.characters,
          filteredCharacters: sorted,
          hasMore: data.hasMore,
          currentPage: 1,
        ));
      },
    );
  }

  Future<void> _onApplyFilter(
    ApplyCharacterFilter event,
    Emitter<CharacterState> emit,
  ) async {
    emit(state.copyWith(
      filter: event.filter,
      status: CharacterStatus.loading,
      characters: [],
      filteredCharacters: [],
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
        status: CharacterStatus.failure,
        errorMessage: failure.message,
      )),
      (data) {
        final sorted = _applySort(data.characters, state.sortBy);
        emit(state.copyWith(
          status: CharacterStatus.success,
          characters: data.characters,
          filteredCharacters: sorted,
          hasMore: data.hasMore,
          currentPage: 1,
        ));
      },
    );
  }

  Future<void> _onSort(
    SortCharactersEvent event,
    Emitter<CharacterState> emit,
  ) async {
    final sorted = _applySort(state.characters, event.sortBy);
    emit(state.copyWith(sortBy: event.sortBy, filteredCharacters: sorted));
  }

  Future<void> _onToggleFavorite(
    ToggleFavoriteEvent event,
    Emitter<CharacterState> emit,
  ) async {
    await toggleFavorite(event.character);
    final updatedIds = await favoriteRepository.getFavoriteIds();
    emit(state.copyWith(favoriteIds: updatedIds));
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────────

  Future<dynamic> _fetch({
    required int page,
    required String query,
    required CharacterFilter filter,
  }) {
    return getCharacters(CharacterParams(
      page: page,
      name: query.isEmpty ? null : query,
      status: filter.status,
      species: filter.species,
      type: filter.type,
      gender: filter.gender,
    ));
  }

  List<Character> _applySort(List<Character> list, SortBy sortBy) {
    final sorted = List<Character>.from(list);
    switch (sortBy) {
      case SortBy.nameAsc:
        sorted.sort((a, b) => a.name.compareTo(b.name));
      case SortBy.nameDesc:
        sorted.sort((a, b) => b.name.compareTo(a.name));
      case SortBy.statusAlive:
        sorted.sort((a, b) {
          if (a.status == 'Alive' && b.status != 'Alive') return -1;
          if (a.status != 'Alive' && b.status == 'Alive') return 1;
          return 0;
        });
      case SortBy.statusDead:
        sorted.sort((a, b) {
          if (a.status == 'Dead' && b.status != 'Dead') return -1;
          if (a.status != 'Dead' && b.status == 'Dead') return 1;
          return 0;
        });
      case SortBy.none:
        break;
    }
    return sorted;
  }
}
