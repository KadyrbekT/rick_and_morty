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
    on<SortCharactersEvent>(_onSort);
    on<ToggleFavoriteEvent>(_onToggleFavorite);
  }

  Future<void> _onFetch(
    FetchCharacters event,
    Emitter<CharacterState> emit,
  ) async {
    emit(state.copyWith(status: CharacterStatus.loading, clearError: true));

    final favoriteIds = await favoriteRepository.getFavoriteIds();
    final result = await getCharacters(
      const CharacterParams(page: 1),
    );

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

  Future<void> _onFetchMore(
    FetchMoreCharacters event,
    Emitter<CharacterState> emit,
  ) async {
    if (state.isLoadingMore || !state.hasMore) return;
    // Don't paginate during search — API handles it separately
    if (state.searchQuery.isNotEmpty) return;

    emit(state.copyWith(isLoadingMore: true));

    final nextPage = state.currentPage + 1;
    final result = await getCharacters(CharacterParams(page: nextPage));

    result.fold(
      (failure) => emit(state.copyWith(
        isLoadingMore: false,
        errorMessage: failure.message,
      )),
      (data) {
        final allCharacters = [...state.characters, ...data.characters];
        final sorted = _applySort(allCharacters, state.sortBy);
        emit(state.copyWith(
          status: CharacterStatus.success,
          characters: allCharacters,
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
    emit(const CharacterState());
    add(const FetchCharacters());
  }

  Future<void> _onSearch(
    SearchCharacters event,
    Emitter<CharacterState> emit,
  ) async {
    final query = event.query.trim();
    emit(state.copyWith(
      searchQuery: query,
      status: CharacterStatus.loading,
      clearError: true,
    ));

    if (query.isEmpty) {
      // Return to main list
      final sorted = _applySort(state.characters, state.sortBy);
      emit(state.copyWith(
        status: CharacterStatus.success,
        filteredCharacters: sorted,
        currentPage: 1,
        hasMore: true,
      ));
      return;
    }

    final result = await getCharacters(
      CharacterParams(page: 1, name: query),
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
    final source = state.searchQuery.isEmpty
        ? state.characters
        : state.filteredCharacters;
    final sorted = _applySort(source, event.sortBy);
    emit(state.copyWith(
      sortBy: event.sortBy,
      filteredCharacters: sorted,
    ));
  }

  Future<void> _onToggleFavorite(
    ToggleFavoriteEvent event,
    Emitter<CharacterState> emit,
  ) async {
    await toggleFavorite(event.character);
    final updatedIds = await favoriteRepository.getFavoriteIds();
    emit(state.copyWith(favoriteIds: updatedIds));
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
