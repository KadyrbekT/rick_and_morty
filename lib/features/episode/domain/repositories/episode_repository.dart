import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/episode.dart';

abstract class EpisodeRepository {
  Future<Either<Failure, ({List<Episode> episodes, bool hasMore})>> getEpisodes(
    int page, {
    String? name,
    String? episodeCode,
  });

  Future<Either<Failure, Episode>> getEpisodeById(int id);

  Future<Either<Failure, List<Episode>>> getMultipleEpisodes(List<int> ids);
}
