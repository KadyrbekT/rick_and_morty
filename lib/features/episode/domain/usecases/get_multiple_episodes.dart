import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/episode.dart';
import '../repositories/episode_repository.dart';

class GetMultipleEpisodes {
  final EpisodeRepository repository;

  const GetMultipleEpisodes(this.repository);

  Future<Either<Failure, List<Episode>>> call(List<int> ids) {
    return repository.getMultipleEpisodes(ids);
  }
}
