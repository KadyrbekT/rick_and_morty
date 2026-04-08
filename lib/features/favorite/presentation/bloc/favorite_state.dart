import 'package:equatable/equatable.dart';
import '../../../home/domain/entities/character.dart';

enum FavoriteStatus { initial, loading, success, failure }

final class FavoriteState extends Equatable {
  final FavoriteStatus status;
  final List<Character> favorites;
  final String? errorMessage;

  const FavoriteState({
    this.status = FavoriteStatus.initial,
    this.favorites = const [],
    this.errorMessage,
  });

  FavoriteState copyWith({
    FavoriteStatus? status,
    List<Character>? favorites,
    String? errorMessage,
  }) {
    return FavoriteState(
      status: status ?? this.status,
      favorites: favorites ?? this.favorites,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, favorites, errorMessage];
}
