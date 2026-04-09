import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/character_model.dart';

abstract class CharacterRemoteDataSource {
  Future<({List<CharacterModel> characters, bool hasMore})> getCharacters(
      int page, {
      String? name,
      String? status,
      String? species,
      String? type,
      String? gender,
      });

  Future<CharacterModel> getCharacterById(int id);

  Future<List<CharacterModel>> getMultipleCharacters(List<int> ids);
}

class CharacterRemoteDataSourceImpl implements CharacterRemoteDataSource {
  final Dio dio;

  CharacterRemoteDataSourceImpl(this.dio);

  @override
  Future<({List<CharacterModel> characters, bool hasMore})> getCharacters(
    int page, {
    String? name,
    String? status,
    String? species,
    String? type,
    String? gender,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page};
      if (name != null && name.isNotEmpty) queryParams['name'] = name;
      if (status != null && status.isNotEmpty) queryParams['status'] = status;
      if (species != null && species.isNotEmpty) queryParams['species'] = species;
      if (type != null && type.isNotEmpty) queryParams['type'] = type;
      if (gender != null && gender.isNotEmpty) queryParams['gender'] = gender;

      final response = await dio.get(
        ApiConstants.characters,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final info = data['info'] as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>;

        return (
          characters: results
              .map((e) => CharacterModel.fromJson(e as Map<String, dynamic>))
              .toList(),
          hasMore: info['next'] != null,
        );
      }

      throw ServerException(message: 'Status: ${response.statusCode}');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return (characters: <CharacterModel>[], hasMore: false);
      }
      throw ServerException(message: e.message ?? 'Network request failed');
    }
  }

  @override
  Future<CharacterModel> getCharacterById(int id) async {
    try {
      final response = await dio.get('${ApiConstants.characters}/$id');

      if (response.statusCode == 200) {
        return CharacterModel.fromJson(
            response.data as Map<String, dynamic>);
      }

      throw ServerException(message: 'Status: ${response.statusCode}');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Network request failed');
    }
  }

  @override
  Future<List<CharacterModel>> getMultipleCharacters(List<int> ids) async {
    try {
      final idsParam = ids.join(',');
      final response = await dio.get('${ApiConstants.characters}/$idsParam');

      if (response.statusCode == 200) {
        // Single id returns an object, multiple returns an array
        final data = response.data;
        if (data is List) {
          return data
              .map((e) => CharacterModel.fromJson(e as Map<String, dynamic>))
              .toList();
        } else {
          return [CharacterModel.fromJson(data as Map<String, dynamic>)];
        }
      }

      throw ServerException(message: 'Status: ${response.statusCode}');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Network request failed');
    }
  }
}
