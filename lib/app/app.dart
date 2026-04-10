import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/di/injection_container.dart';
import '../core/network/connectivity_banner.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/theme_cubit.dart';
import '../features/episode/presentation/bloc/episode_bloc.dart';
import '../features/favorite/presentation/bloc/favorite_bloc.dart';
import '../features/home/presentation/bloc/character_bloc.dart';
import '../features/location/presentation/bloc/location_bloc.dart';
import '../l10n/app_localizations.dart';
import '../core/widgets/overlay_loader.dart';
import 'view/main_scaffold.dart';

/// Root widget. Wires up global BLoC providers, theming, localisation,
/// the connectivity banner and the overlay loader — then hands off to
/// [MainScaffold] for navigation.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<ThemeCubit>()),
        BlocProvider(create: (_) => sl<CharacterBloc>()),
        BlocProvider(create: (_) => sl<FavoriteBloc>()),
        BlocProvider(create: (_) => sl<LocationBloc>()),
        BlocProvider(create: (_) => sl<EpisodeBloc>()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: 'Rick & Morty',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeMode,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (context, child) => ConnectivityBanner(
              child: AppOverlayLoader(child: child!),
            ),
            home: const MainScaffold(),
          );
        },
      ),
    );
  }
}
