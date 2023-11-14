import 'package:flutter/material.dart';

class SettingsItem extends StatelessWidget {
  final Widget child;

  const SettingsItem({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // 1/10 height and 3/5 width
      height: MediaQuery.of(context).size.height / 10,
      width: MediaQuery.of(context).size.width * 3 / 5,
      child: Card(
        child: Center(
          child: child,
        ),
      ),
    );
  }
}

class VertSpace extends StatelessWidget {
  const VertSpace({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // 2% of screen height
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.02,
    );
  }
}
