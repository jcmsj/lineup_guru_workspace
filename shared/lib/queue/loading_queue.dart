import 'package:flutter/material.dart';
import 'package:shared/theme/app_theme.dart';

class LoadingQueueWidget extends StatelessWidget {
  const LoadingQueueWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircularProgressIndicator(
          strokeWidth: 8.0,
          color: SurfaceVariant.fg(context),
        ),
        const SizedBox(height: 20),
        Text(
          'Loading Queues...',
          style: TextStyle(
            color: SurfaceVariant.fg(context),
          ),
        ),
      ],
    );
  }
}
