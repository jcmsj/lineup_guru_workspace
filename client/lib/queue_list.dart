import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared/queue_notifier.dart';
import 'package:shared/shop_queue.dart';
import 'package:shared/service_card.dart';
import 'second_route.dart';

class QueueItem extends StatelessWidget {
  const QueueItem({
    super.key,
    required this.data,
  });
  final ShopQueue data;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print("napindot ${data.name}");
        Provider.of<QueueNotifier>(context, listen: false).queue = data;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SecondRoute()),
        );
      },
      child: ServiceCard(data.name, data.iconName),
    );
  }
}
