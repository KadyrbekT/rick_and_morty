import '../../domain/entities/episode.dart';

class EpisodeModel extends Episode {
  const EpisodeModel({
    required super.id,
    required super.name,
    required super.airDate,
    required super.episode,
    required super.characterCount,
    required super.characterIds,
    required super.url,
  });

  /// Parses the API response (characters are URL strings).
  factory EpisodeModel.fromJson(Map<String, dynamic> json) {
    final characters = json['characters'] as List<dynamic>;
    final characterIds = characters
        .map((u) => int.parse((u as String).split('/').last))
        .toList();

    return EpisodeModel(
      id: json['id'] as int,
      name: json['name'] as String,
      airDate: json['air_date'] as String,
      episode: json['episode'] as String,
      characterCount: characters.length,
      characterIds: characterIds,
      url: json['url'] as String? ?? '',
    );
  }

  /// Parses the local cache format (characters stored as int list).
  factory EpisodeModel.fromCacheJson(Map<String, dynamic> json) {
    final ids = (json['characterIds'] as List<dynamic>?)
            ?.map((e) => e as int)
            .toList() ??
        [];
    return EpisodeModel(
      id: json['id'] as int,
      name: json['name'] as String,
      airDate: json['air_date'] as String,
      episode: json['episode'] as String,
      characterCount: json['characterCount'] as int? ?? ids.length,
      characterIds: ids,
      url: json['url'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'air_date': airDate,
        'episode': episode,
        'characterCount': characterCount,
        'characterIds': characterIds,
        'url': url,
      };

  factory EpisodeModel.fromEntity(Episode ep) {
    return EpisodeModel(
      id: ep.id,
      name: ep.name,
      airDate: ep.airDate,
      episode: ep.episode,
      characterCount: ep.characterCount,
      characterIds: ep.characterIds,
      url: ep.url,
    );
  }
}
