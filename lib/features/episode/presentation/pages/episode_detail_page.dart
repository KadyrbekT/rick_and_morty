import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../home/domain/entities/character.dart';
import '../../../home/presentation/pages/character_detail_page.dart';
import '../../domain/entities/episode.dart';
import '../cubit/episode_detail_cubit.dart';
import '../cubit/episode_detail_state.dart';

class EpisodeDetailPage extends StatelessWidget {
  final Episode initial;

  const EpisodeDetailPage({super.key, required this.initial});

  static Route<void> route(Episode episode) {
    return MaterialPageRoute(
      builder: (_) => BlocProvider(
        create: (_) => sl<EpisodeDetailCubit>()..load(episode),
        child: EpisodeDetailPage(initial: episode),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EpisodeDetailCubit, EpisodeDetailState>(
      builder: (context, state) {
        final episode = switch (state) {
          EpisodeDetailLoading(:final episode) => episode,
          EpisodeDetailLoaded(:final episode) => episode,
          EpisodeDetailError(:final episode) => episode ?? initial,
        };

        final characters =
            state is EpisodeDetailLoaded ? state.characters : null;
        final isLoading = state is EpisodeDetailLoading;
        final error =
            state is EpisodeDetailError ? state.message : null;

        return _EpisodeDetailView(
          episode: episode,
          characters: characters,
          isLoading: isLoading,
          error: error,
          onRetry: () =>
              context.read<EpisodeDetailCubit>().retry(episode),
        );
      },
    );
  }
}

// ─── Main view ────────────────────────────────────────────────────────────────

class _EpisodeDetailView extends StatelessWidget {
  final Episode episode;
  final List<Character>? characters;
  final bool isLoading;
  final String? error;
  final VoidCallback onRetry;

  const _EpisodeDetailView({
    required this.episode,
    required this.characters,
    required this.isLoading,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            stretch: true,
            backgroundColor: theme.colorScheme.surface,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => Navigator.of(context).pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              background: _EpisodeHeader(episode: episode),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    episode.name,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  _SectionTitle(title: context.l10n.information, theme: theme),
                  const SizedBox(height: 12),
                  _InfoRow(episode: episode),
                  const SizedBox(height: 24),

                  _SectionTitle(
                    title: context.l10n.episodeCharactersCount(episode.characterCount),
                    theme: theme,
                  ),
                  const SizedBox(height: 12),
                  _CharactersSection(
                    episode: episode,
                    characters: characters,
                    isLoading: isLoading,
                    error: error,
                    onRetry: onRetry,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _EpisodeHeader extends StatelessWidget {
  final Episode episode;

  const _EpisodeHeader({required this.episode});

  Color _seasonColor(BuildContext context) {
    final colors = [
      const Color(0xFF97CE4C),
      const Color(0xFF2196F3),
      const Color(0xFFFF9800),
      const Color(0xFFE91E63),
      const Color(0xFF9C27B0),
      const Color(0xFF00BCD4),
      const Color(0xFFFF5722),
    ];
    final idx = (episode.season - 1).clamp(0, colors.length - 1);
    return colors[idx];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = _seasonColor(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [accentColor.withValues(alpha: 0.3), Theme.of(context).colorScheme.surface]
              : [accentColor.withValues(alpha: 0.18), Theme.of(context).colorScheme.surface],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 48),
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.4),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    episode.episode,
                    style: TextStyle(
                      color: accentColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Info row ─────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final Episode episode;

  const _InfoRow({required this.episode});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _InfoCard(
          icon: Icons.calendar_today_outlined,
          label: context.l10n.airDate,
          value: episode.airDate,
        ),
        _InfoCard(
          icon: Icons.tv_rounded,
          label: context.l10n.episodeCode,
          value: episode.episode,
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 140),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.primary.withValues(alpha: 0.15),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: colorScheme.primary),
            const SizedBox(width: 8),
            Flexible(
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
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Section title ────────────────────────────────────────────────────────────

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

// ─── Characters section ───────────────────────────────────────────────────────

class _CharactersSection extends StatelessWidget {
  final Episode episode;
  final List<Character>? characters;
  final bool isLoading;
  final String? error;
  final VoidCallback onRetry;

  const _CharactersSection({
    required this.episode,
    required this.characters,
    required this.isLoading,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (episode.characterCount == 0) return const _EmptyCharacters();
    if (isLoading) return const _CharactersShimmer();
    if (error != null) return _CharactersError(message: error!, onRetry: onRetry);
    if (characters == null || characters!.isEmpty) return const _EmptyCharacters();
    return _CharactersGrid(characters: characters!);
  }
}

class _CharactersGrid extends StatelessWidget {
  final List<Character> characters;

  const _CharactersGrid({required this.characters});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.7,
      ),
      itemCount: characters.length,
      itemBuilder: (context, index) =>
          _CharacterCard(character: characters[index]),
    );
  }
}

class _CharacterCard extends StatelessWidget {
  final Character character;

  const _CharacterCard({required this.character});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final statusColor = AppTheme.statusColor(character.status);

    return GestureDetector(
      onTap: () =>
          Navigator.of(context).push(CharacterDetailPage.route(character)),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Hero(
                tag: 'character_image_${character.id}',
                child: Image.network(
                  character.image,
                  fit: BoxFit.cover,
                  loadingBuilder: (_, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      color: colorScheme.surfaceContainerHighest,
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  },
                  errorBuilder: (_, _, _) => Container(
                    color: colorScheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.broken_image_outlined,
                      size: 32,
                      color: theme.disabledColor,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 6, 6, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    character.name,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          character.status,
                          style: TextStyle(
                            fontSize: 10,
                            color: statusColor,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Shimmer ──────────────────────────────────────────────────────────────────

class _CharactersShimmer extends StatelessWidget {
  const _CharactersShimmer();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? const Color(0xFF1E3A5F) : Colors.grey.shade300;
    final highlight = isDark ? const Color(0xFF2A5080) : Colors.grey.shade100;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.7,
      ),
      itemCount: 9,
      itemBuilder: (_, _) => Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: _Shimmer(base: base, highlight: highlight)),
            Padding(
              padding: const EdgeInsets.all(6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Box(w: double.infinity, h: 8, color: base),
                  const SizedBox(height: 4),
                  _Box(w: 40, h: 7, color: base),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Shimmer extends StatefulWidget {
  final Color base;
  final Color highlight;
  const _Shimmer({required this.base, required this.highlight});

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
          ..repeat();
    _anim = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _anim,
        builder: (_, _) => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(_anim.value - 1, 0),
              end: Alignment(_anim.value + 1, 0),
              colors: [widget.base, widget.highlight, widget.base],
            ),
          ),
        ),
      );
}

class _Box extends StatelessWidget {
  final double w;
  final double h;
  final Color color;
  const _Box({required this.w, required this.h, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        width: w,
        height: h,
        decoration:
            BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
      );
}

// ─── Empty / Error ────────────────────────────────────────────────────────────

class _EmptyCharacters extends StatelessWidget {
  const _EmptyCharacters();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            Icon(Icons.people_outline_rounded,
                size: 56, color: Theme.of(context).disabledColor),
            const SizedBox(height: 12),
            Text(context.l10n.noEpisodeCharacters,
                style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _CharactersError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _CharactersError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded,
                size: 48, color: Theme.of(context).disabledColor),
            const SizedBox(height: 8),
            Text(message, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 16),
              label: Text(context.l10n.retryShort),
            ),
          ],
        ),
      ),
    );
  }
}
