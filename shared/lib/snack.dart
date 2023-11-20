import 'package:flutter/material.dart';

import 'theme/app_theme.dart';

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> snack(
    BuildContext context, String message) {
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: SurfaceVariant.bg(context),
      showCloseIcon: true,
      content: Text(
        message,
        style: TextStyle(
          color: SurfaceVariant.fg(context),
        ),
      ),
    ),
  );
}

// Error variationof snack bar
ScaffoldFeatureController<SnackBar, SnackBarClosedReason> snackErr(
    BuildContext context, String message) {
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      showCloseIcon: true,
      closeIconColor: Theme.of(context).colorScheme.onErrorContainer,
      backgroundColor: Theme.of(context).colorScheme.errorContainer,
      content: Text(
        message,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onErrorContainer,
        ),
      ),
    ),
  );
}
