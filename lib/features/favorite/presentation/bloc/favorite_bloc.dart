import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/repositories/favorite_repository.dart';
import '../../domain/usecases/get_favorites.dart';
import 'favorite_event.dart';
import 'favorite_state.dart';

class FavoriteBloc extends Bloc<FavoriteEvent, FavoriteState> {
  final GetFavorites getFavorites;
  final FavoriteRepository favoriteRepository;

  FavoriteBloc({
    required this.getFavorites,
    required this.favoriteRepository,
  }) : super(const FavoriteState()) {
    on<LoadFavorites>(_onLoad);
    on<RemoveFavoriteEvent>(_onRemove);
  }

  Future<void> _onLoad(
    LoadFavorites event,
    Emitter<FavoriteState> emit,
  ) async {
    emit(state.copyWith(status: FavoriteStatus.loading));

    final result = await getFavorites(const NoParams());
    result.fold(
      (failure) => emit(state.copyWith(
        status: FavoriteStatus.failure,
        errorMessage: failure.message,
      )),
      (favorites) => emit(state.copyWith(
        status: FavoriteStatus.success,
        favorites: favorites,
      )),
    );
  }

  Future<void> _onRemove(
    RemoveFavoriteEvent event,
    Emitter<FavoriteState> emit,
  ) async {
    await favoriteRepository.removeFavorite(event.characterId);
    final result = await getFavorites(const NoParams());
    result.fold(
      (_) {/* keep current list on error */},
      (favorites) => emit(state.copyWith(favorites: favorites)),
    );
  }
}
