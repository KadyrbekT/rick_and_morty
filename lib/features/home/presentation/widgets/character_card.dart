import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/character.dart';
import '../bloc/character_bloc.dart';
import '../bloc/character_event.dart';
import '../bloc/character_state.dart';

class CharacterCard extends StatelessWidget {
  final Character character;
  final VoidCallback? onFavoriteTap;

  const CharacterCard({
    super.key,
    required this.character,
    this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {},
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CharacterImage(imageUrl: character.image),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      character.name,
                      style: theme.textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    _StatusRow(
                      status: character.status,
                      species: character.species,
                    ),
                    const SizedBox(height: 4),
                    _InfoRow(
                      icon: Icons.wc_outlined,
                      label: character.gender,
                      context: context,
                    ),
                    const SizedBox(height: 2),
                    _InfoRow(
                      icon: Icons.location_on_outlined,
                      label: character.locationName,
                      context: context,
                    ),
                    const SizedBox(height: 2),
                    _InfoRow(
                      icon: Icons.travel_explore_outlined,
                      label: character.originName,
                      context: context,
                    ),
                  ],
                ),
              ),
            ),
            BlocBuilder<CharacterBloc, CharacterState>(
              buildWhen: (prev, curr) =>
                  prev.favoriteIds.contains(character.id) !=
                  curr.favoriteIds.contains(character.id),
              builder: (context, state) {
                final isFav = state.favoriteIds.contains(character.id);
                return _FavoriteButton(
                  isFavorite: isFav,
                  onTap: onFavoriteTap ??
                      () => context
                          .read<CharacterBloc>()
                          .add(ToggleFavoriteEvent(character)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Версия карточки для экрана избранного (не использует CharacterBloc)
class FavoriteCharacterCard extends StatelessWidget {
  final Character character;
  final bool isFavorite;
  final VoidCallback onFavoriteTap;

  const FavoriteCharacterCard({
    super.key,
    required this.character,
    required this.isFavorite,
    required this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CharacterImage(imageUrl: character.image),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    character.name,
                    style: theme.textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  _StatusRow(
                    status: character.status,
                    species: character.species,
                  ),
                  const SizedBox(height: 4),
                  _InfoRow(
                    icon: Icons.wc_outlined,
                    label: character.gender,
                    context: context,
                  ),
                  const SizedBox(height: 2),
                  _InfoRow(
                    icon: Icons.location_on_outlined,
                    label: character.locationName,
                    context: context,
                  ),
                ],
              ),
            ),
          ),
          _FavoriteButton(isFavorite: isFavorite, onTap: onFavoriteTap),
        ],
      ),
    );
  }
}

class _CharacterImage extends StatelessWidget {
  final String imageUrl;

  const _CharacterImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(12),
        bottomLeft: Radius.circular(12),
      ),
      child: Image.network(
        imageUrl,
        width: 100,
        height: 120,
        fit: BoxFit.cover,
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return Container(
            width: 100,
            height: 120,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                value: progress.expectedTotalBytes != null
                    ? progress.cumulativeBytesLoaded /
                        progress.expectedTotalBytes!
                    : null,
                color: Theme.of(context).primaryColor,
              ),
            ),
          );
        },
        errorBuilder: (_, _, _) => Container(
          width: 100,
          height: 120,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Icon(
            Icons.broken_image_outlined,
            color: Theme.of(context).disabledColor,
          ),
        ),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final String status;
  final String species;

  const _StatusRow({required this.status, required this.species});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppTheme.statusColor(status),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            '$status · $species',
            style: Theme.of(context).textTheme.bodyMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final BuildContext context;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.context,
  });

  @override
  Widget build(BuildContext _) {
    return Row(
      children: [
        Icon(icon, size: 13, color: Theme.of(context).disabledColor),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onTap;

  const _FavoriteButton({required this.isFavorite, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 4, top: 4),
      child: IconButton(
        tooltip: isFavorite ? 'Убрать из избранного' : 'Добавить в избранное',
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, anim) => ScaleTransition(
            scale: Tween<double>(begin: 0.6, end: 1.0).animate(
              CurvedAnimation(parent: anim, curve: Curves.elasticOut),
            ),
            child: child,
          ),
          child: Icon(
            isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
            key: ValueKey(isFavorite),
            color: isFavorite ? Colors.amber : Theme.of(context).disabledColor,
            size: 28,
          ),
        ),
        onPressed: onTap,
      ),
    );
  }
}
