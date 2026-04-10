import 'package:equatable/equatable.dart';

enum SortBy { none, nameAsc, nameDesc, statusAlive, statusDead }

/// Immutable filter value object for character API queries.
class CharacterFilter extends Equatable {
  final String? status;  // alive | dead | unknown
  final String? species;
  final String? type;
  final String? gender;  // female | male | genderless | unknown

  const CharacterFilter({this.status, this.species, this.type, this.gender});

  static const empty = CharacterFilter();

  bool get isActive =>
      (status != null && status!.isNotEmpty) ||
      (species != null && species!.isNotEmpty) ||
      (type != null && type!.isNotEmpty) ||
      (gender != null && gender!.isNotEmpty);

  int get activeCount => [status, species, type, gender]
      .where((v) => v != null && v.isNotEmpty)
      .length;

  @override
  List<Object?> get props => [status, species, type, gender];
}
