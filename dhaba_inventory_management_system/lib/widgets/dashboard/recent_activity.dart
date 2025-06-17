import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/inventory_provider.dart';

class RecentActivity extends StatelessWidget {
  const RecentActivity({super.key});

  Icon _getIcon(String type) {
    switch (type) {
      case 'add':
        return const Icon(Icons.add_circle, color: Colors.green);
      case 'remove':
        return const Icon(Icons.remove_circle, color: Colors.red);
      case 'low_stock':
        return const Icon(Icons.warning, color: Colors.orange);
      default:
        return const Icon(Icons.info, color: Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    final recentActivities = context.watch<InventoryProvider>().recentActivities;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Recent Activity", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            if (recentActivities.isEmpty)
              const Text("No recent activity."),
            ...recentActivities.take(5).map((activity) => ListTile(
              leading: _getIcon(activity.type),
              title: Text(activity.title),
              subtitle: Text(activity.subtitle),
              trailing: Text(
                "${activity.timestamp.hour}:${activity.timestamp.minute.toString().padLeft(2, '0')}",
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
