import 'package:equatable/equatable.dart';
import '../../../home/domain/entities/character.dart';
import '../../domain/entities/location.dart';

sealed class LocationDetailState extends Equatable {
  const LocationDetailState();

  @override
  List<Object?> get props => [];
}

/// Shown immediately — uses the location data already available from the list.
final class LocationDetailLoading extends LocationDetailState {
  final Location location;

  const LocationDetailLoading({required this.location});

  @override
  List<Object?> get props => [location];
}

/// Fresh location + full resident list loaded successfully.
final class LocationDetailLoaded extends LocationDetailState {
  final Location location;
  final List<Character> residents;

  const LocationDetailLoaded({
    required this.location,
    required this.residents,
  });

  @override
  List<Object?> get props => [location, residents];
}

/// Error loading residents; location may still be available for display.
final class LocationDetailError extends LocationDetailState {
  final String message;
  final Location? location;

  const LocationDetailError({required this.message, this.location});

  @override
  List<Object?> get props => [message, location];
}
