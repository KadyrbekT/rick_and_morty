import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/l10n/l10n_extension.dart';
import '../../features/episode/presentation/pages/episode_page.dart';
import '../../features/favorite/presentation/bloc/favorite_bloc.dart';
import '../../features/favorite/presentation/bloc/favorite_event.dart';
import '../../features/favorite/presentation/pages/favorite_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/location/presentation/pages/location_page.dart';

/// Bottom-navigation shell. Each tab is kept alive in an [IndexedStack]
/// so scroll position is preserved when switching tabs.
class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
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

/// Wraps a page so its state survives tab switches in [IndexedStack].
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
