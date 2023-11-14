import 'package:flutter/material.dart';
import 'package:shared/theme/app_theme.dart';
import 'package:shared/theme/themed_bar.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double height;
  final String title;

  const CustomAppBar({super.key, required this.height, required this.title});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ThemedBar(
        context: context,
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.qr_code,
              color: SurfaceVariant.fg(context),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              // make a style that us headline medium and uses SurfaceVariant.fg
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: SurfaceVariant.fg(context),
                  ),
            ),
          ],
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
