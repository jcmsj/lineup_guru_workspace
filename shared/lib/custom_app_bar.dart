import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double height;
  final String title;

  const CustomAppBar({super.key, required this.height, required this.title});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(Icons.qr_code),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 25),
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
