import 'package:flutter/material.dart';
import '../../../../core/l10n/l10n_extension.dart';
import '../bloc/episode_event.dart';

/// Bottom sheet for filtering episodes by season or specific episode code.
class EpisodeFilterSheet extends StatefulWidget {
  final EpisodeFilter current;

  const EpisodeFilterSheet({super.key, required this.current});

  @override
  State<EpisodeFilterSheet> createState() => _EpisodeFilterSheetState();
}

class _EpisodeFilterSheetState extends State<EpisodeFilterSheet> {
  final _codeController = TextEditingController();
  String? _selectedSeason;

  // Rick and Morty has 7 seasons
  static const _seasons = ['S01', 'S02', 'S03', 'S04', 'S05', 'S06', 'S07'];

  @override
  void initState() {
    super.initState();
    final code = widget.current.episodeCode ?? '';

    // Pre-select season chip if current filter is a season prefix (e.g. "S01")
    if (_seasons.contains(code.toUpperCase())) {
      _selectedSeason = code.toUpperCase();
    } else {
      _codeController.text = code;
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  EpisodeFilter get _current {
    // Season chip takes priority over text field
    if (_selectedSeason != null) {
      return EpisodeFilter(episodeCode: _selectedSeason);
    }
    final text = _codeController.text.trim();
    return EpisodeFilter(episodeCode: text.isEmpty ? null : text);
  }

  void _reset() => Navigator.of(context).pop(EpisodeFilter.empty);
  void _apply() => Navigator.of(context).pop(_current);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          Text(context.l10n.filterBySeasonEpisode,
              style: theme.textTheme.titleLarge),
          const SizedBox(height: 20),

          // Season quick-select chips
          Text(context.l10n.season, style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: _seasons.map((season) {
              final isSelected = _selectedSeason == season;
              return FilterChip(
                label: Text(season),
                selected: isSelected,
                onSelected: (_) {
                  setState(() {
                    _selectedSeason = isSelected ? null : season;
                    if (!isSelected) _codeController.clear();
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Specific episode code
          TextField(
            controller: _codeController,
            decoration: InputDecoration(
              labelText: context.l10n.specificEpisode,
              hintText: context.l10n.specificEpisodeHint,
              border: const OutlineInputBorder(),
              isDense: true,
              prefixIcon: const Icon(Icons.tv_rounded),
            ),
            textCapitalization: TextCapitalization.characters,
            textInputAction: TextInputAction.done,
            onChanged: (_) => setState(() => _selectedSeason = null),
            onSubmitted: (_) => _apply(),
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _reset,
                  child: Text(context.l10n.reset),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton(
                  onPressed: _apply,
                  child: Text(context.l10n.apply),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
