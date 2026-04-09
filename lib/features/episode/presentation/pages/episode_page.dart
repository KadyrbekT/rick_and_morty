import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/l10n/l10n_extension.dart';
import '../bloc/episode_bloc.dart';
import '../bloc/episode_event.dart';
import '../bloc/episode_state.dart';
import '../widgets/episode_card.dart';
import '../widgets/episode_filter_sheet.dart';

class EpisodePage extends StatefulWidget {
  const EpisodePage({super.key});

  @override
  State<EpisodePage> createState() => _EpisodePageState();
}

class _EpisodePageState extends State<EpisodePage>
    with AutomaticKeepAliveClientMixin {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<EpisodeBloc>().add(const FetchEpisodes());
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    if (_scrollController.offset >= maxScroll * 0.9) {
      context.read<EpisodeBloc>().add(const FetchMoreEpisodes());
    }
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        context.read<EpisodeBloc>().add(const SearchEpisodes(''));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: (q) =>
                    context.read<EpisodeBloc>().add(SearchEpisodes(q)),
                decoration: InputDecoration(
                  hintText: context.l10n.searchEpisodesHint,
                  border: InputBorder.none,
                  isDense: true,
                ),
                style: Theme.of(context).textTheme.titleMedium,
              )
            : Text(context.l10n.navEpisodes),
        actions: [
          if (!_isSearching) const _EpisodeFilterButton(),
          IconButton(
            tooltip: _isSearching ? context.l10n.closeSearch : context.l10n.search,
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
          ),
        ],
      ),
      body: BlocBuilder<EpisodeBloc, EpisodeState>(
        builder: (context, state) {
          if (state.status == EpisodeStatus.loading &&
              state.episodes.isEmpty) {
            return const _EpisodeShimmerList();
          }

          if (state.status == EpisodeStatus.failure &&
              state.episodes.isEmpty) {
            return _ErrorView(
              message: state.errorMessage ?? context.l10n.loadingError,
              onRetry: () =>
                  context.read<EpisodeBloc>().add(const FetchEpisodes()),
            );
          }

          if (state.episodes.isEmpty && state.status == EpisodeStatus.success) {
            return _EmptyView(query: state.searchQuery);
          }

          return RefreshIndicator(
            color: Theme.of(context).primaryColor,
            onRefresh: () async {
              context.read<EpisodeBloc>().add(const RefreshEpisodes());
              await context.read<EpisodeBloc>().stream.firstWhere(
                    (s) => s.status != EpisodeStatus.loading,
                  );
            },
            child: ListView.builder(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(top: 8, bottom: 80),
              itemCount: state.episodes.length + (state.isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == state.episodes.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                return EpisodeCard(episode: state.episodes[index]);
              },
            ),
          );
        },
      ),
    );
  }
}

// ─── Helper ───────────────────────────────────────────────────────────────────

Future<void> _openEpisodeFilterSheet(
  BuildContext context,
  EpisodeFilter current,
) async {
  final result = await showModalBottomSheet<EpisodeFilter>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => EpisodeFilterSheet(current: current),
  );
  if (result != null && context.mounted) {
    context.read<EpisodeBloc>().add(ApplyEpisodeFilter(result));
  }
}

// ─── Filter button with active-count badge ────────────────────────────────────

class _EpisodeFilterButton extends StatelessWidget {
  const _EpisodeFilterButton();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EpisodeBloc, EpisodeState>(
      buildWhen: (p, c) => p.filter != c.filter,
      builder: (context, state) {
        final isActive = state.filter.isActive;
        final count = state.filter.activeCount;
        return Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              tooltip: context.l10n.filterTooltip,
              icon: Icon(
                isActive ? Icons.filter_alt : Icons.filter_alt_outlined,
                color: isActive
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
              onPressed: () =>
                  _openEpisodeFilterSheet(context, state.filter),
            ),
            if (isActive)
              Positioned(
                top: 8,
                right: 8,
                child: IgnorePointer(
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.error,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$count',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _EpisodeShimmerList extends StatelessWidget {
  const _EpisodeShimmerList();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 10,
      itemBuilder: (_, _) => Shimmer.fromColors(
        baseColor:
            isDark ? const Color(0xFF1E3A5F) : Colors.grey.shade300,
        highlightColor:
            isDark ? const Color(0xFF2A5080) : Colors.grey.shade100,
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Box(width: double.infinity, height: 14),
                      const SizedBox(height: 6),
                      _Box(width: 140, height: 11),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Box extends StatelessWidget {
  final double width;
  final double height;

  const _Box({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded,
                size: 72, color: Theme.of(context).disabledColor),
            const SizedBox(height: 16),
            Text(message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(context.l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final String query;

  const _EmptyView({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded,
              size: 72, color: Theme.of(context).disabledColor),
          const SizedBox(height: 16),
          Text(
            query.isNotEmpty ? context.l10n.episodeNotFound(query) : context.l10n.emptyList,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
