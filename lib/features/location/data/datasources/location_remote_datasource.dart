import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/location_model.dart';

abstract class LocationRemoteDataSource {
  Future<({List<LocationModel> locations, bool hasMore})> getLocations(
    int page, {
    String? name,
    String? type,
    String? dimension,
  });

  Future<LocationModel> getLocationById(int id);

  Future<List<LocationModel>> getMultipleLocations(List<int> ids);
}

class LocationRemoteDataSourceImpl implements LocationRemoteDataSource {
  final Dio dio;

  LocationRemoteDataSourceImpl(this.dio);

  @override
  Future<({List<LocationModel> locations, bool hasMore})> getLocations(
    int page, {
    String? name,
    String? type,
    String? dimension,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page};
      if (name != null && name.isNotEmpty) queryParams['name'] = name;
      if (type != null && type.isNotEmpty) queryParams['type'] = type;
      if (dimension != null && dimension.isNotEmpty) queryParams['dimension'] = dimension;

      final response = await dio.get(
        ApiConstants.locations,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final info = data['info'] as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>;

        return (
          locations: results
              .map((e) => LocationModel.fromJson(e as Map<String, dynamic>))
              .toList(),
          hasMore: info['next'] != null,
        );
      }

      throw ServerException(message: 'Status: ${response.statusCode}');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return (locations: <LocationModel>[], hasMore: false);
      }
      throw ServerException(message: e.message ?? 'Network request failed');
    }
  }

  @override
  Future<LocationModel> getLocationById(int id) async {
    try {
      final response = await dio.get('${ApiConstants.locations}/$id');

      if (response.statusCode == 200) {
        return LocationModel.fromJson(response.data as Map<String, dynamic>);
      }

      throw ServerException(message: 'Status: ${response.statusCode}');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Network request failed');
    }
  }

  @override
  Future<List<LocationModel>> getMultipleLocations(List<int> ids) async {
    try {
      final idsParam = ids.join(',');
      final response = await dio.get('${ApiConstants.locations}/$idsParam');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return data
              .map((e) => LocationModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        // Single ID returns an object, not an array
        return [LocationModel.fromJson(data as Map<String, dynamic>)];
      }

      throw ServerException(message: 'Status: ${response.statusCode}');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Network request failed');
    }
  }
}
