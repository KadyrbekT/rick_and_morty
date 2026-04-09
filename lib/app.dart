import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/di/injection_container.dart';
import 'core/l10n/l10n_extension.dart';
import 'presentation/loader/overlay_loader.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'features/episode/presentation/bloc/episode_bloc.dart';
import 'features/episode/presentation/pages/episode_page.dart';
import 'features/favorite/presentation/bloc/favorite_bloc.dart';
import 'features/favorite/presentation/bloc/favorite_event.dart';
import 'features/favorite/presentation/pages/favorite_page.dart';
import 'features/home/presentation/bloc/character_bloc.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/location/presentation/bloc/location_bloc.dart';
import 'features/location/presentation/pages/location_page.dart';

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
            builder: (context, child) => AppOverlayLoader(child: child!),
            home: const _MainScaffold(),
          );
        },
      ),
    );
  }
}

class _MainScaffold extends StatefulWidget {
  const _MainScaffold();

  @override
  State<_MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<_MainScaffold> {
  int _currentIndex = 0;

  static const _pages = <Widget>[
    _KeepAlivePage(child: HomePage()),
    _KeepAlivePage(child: LocationPage()),
    _KeepAlivePage(child: EpisodePage()),
    _KeepAlivePage(child: FavoritePage()),
  ];

  void _onTabTap(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);

    if (index == 3) {
      context.read<FavoriteBloc>().add(const LoadFavorites());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTap,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.people_outline_rounded),
            activeIcon: const Icon(Icons.people_rounded),
            label: context.l10n.navCharacters,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.location_on_outlined),
            activeIcon: const Icon(Icons.location_on_rounded),
            label: context.l10n.navLocations,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.tv_outlined),
            activeIcon: const Icon(Icons.tv_rounded),
            label: context.l10n.navEpisodes,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.star_border_rounded),
            activeIcon: const Icon(Icons.star_rounded),
            label: context.l10n.navFavorites,
          ),
        ],
      ),
    );
  }
}

// Keeps child alive in IndexedStack so scroll position is preserved
class _KeepAlivePage extends StatefulWidget {
  final Widget child;

  const _KeepAlivePage({required this.child});

  @override
  State<_KeepAlivePage> createState() => _KeepAlivePageState();
}

class _KeepAlivePageState extends State<_KeepAlivePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
