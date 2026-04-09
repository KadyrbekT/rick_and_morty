import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/episode_model.dart';

abstract class EpisodeRemoteDataSource {
  Future<({List<EpisodeModel> episodes, bool hasMore})> getEpisodes(
    int page, {
    String? name,
    String? episodeCode,
  });

  Future<EpisodeModel> getEpisodeById(int id);

  Future<List<EpisodeModel>> getMultipleEpisodes(List<int> ids);
}

class EpisodeRemoteDataSourceImpl implements EpisodeRemoteDataSource {
  final Dio dio;

  EpisodeRemoteDataSourceImpl(this.dio);

  @override
  Future<({List<EpisodeModel> episodes, bool hasMore})> getEpisodes(
    int page, {
    String? name,
    String? episodeCode,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page};
      if (name != null && name.isNotEmpty) queryParams['name'] = name;
      if (episodeCode != null && episodeCode.isNotEmpty) {
        queryParams['episode'] = episodeCode;
      }

      final response = await dio.get(
        ApiConstants.episodes,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final info = data['info'] as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>;

        return (
          episodes: results
              .map((e) => EpisodeModel.fromJson(e as Map<String, dynamic>))
              .toList(),
          hasMore: info['next'] != null,
        );
      }

      throw ServerException(message: 'Status: ${response.statusCode}');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return (episodes: <EpisodeModel>[], hasMore: false);
      }
      throw ServerException(message: e.message ?? 'Network request failed');
    }
  }

  @override
  Future<EpisodeModel> getEpisodeById(int id) async {
    try {
      final response = await dio.get('${ApiConstants.episodes}/$id');

      if (response.statusCode == 200) {
        return EpisodeModel.fromJson(response.data as Map<String, dynamic>);
      }

      throw ServerException(message: 'Status: ${response.statusCode}');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Network request failed');
    }
  }

  @override
  Future<List<EpisodeModel>> getMultipleEpisodes(List<int> ids) async {
    try {
      final idsParam = ids.join(',');
      final response = await dio.get('${ApiConstants.episodes}/$idsParam');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return data
              .map((e) => EpisodeModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        // Single ID returns an object, not an array
        return [EpisodeModel.fromJson(data as Map<String, dynamic>)];
      }

      throw ServerException(message: 'Status: ${response.statusCode}');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Network request failed');
    }
  }
}
