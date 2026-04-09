import 'package:equatable/equatable.dart';

class Location extends Equatable {
  final int id;
  final String name;
  final String type;
  final String dimension;
  final int residentCount;
  final List<int> residentIds;
  final String url;

  const Location({
    required this.id,
    required this.name,
    required this.type,
    required this.dimension,
    required this.residentCount,
    required this.residentIds,
    required this.url,
  });

  @override
  List<Object> get props => [id];
}
