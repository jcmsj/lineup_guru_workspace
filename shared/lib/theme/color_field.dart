import 'package:flutter/material.dart';
import 'package:shared/theme/app_theme.dart';

typedef ColorChange = void Function(Color color);

class ColorField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final ColorChange onChange;
  const ColorField({
    super.key,
    required this.controller,
    required this.label,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: controller,
        style: TextStyle(
          color: Theme.of(context).colorScheme.inverseSurface,
        ),
        decoration: InputDecoration(
          icon: Icon(Icons.square, color: hexStringToColor(controller.text)),
          labelText: label,
          labelStyle: TextStyle(
            color: Theme.of(context).colorScheme.inverseSurface,
          ),
          border: const OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.surfaceVariant,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Surface.bg(context),
            ),
          ),
        ),
        onChanged: (value) {
          onChange(hexStringToColor(controller.text));
        },
      ),
    );
  }
}
