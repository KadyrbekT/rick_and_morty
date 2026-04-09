import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_locations.dart';
import 'location_event.dart';
import 'location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final GetLocations getLocations;

  LocationBloc({required this.getLocations}) : super(const LocationState()) {
    on<FetchLocations>(_onFetch);
    on<FetchMoreLocations>(_onFetchMore);
    on<RefreshLocations>(_onRefresh);
    on<SearchLocations>(_onSearch);
    on<ApplyLocationFilter>(_onApplyFilter);
  }

  // ─── Handlers ────────────────────────────────────────────────────────────────

  Future<void> _onFetch(
    FetchLocations event,
    Emitter<LocationState> emit,
  ) async {
    emit(state.copyWith(status: LocationStatus.loading, clearError: true));

    final result = await _fetch(page: 1, query: '', filter: LocationFilter.empty);

    result.fold(
      (failure) => emit(state.copyWith(
        status: LocationStatus.failure,
        errorMessage: failure.message,
      )),
      (data) => emit(state.copyWith(
        status: LocationStatus.success,
        locations: data.locations,
        currentPage: 1,
        hasMore: data.hasMore,
        searchQuery: '',
        filter: LocationFilter.empty,
      )),
    );
  }

  Future<void> _onFetchMore(
    FetchMoreLocations event,
    Emitter<LocationState> emit,
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
      (data) => emit(state.copyWith(
        status: LocationStatus.success,
        locations: [...state.locations, ...data.locations],
        currentPage: nextPage,
        hasMore: data.hasMore,
        isLoadingMore: false,
        clearError: true,
      )),
    );
  }

  Future<void> _onRefresh(
    RefreshLocations event,
    Emitter<LocationState> emit,
  ) async {
    // Preserve active search + filter on pull-to-refresh
    final query = state.searchQuery;
    final filter = state.filter;

    emit(state.copyWith(
      status: LocationStatus.loading,
      locations: [],
      currentPage: 1,
      hasMore: true,
      isLoadingMore: false,
      clearError: true,
    ));

    final result = await _fetch(page: 1, query: query, filter: filter);

    result.fold(
      (failure) => emit(state.copyWith(
        status: LocationStatus.failure,
        errorMessage: failure.message,
      )),
      (data) => emit(state.copyWith(
        status: LocationStatus.success,
        locations: data.locations,
        currentPage: 1,
        hasMore: data.hasMore,
      )),
    );
  }

  Future<void> _onSearch(
    SearchLocations event,
    Emitter<LocationState> emit,
  ) async {
    final query = event.query.trim();
    emit(state.copyWith(
      searchQuery: query,
      status: LocationStatus.loading,
      locations: [],
      currentPage: 1,
      clearError: true,
    ));

    final result = await _fetch(page: 1, query: query, filter: state.filter);

    result.fold(
      (failure) => emit(state.copyWith(
        status: LocationStatus.failure,
        errorMessage: failure.message,
      )),
      (data) => emit(state.copyWith(
        status: LocationStatus.success,
        locations: data.locations,
        hasMore: data.hasMore,
        currentPage: 1,
      )),
    );
  }

  Future<void> _onApplyFilter(
    ApplyLocationFilter event,
    Emitter<LocationState> emit,
  ) async {
    emit(state.copyWith(
      filter: event.filter,
      status: LocationStatus.loading,
      locations: [],
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
        status: LocationStatus.failure,
        errorMessage: failure.message,
      )),
      (data) => emit(state.copyWith(
        status: LocationStatus.success,
        locations: data.locations,
        hasMore: data.hasMore,
        currentPage: 1,
      )),
    );
  }

  // ─── Helper ──────────────────────────────────────────────────────────────────

  Future<dynamic> _fetch({
    required int page,
    required String query,
    required LocationFilter filter,
  }) {
    return getLocations(LocationParams(
      page: page,
      name: query.isEmpty ? null : query,
      type: filter.type,
      dimension: filter.dimension,
    ));
  }
}
