import 'package:flutter/material.dart';

class LoadingQueueWidget extends StatelessWidget {
  const LoadingQueueWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircularProgressIndicator(
          strokeWidth: 8.0,
          color: Color.fromARGB(255, 255, 189, 89),
        ),
        SizedBox(height: 20),
        Text('Loading Queues...'),
      ],
    );
  }
}
