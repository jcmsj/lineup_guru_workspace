import 'package:flutter/material.dart';

class ThemedBar extends AppBar {
  final BuildContext context;
  ThemedBar({
    super.key,
    required this.context,
    super.title,
    super.actions,
    super.bottom,
    super.elevation,
    super.shape,
    super.backgroundColor,
    super.iconTheme,
    super.actionsIconTheme,
    super.centerTitle,
    super.titleSpacing,
  });

  @override
  Color get backgroundColor =>
      super.backgroundColor ?? Theme.of(context).colorScheme.surfaceVariant;

  @override
  Color get foregroundColor =>
      super.foregroundColor ?? Theme.of(context).colorScheme.onSurfaceVariant;
}
