import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/episode.dart';
import '../repositories/episode_repository.dart';

class GetEpisodeById implements UseCase<Episode, IdParam> {
  final EpisodeRepository repository;

  const GetEpisodeById(this.repository);

  @override
  Future<Either<Failure, Episode>> call(IdParam params) =>
      repository.getEpisodeById(params.id);
}
