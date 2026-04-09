import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../home/domain/usecases/get_multiple_characters.dart';
import '../../domain/entities/episode.dart';
import '../../domain/usecases/get_episode_by_id.dart';
import 'episode_detail_state.dart';

class EpisodeDetailCubit extends Cubit<EpisodeDetailState> {
  final GetEpisodeById getEpisodeById;
  final GetMultipleCharacters getMultipleCharacters;

  EpisodeDetailCubit({
    required this.getEpisodeById,
    required this.getMultipleCharacters,
  }) : super(const EpisodeDetailLoading(episode: _placeholder));

  static const _placeholder = Episode(
    id: 0,
    name: '',
    airDate: '',
    episode: '',
    characterCount: 0,
    characterIds: [],
    url: '',
  );

  /// Emits [EpisodeDetailLoading] immediately so the header renders instantly,
  /// then fetches fresh episode data and its character cast.
  Future<void> load(Episode initial) async {
    emit(EpisodeDetailLoading(episode: initial));

    final episodeResult = await getEpisodeById(initial.id);

    await episodeResult.fold(
      // Network failed — fall back to cached data from the list.
      (failure) => _loadCharacters(initial),
      (fresh) => _loadCharacters(fresh),
    );
  }

  Future<void> retry(Episode episode) => load(episode);

  // ─── Private ─────────────────────────────────────────────────────────────────

  Future<void> _loadCharacters(Episode episode) async {
    if (episode.characterIds.isEmpty) {
      emit(EpisodeDetailLoaded(episode: episode, characters: []));
      return;
    }

    final result = await getMultipleCharacters(episode.characterIds);

    result.fold(
      (failure) => emit(
        EpisodeDetailError(message: failure.message, episode: episode),
      ),
      (characters) => emit(
        EpisodeDetailLoaded(episode: episode, characters: characters),
      ),
    );
  }
}
