import 'package:flutter/material.dart';
import 'package:shared/theme/app_theme.dart';

class PageTitleWidget extends StatefulWidget {
  final String title;
  const PageTitleWidget({super.key, required this.title});

  @override
  PageTitleState createState() => PageTitleState();
}

class PageTitleState extends State<PageTitleWidget> {
  @override
  Widget build(BuildContext context) {
    final onSurfaceVariant = SurfaceVariant.fg(context);
    final bg = Theme.of(context).colorScheme.background;
    final titleColor = onSurfaceVariant == bg
        ? Theme.of(context).colorScheme.inverseSurface
        : onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            widget.title,
            style: TextStyle(
              fontSize: Theme.of(context).textTheme.headlineMedium?.fontSize,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 6.0),
          Container(
            height: 1.5,
            width: MediaQuery.of(context).size.width * 0.75,
            color: SurfaceVariant.bg(context),
          ),
        ],
      ),
    );
  }
}
