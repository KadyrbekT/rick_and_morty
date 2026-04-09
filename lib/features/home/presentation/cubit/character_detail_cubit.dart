import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/character.dart';
import '../../domain/usecases/get_character_by_id.dart';
import 'character_detail_state.dart';

class CharacterDetailCubit extends Cubit<CharacterDetailState> {
  final GetCharacterById getCharacterById;

  CharacterDetailCubit({required this.getCharacterById})
      : super(const CharacterDetailLoading());

  /// Shows the passed character immediately (from list cache),
  /// then silently refreshes in the background.
  Future<void> load(Character initial) async {
    emit(CharacterDetailLoaded(initial));

    final result = await getCharacterById(IdParam(initial.id));
    result.fold(
      (_) {/* keep showing the cached version on error */},
      (fresh) => emit(CharacterDetailLoaded(fresh)),
    );
  }
}
