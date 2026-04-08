import 'package:equatable/equatable.dart';

sealed class FavoriteEvent extends Equatable {
  const FavoriteEvent();

  @override
  List<Object?> get props => [];
}

final class LoadFavorites extends FavoriteEvent {
  const LoadFavorites();
}

final class RemoveFavoriteEvent extends FavoriteEvent {
  final int characterId;
  const RemoveFavoriteEvent(this.characterId);

  @override
  List<Object?> get props => [characterId];
}
