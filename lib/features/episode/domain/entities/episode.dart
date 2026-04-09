import 'package:equatable/equatable.dart';

class Episode extends Equatable {
  final int id;
  final String name;
  final String airDate;
  final String episode; // e.g. S01E01
  final int characterCount;
  final List<int> characterIds;
  final String url;

  const Episode({
    required this.id,
    required this.name,
    required this.airDate,
    required this.episode,
    required this.characterCount,
    required this.characterIds,
    required this.url,
  });

  /// Season number parsed from episode code (S01E01 → 1).
  int get season {
    final match = RegExp(r'S(\d+)').firstMatch(episode);
    return int.tryParse(match?.group(1) ?? '0') ?? 0;
  }

  @override
  List<Object> get props => [id];
}
