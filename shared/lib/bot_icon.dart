import 'package:flutter/material.dart';
import 'package:shared/theme/app_theme.dart';

class BotIcon extends StatelessWidget {
  final IconData iconData;
  final bool isActive;

  const BotIcon({
    super.key,
    required this.iconData,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      iconData,
      color: isActive ? Surface.fg(context) : SurfaceVariant.fg(context),
      size: 35,
    );
  }
}
