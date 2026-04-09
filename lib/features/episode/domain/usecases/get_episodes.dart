import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/episode.dart';
import '../repositories/episode_repository.dart';

class EpisodeParams extends Equatable {
  final int page;
  final String? name;
  final String? episodeCode; // e.g. S01E01 or S02

  const EpisodeParams({required this.page, this.name, this.episodeCode});

  @override
  List<Object?> get props => [page, name, episodeCode];
}

class GetEpisodes
    implements UseCase<({List<Episode> episodes, bool hasMore}), EpisodeParams> {
  final EpisodeRepository repository;

  const GetEpisodes(this.repository);

  @override
  Future<Either<Failure, ({List<Episode> episodes, bool hasMore})>> call(
    EpisodeParams params,
  ) =>
      repository.getEpisodes(
        params.page,
        name: params.name,
        episodeCode: params.episodeCode,
      );
}
