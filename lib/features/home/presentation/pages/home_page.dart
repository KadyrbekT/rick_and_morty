import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../bloc/character_bloc.dart';
import '../bloc/character_event.dart';
import '../bloc/character_state.dart';
import '../widgets/character_card.dart';
import '../widgets/character_filter_sheet.dart';
import '../widgets/character_shimmer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<CharacterBloc>().add(const FetchCharacters());
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
      context.read<CharacterBloc>().add(const FetchMoreCharacters());
    }
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        context.read<CharacterBloc>().add(const SearchCharacters(''));
      }
    });
  }

  Future<void> _openFilterSheet(CharacterFilter current) async {
    final result = await showModalBottomSheet<CharacterFilter>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => CharacterFilterSheet(current: current),
    );
    if (result != null && mounted) {
      context.read<CharacterBloc>().add(ApplyCharacterFilter(result));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: (q) =>
                    context.read<CharacterBloc>().add(SearchCharacters(q)),
                decoration: InputDecoration(
                  hintText: context.l10n.searchCharactersHint,
                  border: InputBorder.none,
                  isDense: true,
                ),
                style: Theme.of(context).textTheme.titleMedium,
              )
            : const Text('Rick & Morty'),
        actions: [
          IconButton(
            tooltip: _isSearching ? context.l10n.closeSearch : context.l10n.search,
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
          ),
          _FilterButton(onTap: _openFilterSheet),
          _SortButton(),
          IconButton(
            tooltip: context.l10n.changeTheme,
            icon: BlocBuilder<ThemeCubit, ThemeMode>(
              builder: (_, mode) => Icon(
                mode == ThemeMode.dark
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
              ),
            ),
            onPressed: () => context.read<ThemeCubit>().toggle(),
          ),
        ],
      ),
      body: BlocBuilder<CharacterBloc, CharacterState>(
        builder: (context, state) {
          if (state.status == CharacterStatus.loading &&
              state.characters.isEmpty) {
            return const CharacterShimmerList();
          }

          if (state.status == CharacterStatus.failure &&
              state.characters.isEmpty) {
            return _ErrorView(
              message: state.errorMessage ?? context.l10n.loadingError,
              onRetry: () =>
                  context.read<CharacterBloc>().add(const FetchCharacters()),
            );
          }

          final characters = state.filteredCharacters;

          if (characters.isEmpty && state.status == CharacterStatus.success) {
            return _EmptyView(query: state.searchQuery);
          }

          return RefreshIndicator(
            color: Theme.of(context).primaryColor,
            onRefresh: () async {
              context.read<CharacterBloc>().add(const RefreshCharacters());
              await context.read<CharacterBloc>().stream.firstWhere(
                    (s) => s.status != CharacterStatus.loading,
                  );
            },
            child: ListView.builder(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(top: 8, bottom: 80),
              itemCount: characters.length + (state.isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == characters.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                return CharacterCard(character: characters[index]);
              },
            ),
          );
        },
      ),
    );
  }
}

// ─── Filter button ────────────────────────────────────────────────────────────

class _FilterButton extends StatelessWidget {
  final void Function(CharacterFilter current) onTap;

  const _FilterButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CharacterBloc, CharacterState>(
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

// ─── Sort button ─────────────────────────────────────────────────────────────

class _SortButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CharacterBloc, CharacterState>(
      buildWhen: (prev, curr) => prev.sortBy != curr.sortBy,
      builder: (context, state) {
        final isActive = state.sortBy != SortBy.none;
        return PopupMenuButton<SortBy>(
          tooltip: context.l10n.sortBy,
          icon: Icon(
            Icons.sort_rounded,
            color: isActive ? Theme.of(context).primaryColor : null,
          ),
          onSelected: (sort) =>
              context.read<CharacterBloc>().add(SortCharactersEvent(sort)),
          itemBuilder: (ctx) => [
            _sortItem(SortBy.none, ctx.l10n.sortDefault, Icons.list, state.sortBy),
            _sortItem(SortBy.nameAsc, ctx.l10n.sortNameAsc, Icons.sort_by_alpha, state.sortBy),
            _sortItem(SortBy.nameDesc, ctx.l10n.sortNameDesc, Icons.sort_by_alpha, state.sortBy),
            _sortItem(SortBy.statusAlive, ctx.l10n.sortAliveFirst, Icons.favorite_border, state.sortBy),
            _sortItem(SortBy.statusDead, ctx.l10n.sortDeadFirst, Icons.heart_broken_outlined, state.sortBy),
          ],
        );
      },
    );
  }

  PopupMenuItem<SortBy> _sortItem(
    SortBy value,
    String label,
    IconData icon,
    SortBy current,
  ) {
    final isSelected = current == value;
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18, color: isSelected ? Colors.amber : null),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          if (isSelected) ...[
            const Spacer(),
            const Icon(Icons.check, size: 16, color: Colors.amber),
          ],
        ],
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
                ? context.l10n.characterNotFound(query)
                : context.l10n.emptyList,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
