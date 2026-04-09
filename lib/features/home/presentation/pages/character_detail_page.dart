import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/character.dart';
import '../bloc/character_bloc.dart';
import '../bloc/character_event.dart';
import '../bloc/character_state.dart';
import '../cubit/character_detail_cubit.dart';
import '../cubit/character_detail_state.dart';

class CharacterDetailPage extends StatelessWidget {
  final Character character;

  const CharacterDetailPage({super.key, required this.character});

  static Route<void> route(Character character) {
    return MaterialPageRoute(
      builder: (_) => BlocProvider(
        create: (_) => CharacterDetailCubit(
          getCharacterById: sl(),
        )..load(character),
        child: CharacterDetailPage(character: character),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CharacterDetailCubit, CharacterDetailState>(
      builder: (context, state) {
        final c = state is CharacterDetailLoaded ? state.character : character;
        return _DetailView(character: c);
      },
    );
  }
}

class _DetailView extends StatelessWidget {
  final Character character;

  const _DetailView({required this.character});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final statusColor = AppTheme.statusColor(character.status);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Hero SliverAppBar ──────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            stretch: true,
            backgroundColor: colorScheme.surface,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              BlocBuilder<CharacterBloc, CharacterState>(
                buildWhen: (prev, curr) =>
                    prev.favoriteIds.contains(character.id) !=
                    curr.favoriteIds.contains(character.id),
                builder: (context, state) {
                  final isFav = state.favoriteIds.contains(character.id);
                  return IconButton(
                    tooltip: isFav
                        ? context.l10n.removeFromFavorites
                        : context.l10n.addToFavorites,
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, anim) => ScaleTransition(
                        scale: Tween<double>(begin: 0.6, end: 1.0).animate(
                          CurvedAnimation(
                              parent: anim, curve: Curves.elasticOut),
                        ),
                        child: child,
                      ),
                      child: Icon(
                        isFav
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        key: ValueKey(isFav),
                        color: isFav ? Colors.amber : null,
                        size: 28,
                      ),
                    ),
                    onPressed: () => context
                        .read<CharacterBloc>()
                        .add(ToggleFavoriteEvent(character)),
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
              ],
              background: Hero(
                tag: 'character_image_${character.id}',
                child: Image.network(
                  character.image,
                  fit: BoxFit.cover,
                  loadingBuilder: (_, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      color: colorScheme.surfaceContainerHighest,
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          value: progress.expectedTotalBytes != null
                              ? progress.cumulativeBytesLoaded /
                                  progress.expectedTotalBytes!
                              : null,
                          color: colorScheme.primary,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (_, _, _) => Container(
                    color: colorScheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.broken_image_outlined,
                      size: 64,
                      color: theme.disabledColor,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Content ───────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + status badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          character.name,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: statusColor.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: statusColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              character.status,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ── Info Grid ─────────────────────────────────────────────
                  _SectionTitle(title: context.l10n.characterTraits, theme: theme),
                  const SizedBox(height: 12),
                  _InfoGrid(character: character),

                  const SizedBox(height: 24),

                  // ── Locations ─────────────────────────────────────────────
                  _SectionTitle(title: context.l10n.characterLocations, theme: theme),
                  const SizedBox(height: 12),
                  _LocationSection(character: character),

                  if (character.episodeIds.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    // ── Episodes ──────────────────────────────────────────
                    _SectionTitle(
                      title: context.l10n.characterEpisodesCount(character.episodeIds.length),
                      theme: theme,
                    ),
                    const SizedBox(height: 12),
                    _EpisodeChips(episodeIds: character.episodeIds),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section title ──────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  final ThemeData theme;

  const _SectionTitle({required this.title, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        color: theme.colorScheme.primary,
        letterSpacing: 0.5,
      ),
    );
  }
}

// ── 2-column info grid ─────────────────────────────────────────────────────

class _InfoGrid extends StatelessWidget {
  final Character character;

  const _InfoGrid({required this.character});

  @override
  Widget build(BuildContext context) {
    final items = [
      _InfoItem(label: context.l10n.species, value: character.species),
      _InfoItem(label: context.l10n.gender, value: character.gender),
      if (character.type.isNotEmpty)
        _InfoItem(label: context.l10n.type, value: character.type, fullWidth: true),
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: items,
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;
  final bool fullWidth;

  const _InfoItem({
    required this.label,
    required this.value,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final card = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );

    if (fullWidth) {
      return SizedBox(width: double.infinity, child: card);
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 140),
      child: card,
    );
  }
}

// ── Location cards ─────────────────────────────────────────────────────────

class _LocationSection extends StatelessWidget {
  final Character character;

  const _LocationSection({required this.character});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _LocationTile(
          icon: Icons.travel_explore_outlined,
          label: context.l10n.origin,
          value: character.originName,
        ),
        const SizedBox(height: 8),
        _LocationTile(
          icon: Icons.location_on_outlined,
          label: context.l10n.lastLocation,
          value: character.locationName,
        ),
      ],
    );
  }
}

class _LocationTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _LocationTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Episode chips ──────────────────────────────────────────────────────────

class _EpisodeChips extends StatelessWidget {
  final List<int> episodeIds;

  const _EpisodeChips({required this.episodeIds});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: episodeIds.map((id) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: primary.withValues(alpha: 0.3)),
          ),
          child: Text(
            'Ep. $id',
            style: theme.textTheme.bodySmall?.copyWith(
              color: primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }).toList(),
    );
  }
}
