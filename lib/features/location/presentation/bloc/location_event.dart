import 'package:equatable/equatable.dart';

/// Immutable filter value object for location API queries.
class LocationFilter extends Equatable {
  final String? type;
  final String? dimension;

  const LocationFilter({this.type, this.dimension});

  static const empty = LocationFilter();

  bool get isActive =>
      (type != null && type!.isNotEmpty) ||
      (dimension != null && dimension!.isNotEmpty);

  int get activeCount =>
      [type, dimension].where((v) => v != null && v.isNotEmpty).length;

  @override
  List<Object?> get props => [type, dimension];
}

sealed class LocationEvent extends Equatable {
  const LocationEvent();

  @override
  List<Object?> get props => [];
}

final class FetchLocations extends LocationEvent {
  const FetchLocations();
}

final class FetchMoreLocations extends LocationEvent {
  const FetchMoreLocations();
}

final class RefreshLocations extends LocationEvent {
  const RefreshLocations();
}

final class SearchLocations extends LocationEvent {
  final String query;
  const SearchLocations(this.query);

  @override
  List<Object?> get props => [query];
}

final class ApplyLocationFilter extends LocationEvent {
  final LocationFilter filter;
  const ApplyLocationFilter(this.filter);

  @override
  List<Object?> get props => [filter];
}
