import 'package:flutter/material.dart';
import '../../../../core/l10n/l10n_extension.dart';
import '../bloc/location_event.dart';

/// Bottom sheet for filtering locations by type and dimension.
class LocationFilterSheet extends StatefulWidget {
  final LocationFilter current;

  const LocationFilterSheet({super.key, required this.current});

  @override
  State<LocationFilterSheet> createState() => _LocationFilterSheetState();
}

class _LocationFilterSheetState extends State<LocationFilterSheet> {
  final _typeController = TextEditingController();
  final _dimensionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _typeController.text = widget.current.type ?? '';
    _dimensionController.text = widget.current.dimension ?? '';
  }

  @override
  void dispose() {
    _typeController.dispose();
    _dimensionController.dispose();
    super.dispose();
  }

  LocationFilter get _current => LocationFilter(
        type: _typeController.text.trim().isEmpty
            ? null
            : _typeController.text.trim(),
        dimension: _dimensionController.text.trim().isEmpty
            ? null
            : _dimensionController.text.trim(),
      );

  void _reset() => Navigator.of(context).pop(LocationFilter.empty);
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

          TextField(
            controller: _typeController,
            decoration: InputDecoration(
              labelText: context.l10n.typeLocationLabel,
              hintText: context.l10n.typeLocationHint,
              border: const OutlineInputBorder(),
              isDense: true,
              prefixIcon: const Icon(Icons.public_rounded),
            ),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _dimensionController,
            decoration: InputDecoration(
              labelText: context.l10n.dimensionLabel,
              hintText: context.l10n.dimensionHint,
              border: const OutlineInputBorder(),
              isDense: true,
              prefixIcon: const Icon(Icons.blur_circular_rounded),
            ),
            textInputAction: TextInputAction.done,
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
