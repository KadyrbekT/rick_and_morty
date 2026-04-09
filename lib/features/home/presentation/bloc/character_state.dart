import 'package:equatable/equatable.dart';
import '../../domain/entities/character.dart';
import 'character_event.dart';

enum CharacterStatus { initial, loading, success, failure }

final class CharacterState extends Equatable {
  final CharacterStatus status;
  final List<Character> characters;
  final List<Character> filteredCharacters;
  final Set<int> favoriteIds;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;
  final String searchQuery;
  final CharacterFilter filter;
  final SortBy sortBy;
  final String? errorMessage;

  const CharacterState({
    this.status = CharacterStatus.initial,
    this.characters = const [],
    this.filteredCharacters = const [],
    this.favoriteIds = const {},
    this.currentPage = 1,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.searchQuery = '',
    this.filter = CharacterFilter.empty,
    this.sortBy = SortBy.none,
    this.errorMessage,
  });

  bool get hasActiveQuery => searchQuery.isNotEmpty || filter.isActive;

  CharacterState copyWith({
    CharacterStatus? status,
    List<Character>? characters,
    List<Character>? filteredCharacters,
    Set<int>? favoriteIds,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
    String? searchQuery,
    CharacterFilter? filter,
    SortBy? sortBy,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CharacterState(
      status: status ?? this.status,
      characters: characters ?? this.characters,
      filteredCharacters: filteredCharacters ?? this.filteredCharacters,
      favoriteIds: favoriteIds ?? this.favoriteIds,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      searchQuery: searchQuery ?? this.searchQuery,
      filter: filter ?? this.filter,
      sortBy: sortBy ?? this.sortBy,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        characters,
        filteredCharacters,
        favoriteIds,
        currentPage,
        hasMore,
        isLoadingMore,
        searchQuery,
        filter,
        sortBy,
        errorMessage,
      ];
}
