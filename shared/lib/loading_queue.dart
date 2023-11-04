import 'package:flutter/material.dart';

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
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: 20),
        Text(
          'Loading Queues...',
          style: TextStyle(
            color: Theme.of(context).colorScheme.surfaceVariant,
          ),
        ),
      ],
    );
  }
}
