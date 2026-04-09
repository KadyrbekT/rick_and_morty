import '../../domain/entities/location.dart';

class LocationModel extends Location {
  const LocationModel({
    required super.id,
    required super.name,
    required super.type,
    required super.dimension,
    required super.residentCount,
    required super.residentIds,
    required super.url,
  });

  /// Parses the API response (residents are URL strings).
  factory LocationModel.fromJson(Map<String, dynamic> json) {
    final residents = json['residents'] as List<dynamic>;
    final residentIds = residents
        .map((u) => int.parse((u as String).split('/').last))
        .toList();

    return LocationModel(
      id: json['id'] as int,
      name: json['name'] as String,
      type: json['type'] as String,
      dimension: json['dimension'] as String,
      residentCount: residents.length,
      residentIds: residentIds,
      url: json['url'] as String? ?? '',
    );
  }

  /// Parses the local cache format (residents stored as int list).
  factory LocationModel.fromCacheJson(Map<String, dynamic> json) {
    final ids = (json['residentIds'] as List<dynamic>?)
            ?.map((e) => e as int)
            .toList() ??
        [];
    return LocationModel(
      id: json['id'] as int,
      name: json['name'] as String,
      type: json['type'] as String,
      dimension: json['dimension'] as String,
      residentCount: json['residentCount'] as int? ?? ids.length,
      residentIds: ids,
      url: json['url'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type,
        'dimension': dimension,
        'residentCount': residentCount,
        'residentIds': residentIds,
        'url': url,
      };

  factory LocationModel.fromEntity(Location location) {
    return LocationModel(
      id: location.id,
      name: location.name,
      type: location.type,
      dimension: location.dimension,
      residentCount: location.residentCount,
      residentIds: location.residentIds,
      url: location.url,
    );
  }
}
