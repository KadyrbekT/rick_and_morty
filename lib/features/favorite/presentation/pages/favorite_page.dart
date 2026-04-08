import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../home/presentation/widgets/character_card.dart';
import '../bloc/favorite_bloc.dart';
import '../bloc/favorite_event.dart';
import '../bloc/favorite_state.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => false; // Reload on every visit to stay in sync

  @override
  void initState() {
    super.initState();
    context.read<FavoriteBloc>().add(const LoadFavorites());
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Избранное'),
        actions: [
          BlocBuilder<FavoriteBloc, FavoriteState>(
            builder: (context, state) {
              if (state.favorites.isEmpty) return const SizedBox.shrink();
              return IconButton(
                tooltip: 'Очистить избранное',
                icon: const Icon(Icons.delete_sweep_outlined),
                onPressed: () => _confirmClearAll(context),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<FavoriteBloc, FavoriteState>(
        builder: (context, state) {
          if (state.status == FavoriteStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == FavoriteStatus.failure) {
            return Center(
              child: Text(
                state.errorMessage ?? 'Ошибка загрузки',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            );
          }

          if (state.favorites.isEmpty) {
            return _EmptyFavoritesView();
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            itemCount: state.favorites.length,
            itemBuilder: (context, index) {
              final character = state.favorites[index];
              return Dismissible(
                key: ValueKey(character.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red.shade700,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.delete_outline, color: Colors.white),
                ),
                onDismissed: (_) {
                  context
                      .read<FavoriteBloc>()
                      .add(RemoveFavoriteEvent(character.id));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${character.name} удалён из избранного'),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: FavoriteCharacterCard(
                  character: character,
                  isFavorite: true,
                  onFavoriteTap: () {
                    context
                        .read<FavoriteBloc>()
                        .add(RemoveFavoriteEvent(character.id));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${character.name} удалён из избранного'),
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _confirmClearAll(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Очистить избранное?'),
        content: const Text('Все персонажи будут удалены из избранного.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Очистить'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final bloc = context.read<FavoriteBloc>();
      final favorites = List.from(bloc.state.favorites);
      for (final c in favorites) {
        bloc.add(RemoveFavoriteEvent(c.id));
      }
    }
  }
}

class _EmptyFavoritesView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star_border_rounded,
            size: 80,
            color: Theme.of(context).disabledColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Избранных персонажей нет',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.normal,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Нажмите ★ на карточке персонажа,\nчтобы добавить его в избранное',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
