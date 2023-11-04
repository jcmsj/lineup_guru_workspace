import 'package:flutter/material.dart';

class ServiceCard extends StatelessWidget {
  final String serviceName;
  final String iconName;
  const ServiceCard(this.serviceName, this.iconName, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(
        vertical: 5,
        horizontal: 25,
      ),
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(40.0),
      ),
      child: SizedBox(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Dont use an Icon/IconData since we cant generate a list of available icons in the app. Also The admin needs to visit the google material icons page for the available icons and names
            Text(
              iconName,
              style: TextStyle(
                fontFamily: "MaterialIcons",
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 48,
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              serviceName,
              style: TextStyle(
                fontSize: 17.0,
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
