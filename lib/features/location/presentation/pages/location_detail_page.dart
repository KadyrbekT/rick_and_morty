import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../home/domain/entities/character.dart';
import '../../../home/presentation/pages/character_detail_page.dart';
import '../../domain/entities/location.dart';
import '../cubit/location_detail_cubit.dart';
import '../cubit/location_detail_state.dart';

class LocationDetailPage extends StatelessWidget {
  final Location initial;

  const LocationDetailPage({super.key, required this.initial});

  static Route<void> route(Location location) {
    return MaterialPageRoute(
      builder: (_) => BlocProvider(
        create: (_) => sl<LocationDetailCubit>()..load(location),
        child: LocationDetailPage(initial: location),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocationDetailCubit, LocationDetailState>(
      builder: (context, state) {
        final location = switch (state) {
          LocationDetailLoading(:final location) => location,
          LocationDetailLoaded(:final location) => location,
          LocationDetailError(:final location) => location ?? initial,
        };

        final residents = state is LocationDetailLoaded ? state.residents : null;
        final isLoading = state is LocationDetailLoading;
        final error = state is LocationDetailError ? state.message : null;

        return _LocationDetailView(
          location: location,
          residents: residents,
          isLoading: isLoading,
          error: error,
          onRetry: () =>
              context.read<LocationDetailCubit>().retry(location),
        );
      },
    );
  }
}

class _LocationDetailView extends StatelessWidget {
  final Location location;
  final List<Character>? residents;
  final bool isLoading;
  final String? error;
  final VoidCallback onRetry;

  const _LocationDetailView({
    required this.location,
    required this.residents,
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
          // ── Styled header ─────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            stretch: true,
            backgroundColor: theme.colorScheme.surface,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => Navigator.of(context).pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              background: _LocationHeader(location: location),
            ),
          ),

          // ── Body ──────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    location.name,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  _SectionTitle(title: context.l10n.information, theme: theme),
                  const SizedBox(height: 12),
                  _InfoRow(location: location),
                  const SizedBox(height: 24),

                  _SectionTitle(
                    title: context.l10n.residentsCount(location.residentCount),
                    theme: theme,
                  ),
                  const SizedBox(height: 12),
                  _ResidentsSection(
                    location: location,
                    residents: residents,
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

class _LocationHeader extends StatelessWidget {
  final Location location;

  const _LocationHeader({required this.location});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  colorScheme.primary.withValues(alpha: 0.25),
                  colorScheme.surface,
                ]
              : [
                  colorScheme.primary.withValues(alpha: 0.15),
                  colorScheme.surface,
                ],
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
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.location_city_rounded,
                  size: 44,
                  color: colorScheme.primary,
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
  final Location location;

  const _InfoRow({required this.location});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _InfoCard(
          icon: Icons.public_rounded,
          label: context.l10n.type,
          value: location.type.isEmpty ? context.l10n.statusUnknown : location.type,
        ),
        _InfoCard(
          icon: Icons.blur_circular_rounded,
          label: context.l10n.dimension,
          value: location.dimension.isEmpty ? context.l10n.statusUnknown : location.dimension,
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

// ─── Residents section ────────────────────────────────────────────────────────

class _ResidentsSection extends StatelessWidget {
  final Location location;
  final List<Character>? residents;
  final bool isLoading;
  final String? error;
  final VoidCallback onRetry;

  const _ResidentsSection({
    required this.location,
    required this.residents,
    required this.isLoading,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (location.residentCount == 0) return const _EmptyResidents();
    if (isLoading) return const _ResidentsShimmer();
    if (error != null) return _ResidentsError(message: error!, onRetry: onRetry);
    if (residents == null || residents!.isEmpty) return const _EmptyResidents();
    return _ResidentsGrid(residents: residents!);
  }
}

class _ResidentsGrid extends StatelessWidget {
  final List<Character> residents;

  const _ResidentsGrid({required this.residents});

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
      itemCount: residents.length,
      itemBuilder: (context, index) =>
          _ResidentCard(character: residents[index]),
    );
  }
}

class _ResidentCard extends StatelessWidget {
  final Character character;

  const _ResidentCard({required this.character});

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
            // Avatar
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

            // Name + status
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

class _ResidentsShimmer extends StatelessWidget {
  const _ResidentsShimmer();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF1E3A5F) : Colors.grey.shade300;
    final highlightColor =
        isDark ? const Color(0xFF2A5080) : Colors.grey.shade100;

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
            Expanded(child: _Shimmer(baseColor: baseColor, highlightColor: highlightColor)),
            Padding(
              padding: const EdgeInsets.all(6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ShimmerBox(width: double.infinity, height: 8, color: baseColor),
                  const SizedBox(height: 4),
                  _ShimmerBox(width: 40, height: 7, color: baseColor),
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
  final Color baseColor;
  final Color highlightColor;

  const _Shimmer({required this.baseColor, required this.highlightColor});

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, _) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(_animation.value - 1, 0),
            end: Alignment(_animation.value + 1, 0),
            colors: [widget.baseColor, widget.highlightColor, widget.baseColor],
          ),
        ),
      ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final Color color;

  const _ShimmerBox({
    required this.width,
    required this.height,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

// ─── Empty / Error ────────────────────────────────────────────────────────────

class _EmptyResidents extends StatelessWidget {
  const _EmptyResidents();

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
            Text(context.l10n.noResidents,
                style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _ResidentsError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ResidentsError({required this.message, required this.onRetry});

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
