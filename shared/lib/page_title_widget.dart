import 'package:flutter/material.dart';

class PageTitleWidget extends StatefulWidget {
  final String title;
  const PageTitleWidget({super.key, required this.title});

  @override
  PageTitleState createState() => PageTitleState();
}

class PageTitleState extends State<PageTitleWidget> {
  @override
  Widget build(BuildContext context) {
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;
    final bg = Theme.of(context).colorScheme.background;
    final titleColor = onSurfaceVariant == bg
        ? Theme.of(context).colorScheme.inverseSurface
        : onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          Text(
            widget.title,
            style: TextStyle(
              fontSize: Theme.of(context).textTheme.headlineMedium?.fontSize,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 8.0),
          Container(
            height: 1.5,
            width: 500,
            color: Theme.of(context).colorScheme.surfaceVariant,
          ),
        ],
      ),
    );
  }
}
