import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/episode/data/datasources/episode_local_datasource.dart';
import '../../features/episode/data/datasources/episode_remote_datasource.dart';
import '../../features/episode/data/repositories/episode_repository_impl.dart';
import '../../features/episode/domain/repositories/episode_repository.dart';
import '../../features/episode/domain/usecases/get_episode_by_id.dart';
import '../../features/episode/domain/usecases/get_episodes.dart';
import '../../features/episode/domain/usecases/get_multiple_episodes.dart';
import '../../features/episode/presentation/bloc/episode_bloc.dart';
import '../../features/episode/presentation/cubit/episode_detail_cubit.dart';
import '../../features/favorite/data/repositories/favorite_repository_impl.dart';
import '../../features/favorite/domain/repositories/favorite_repository.dart';
import '../../features/favorite/domain/usecases/get_favorites.dart';
import '../../features/favorite/domain/usecases/toggle_favorite.dart';
import '../../features/favorite/presentation/bloc/favorite_bloc.dart';
import '../../features/home/data/datasources/character_local_datasource.dart';
import '../../features/home/data/datasources/character_remote_datasource.dart';
import '../../features/home/data/repositories/character_repository_impl.dart';
import '../../features/home/domain/repositories/character_repository.dart';
import '../../features/home/domain/usecases/get_character_by_id.dart';
import '../../features/home/domain/usecases/get_characters.dart';
import '../../features/home/domain/usecases/get_multiple_characters.dart';
import '../../features/home/presentation/bloc/character_bloc.dart';
import '../../features/home/presentation/cubit/character_detail_cubit.dart';
import '../../features/location/data/datasources/location_local_datasource.dart';
import '../../features/location/data/datasources/location_remote_datasource.dart';
import '../../features/location/data/repositories/location_repository_impl.dart';
import '../../features/location/domain/repositories/location_repository.dart';
import '../../features/location/domain/usecases/get_location_by_id.dart';
import '../../features/location/domain/usecases/get_locations.dart';
import '../../features/location/domain/usecases/get_multiple_locations.dart';
import '../../features/location/presentation/bloc/location_bloc.dart';
import '../../features/location/presentation/cubit/location_detail_cubit.dart';
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
  sl.registerLazySingleton<ThemeCubit>(
    () => ThemeCubit(sl<SharedPreferences>()),
  );

  // ── Character ──────────────────────────────────────────────────────────────
  sl.registerLazySingleton<CharacterRemoteDataSource>(
    () => CharacterRemoteDataSourceImpl(sl<Dio>()),
  );
  sl.registerLazySingleton<CharacterLocalDataSource>(
    () => CharacterLocalDataSourceImpl(sl<SharedPreferences>()),
  );
  sl.registerLazySingleton<CharacterRepository>(
    () => CharacterRepositoryImpl(
      remoteDataSource: sl<CharacterRemoteDataSource>(),
      localDataSource: sl<CharacterLocalDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );
  sl.registerLazySingleton(() => GetCharacters(sl<CharacterRepository>()));
  sl.registerLazySingleton(() => GetCharacterById(sl<CharacterRepository>()));
  sl.registerLazySingleton(
    () => GetMultipleCharacters(sl<CharacterRepository>()),
  );

  // ── Favorite ───────────────────────────────────────────────────────────────
  sl.registerLazySingleton<FavoriteRepository>(
    () => FavoriteRepositoryImpl(sl<SharedPreferences>()),
  );
  sl.registerLazySingleton(() => GetFavorites(sl<FavoriteRepository>()));
  sl.registerLazySingleton(() => ToggleFavorite(sl<FavoriteRepository>()));

  // ── Location ───────────────────────────────────────────────────────────────
  sl.registerLazySingleton<LocationRemoteDataSource>(
    () => LocationRemoteDataSourceImpl(sl<Dio>()),
  );
  sl.registerLazySingleton<LocationLocalDataSource>(
    () => LocationLocalDataSourceImpl(sl<SharedPreferences>()),
  );
  sl.registerLazySingleton<LocationRepository>(
    () => LocationRepositoryImpl(
      remoteDataSource: sl<LocationRemoteDataSource>(),
      localDataSource: sl<LocationLocalDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );
  sl.registerLazySingleton(() => GetLocations(sl<LocationRepository>()));
  sl.registerLazySingleton(() => GetLocationById(sl<LocationRepository>()));
  sl.registerLazySingleton(
    () => GetMultipleLocations(sl<LocationRepository>()),
  );

  // ── Episode ────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<EpisodeRemoteDataSource>(
    () => EpisodeRemoteDataSourceImpl(sl<Dio>()),
  );
  sl.registerLazySingleton<EpisodeLocalDataSource>(
    () => EpisodeLocalDataSourceImpl(sl<SharedPreferences>()),
  );
  sl.registerLazySingleton<EpisodeRepository>(
    () => EpisodeRepositoryImpl(
      remoteDataSource: sl<EpisodeRemoteDataSource>(),
      localDataSource: sl<EpisodeLocalDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );
  sl.registerLazySingleton(() => GetEpisodes(sl<EpisodeRepository>()));
  sl.registerLazySingleton(() => GetEpisodeById(sl<EpisodeRepository>()));
  sl.registerLazySingleton(() => GetMultipleEpisodes(sl<EpisodeRepository>()));

  // ── BLoCs (factory — new instance per request) ─────────────────────────────
  sl.registerFactory(
    () => CharacterDetailCubit(getCharacterById: sl<GetCharacterById>()),
  );
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
  sl.registerFactory(() => LocationBloc(getLocations: sl<GetLocations>()));
  sl.registerFactory(
    () => LocationDetailCubit(
      getLocationById: sl<GetLocationById>(),
      getMultipleCharacters: sl<GetMultipleCharacters>(),
    ),
  );
  sl.registerFactory(() => EpisodeBloc(getEpisodes: sl<GetEpisodes>()));
  sl.registerFactory(
    () => EpisodeDetailCubit(
      getEpisodeById: sl<GetEpisodeById>(),
      getMultipleCharacters: sl<GetMultipleCharacters>(),
    ),
  );
}
