import '../../domain/entities/character.dart';

class CharacterModel extends Character {
  const CharacterModel({
    required super.id,
    required super.name,
    required super.status,
    required super.species,
    required super.type,
    required super.gender,
    required super.image,
    required super.originName,
    required super.locationName,
    required super.episodeIds,
  });

  factory CharacterModel.fromJson(Map<String, dynamic> json) {
    return CharacterModel(
      id: json['id'] as int,
      name: json['name'] as String,
      status: json['status'] as String,
      species: json['species'] as String,
      type: json['type'] as String? ?? '',
      gender: json['gender'] as String,
      image: json['image'] as String,
      originName: (json['origin'] as Map<String, dynamic>)['name'] as String,
      locationName:
          (json['location'] as Map<String, dynamic>)['name'] as String,
      episodeIds: (json['episode'] as List<dynamic>? ?? [])
          .map((url) => _parseIdFromUrl(url as String))
          .whereType<int>()
          .toList(),
    );
  }

  factory CharacterModel.fromEntity(Character character) {
    return CharacterModel(
      id: character.id,
      name: character.name,
      status: character.status,
      species: character.species,
      type: character.type,
      gender: character.gender,
      image: character.image,
      originName: character.originName,
      locationName: character.locationName,
      episodeIds: character.episodeIds,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'status': status,
        'species': species,
        'type': type,
        'gender': gender,
        'image': image,
        'origin': {'name': originName},
        'location': {'name': locationName},
        'episode': episodeIds
            .map((id) => 'https://rickandmortyapi.com/api/episode/$id')
            .toList(),
      };

  static int? _parseIdFromUrl(String url) {
    final segments = url.split('/');
    return int.tryParse(segments.last);
  }
}
