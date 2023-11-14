import 'package:flutter/material.dart';

class SaveFAB extends StatelessWidget {
  final void Function() onPressed;
  const SaveFAB({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      label: const Text('Save'),
      icon: const Icon(Icons.save),
      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
      foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
    );
  }
}
