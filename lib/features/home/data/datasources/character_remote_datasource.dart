import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/character_model.dart';

abstract class CharacterRemoteDataSource {
  Future<({List<CharacterModel> characters, bool hasMore})> getCharacters(
      int page, {
      String? name,
      });
}

class CharacterRemoteDataSourceImpl implements CharacterRemoteDataSource {
  final Dio dio;

  CharacterRemoteDataSourceImpl(this.dio);

  @override
  Future<({List<CharacterModel> characters, bool hasMore})> getCharacters(
    int page, {
    String? name,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page};
      if (name != null && name.isNotEmpty) queryParams['name'] = name;

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
}
