import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/l10n/l10n_extension.dart';
import '../bloc/location_bloc.dart';
import '../bloc/location_event.dart';
import '../bloc/location_state.dart';
import '../widgets/location_card.dart';
import '../widgets/location_filter_sheet.dart';

class LocationPage extends StatefulWidget {
  const LocationPage({super.key});

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage>
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
    context.read<LocationBloc>().add(const FetchLocations());
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
      context.read<LocationBloc>().add(const FetchMoreLocations());
    }
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        context.read<LocationBloc>().add(const SearchLocations(''));
      }
    });
  }

  Future<void> _openFilterSheet(LocationFilter current) async {
    final result = await showModalBottomSheet<LocationFilter>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => LocationFilterSheet(current: current),
    );
    if (result != null && mounted) {
      context.read<LocationBloc>().add(ApplyLocationFilter(result));
    }
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
                    context.read<LocationBloc>().add(SearchLocations(q)),
                decoration: InputDecoration(
                  hintText: context.l10n.searchLocationsHint,
                  border: InputBorder.none,
                  isDense: true,
                ),
                style: Theme.of(context).textTheme.titleMedium,
              )
            : Text(context.l10n.navLocations),
        actions: [
          IconButton(
            tooltip: _isSearching ? context.l10n.closeSearch : context.l10n.search,
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
          ),
          _LocationFilterButton(onTap: _openFilterSheet),
        ],
      ),
      body: BlocBuilder<LocationBloc, LocationState>(
        builder: (context, state) {
          if (state.status == LocationStatus.loading &&
              state.locations.isEmpty) {
            return const _LocationShimmerList();
          }

          if (state.status == LocationStatus.failure &&
              state.locations.isEmpty) {
            return _ErrorView(
              message: state.errorMessage ?? context.l10n.loadingError,
              onRetry: () =>
                  context.read<LocationBloc>().add(const FetchLocations()),
            );
          }

          if (state.locations.isEmpty &&
              state.status == LocationStatus.success) {
            return _EmptyView(query: state.searchQuery);
          }

          return RefreshIndicator(
            color: Theme.of(context).primaryColor,
            onRefresh: () async {
              context.read<LocationBloc>().add(const RefreshLocations());
              await context.read<LocationBloc>().stream.firstWhere(
                    (s) => s.status != LocationStatus.loading,
                  );
            },
            child: ListView.builder(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(top: 8, bottom: 80),
              itemCount:
                  state.locations.length + (state.isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == state.locations.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                return LocationCard(location: state.locations[index]);
              },
            ),
          );
        },
      ),
    );
  }
}

// ─── Filter button ────────────────────────────────────────────────────────────

class _LocationFilterButton extends StatelessWidget {
  final void Function(LocationFilter current) onTap;

  const _LocationFilterButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocationBloc, LocationState>(
      buildWhen: (prev, curr) => prev.filter != curr.filter,
      builder: (context, state) {
        final count = state.filter.activeCount;
        return Stack(
          alignment: Alignment.topRight,
          children: [
            IconButton(
              tooltip: context.l10n.filters,
              icon: Icon(
                Icons.filter_list_rounded,
                color: state.filter.isActive
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
              onPressed: () => onTap(state.filter),
            ),
            if (count > 0)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
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
          ],
        );
      },
    );
  }
}

// ─── Shimmer ──────────────────────────────────────────────────────────────────

class _LocationShimmerList extends StatelessWidget {
  const _LocationShimmerList();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 10,
      itemBuilder: (_, _) => Shimmer.fromColors(
        baseColor: isDark ? const Color(0xFF1E3A5F) : Colors.grey.shade300,
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
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Box(width: double.infinity, height: 14),
                      const SizedBox(height: 6),
                      _Box(width: 120, height: 11),
                      const SizedBox(height: 4),
                      _Box(width: 160, height: 11),
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

// ─── Error / Empty views ──────────────────────────────────────────────────────

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
            query.isNotEmpty
                ? context.l10n.locationNotFound(query)
                : context.l10n.emptyList,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
