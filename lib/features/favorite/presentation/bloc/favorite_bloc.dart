import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_favorites.dart';
import '../../domain/repositories/favorite_repository.dart';
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
    try {
      final favorites = await getFavorites();
      emit(state.copyWith(
        status: FavoriteStatus.success,
        favorites: favorites,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: FavoriteStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onRemove(
    RemoveFavoriteEvent event,
    Emitter<FavoriteState> emit,
  ) async {
    await favoriteRepository.removeFavorite(event.characterId);
    final updated = await getFavorites();
    emit(state.copyWith(favorites: updated));
  }
}
