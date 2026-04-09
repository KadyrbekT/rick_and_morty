import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../home/domain/usecases/get_multiple_characters.dart';
import '../../domain/entities/location.dart';
import '../../domain/usecases/get_location_by_id.dart';
import 'location_detail_state.dart';

class LocationDetailCubit extends Cubit<LocationDetailState> {
  final GetLocationById getLocationById;
  final GetMultipleCharacters getMultipleCharacters;

  LocationDetailCubit({
    required this.getLocationById,
    required this.getMultipleCharacters,
  }) : super(const LocationDetailLoading(location: _placeholder));

  // Placeholder so the const super() call compiles — replaced immediately in load().
  static const _placeholder = Location(
    id: 0,
    name: '',
    type: '',
    dimension: '',
    residentCount: 0,
    residentIds: [],
    url: '',
  );

  /// Entry point. Emits [LocationDetailLoading] with the initial location
  /// immediately so the UI can render header/info while the API call is in flight.
  /// Then fetches fresh location data and resident characters.
  Future<void> load(Location initial) async {
    emit(LocationDetailLoading(location: initial));

    final locationResult = await getLocationById(IdParam(initial.id));

    await locationResult.fold(
      // Network failed — fall back to the data we already have.
      (failure) => _loadResidents(initial),
      // Got fresh data — use it.
      (fresh) => _loadResidents(fresh),
    );
  }

  Future<void> retry(Location location) => load(location);

  // ─── Private ─────────────────────────────────────────────────────────────────

  Future<void> _loadResidents(Location location) async {
    if (location.residentIds.isEmpty) {
      emit(LocationDetailLoaded(location: location, residents: []));
      return;
    }

    final result = await getMultipleCharacters(IdsParam(location.residentIds));

    result.fold(
      (failure) => emit(
        LocationDetailError(message: failure.message, location: location),
      ),
      (characters) => emit(
        LocationDetailLoaded(location: location, residents: characters),
      ),
    );
  }
}
