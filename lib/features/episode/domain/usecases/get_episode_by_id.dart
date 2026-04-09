import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/episode.dart';
import '../repositories/episode_repository.dart';

class GetEpisodeById {
  final EpisodeRepository repository;

  const GetEpisodeById(this.repository);

  Future<Either<Failure, Episode>> call(int id) {
    return repository.getEpisodeById(id);
  }
}
