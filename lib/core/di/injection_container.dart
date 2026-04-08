import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/favorite/data/repositories/favorite_repository_impl.dart';
import '../../features/favorite/domain/repositories/favorite_repository.dart';
import '../../features/favorite/domain/usecases/get_favorites.dart';
import '../../features/favorite/domain/usecases/toggle_favorite.dart';
import '../../features/favorite/presentation/bloc/favorite_bloc.dart';
import '../../features/home/data/datasources/character_local_datasource.dart';
import '../../features/home/data/datasources/character_remote_datasource.dart';
import '../../features/home/data/repositories/character_repository_impl.dart';
import '../../features/home/domain/repositories/character_repository.dart';
import '../../features/home/domain/usecases/get_characters.dart';
import '../../features/home/presentation/bloc/character_bloc.dart';
import '../network/dio_client.dart';
import '../network/network_info.dart';
import '../theme/theme_cubit.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // External
  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);
  sl.registerSingleton<Dio>(DioClient.create());
  sl.registerSingleton<Connectivity>(Connectivity());

  // Core
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(sl<Connectivity>()),
  );
  sl.registerLazySingleton<ThemeCubit>(() => ThemeCubit(sl<SharedPreferences>()));

  // Data Sources
  sl.registerLazySingleton<CharacterRemoteDataSource>(
    () => CharacterRemoteDataSourceImpl(sl<Dio>()),
  );
  sl.registerLazySingleton<CharacterLocalDataSource>(
    () => CharacterLocalDataSourceImpl(sl<SharedPreferences>()),
  );

  // Repositories
  sl.registerLazySingleton<CharacterRepository>(
    () => CharacterRepositoryImpl(
      remoteDataSource: sl<CharacterRemoteDataSource>(),
      localDataSource: sl<CharacterLocalDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );
  sl.registerLazySingleton<FavoriteRepository>(
    () => FavoriteRepositoryImpl(sl<SharedPreferences>()),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetCharacters(sl<CharacterRepository>()));
  sl.registerLazySingleton(() => GetFavorites(sl<FavoriteRepository>()));
  sl.registerLazySingleton(() => ToggleFavorite(sl<FavoriteRepository>()));

  // BLoCs (factory — новый экземпляр при каждом запросе)
  sl.registerFactory(
    () => CharacterBloc(
      getCharacters: sl<GetCharacters>(),
      toggleFavorite: sl<ToggleFavorite>(),
      favoriteRepository: sl<FavoriteRepository>(),
    ),
  );
  sl.registerFactory(
    () => FavoriteBloc(
      getFavorites: sl<GetFavorites>(),
      favoriteRepository: sl<FavoriteRepository>(),
    ),
  );
}
