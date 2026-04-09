import 'package:equatable/equatable.dart';
import '../../domain/entities/location.dart';
import 'location_event.dart';

enum LocationStatus { initial, loading, success, failure }

final class LocationState extends Equatable {
  final LocationStatus status;
  final List<Location> locations;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;
  final String searchQuery;
  final LocationFilter filter;
  final String? errorMessage;

  const LocationState({
    this.status = LocationStatus.initial,
    this.locations = const [],
    this.currentPage = 1,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.searchQuery = '',
    this.filter = LocationFilter.empty,
    this.errorMessage,
  });

  bool get hasActiveQuery => searchQuery.isNotEmpty || filter.isActive;

  LocationState copyWith({
    LocationStatus? status,
    List<Location>? locations,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
    String? searchQuery,
    LocationFilter? filter,
    String? errorMessage,
    bool clearError = false,
  }) {
    return LocationState(
      status: status ?? this.status,
      locations: locations ?? this.locations,
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
        locations,
        currentPage,
        hasMore,
        isLoadingMore,
        searchQuery,
        filter,
        errorMessage,
      ];
}
