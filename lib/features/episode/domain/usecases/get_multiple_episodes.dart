import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/episode.dart';
import '../repositories/episode_repository.dart';

class GetMultipleEpisodes implements UseCase<List<Episode>, IdsParam> {
  final EpisodeRepository repository;

  const GetMultipleEpisodes(this.repository);

  @override
  Future<Either<Failure, List<Episode>>> call(IdsParam params) =>
      repository.getMultipleEpisodes(params.ids);
}
