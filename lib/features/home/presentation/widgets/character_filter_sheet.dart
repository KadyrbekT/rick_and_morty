import 'package:flutter/material.dart';
import '../../../../core/l10n/l10n_extension.dart';
import '../bloc/character_event.dart';

/// Bottom sheet for filtering characters by status, species, type, gender.
class CharacterFilterSheet extends StatefulWidget {
  final CharacterFilter current;

  const CharacterFilterSheet({super.key, required this.current});

  @override
  State<CharacterFilterSheet> createState() => _CharacterFilterSheetState();
}

class _CharacterFilterSheetState extends State<CharacterFilterSheet> {
  final _speciesController = TextEditingController();
  final _typeController = TextEditingController();

  String? _status;
  String? _gender;

  static const _statuses = ['alive', 'dead', 'unknown'];
  static const _genders = ['female', 'male', 'genderless', 'unknown'];

  @override
  void initState() {
    super.initState();
    _status = widget.current.status;
    _gender = widget.current.gender;
    _speciesController.text = widget.current.species ?? '';
    _typeController.text = widget.current.type ?? '';
  }

  @override
  void dispose() {
    _speciesController.dispose();
    _typeController.dispose();
    super.dispose();
  }

  CharacterFilter get _current => CharacterFilter(
        status: _status,
        species: _speciesController.text.trim().isEmpty
            ? null
            : _speciesController.text.trim(),
        type: _typeController.text.trim().isEmpty
            ? null
            : _typeController.text.trim(),
        gender: _gender,
      );

  void _reset() => Navigator.of(context).pop(CharacterFilter.empty);
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

          Text(context.l10n.filters, style: theme.textTheme.titleLarge),
          const SizedBox(height: 20),

          // Status
          Text(context.l10n.statusLabel, style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          _ChipGroup(
            options: _statuses,
            labels: [
              context.l10n.statusAlive,
              context.l10n.statusDead,
              context.l10n.statusUnknown,
            ],
            selected: _status,
            onSelected: (v) => setState(() => _status = v),
          ),
          const SizedBox(height: 16),

          // Gender
          Text(context.l10n.genderLabel, style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          _ChipGroup(
            options: _genders,
            labels: [
              context.l10n.genderFemale,
              context.l10n.genderMale,
              context.l10n.genderGenderless,
              context.l10n.statusUnknown,
            ],
            selected: _gender,
            onSelected: (v) => setState(() => _gender = v),
          ),
          const SizedBox(height: 16),

          // Species
          TextField(
            controller: _speciesController,
            decoration: InputDecoration(
              labelText: context.l10n.speciesLabel,
              hintText: context.l10n.speciesHint,
              border: const OutlineInputBorder(),
              isDense: true,
            ),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),

          // Type
          TextField(
            controller: _typeController,
            decoration: InputDecoration(
              labelText: context.l10n.typeCharacterLabel,
              hintText: context.l10n.typeCharacterHint,
              border: const OutlineInputBorder(),
              isDense: true,
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _apply(),
          ),
          const SizedBox(height: 24),

          // Actions
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

class _ChipGroup extends StatelessWidget {
  final List<String> options;
  final List<String> labels;
  final String? selected;
  final ValueChanged<String?> onSelected;

  const _ChipGroup({
    required this.options,
    required this.labels,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: List.generate(options.length, (i) {
        final isSelected = selected == options[i];
        return FilterChip(
          label: Text(labels[i]),
          selected: isSelected,
          onSelected: (_) => onSelected(isSelected ? null : options[i]),
        );
      }),
    );
  }
}
