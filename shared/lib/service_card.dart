import 'package:flutter/material.dart';
import 'package:shared/theme/app_theme.dart';

class ServiceCard extends StatelessWidget {
  final String serviceName;
  final String iconName;
  const ServiceCard(this.serviceName, this.iconName, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Surface.bg(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(40.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Dont use an Icon/IconData since we cant generate a list of available icons in the app. Also The admin needs to visit the google material icons page for the available icons and names
          Text(
            iconName,
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: Surface.fg(context),
                  fontFamily: "MaterialIcons",
                ),
          ),
          Text(
            serviceName,
            style: TextStyle(
              color: Surface.fg(context),
              fontSize: Theme.of(context).textTheme.headlineMedium?.fontSize,
            ),
          ),
        ],
      ),
    );
  }
}
