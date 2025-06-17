import 'package:dhaba_inventory_management_system/providers/inventory_provider.dart';
import 'package:dhaba_inventory_management_system/widgets/dashboard/category_distribution.dart';
import 'package:dhaba_inventory_management_system/widgets/dashboard/recent_activity.dart';
import 'package:dhaba_inventory_management_system/widgets/dashboard/stock_overview.dart';
import 'package:dhaba_inventory_management_system/widgets/dashboard/stock_bar_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final inventoryProvider = Provider.of<InventoryProvider>(context);
    final products = inventoryProvider.products;
    final lowStockItems = products.where((p) => p.stock < 5).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Center(
          child: Text(
            'Dashboard',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWideScreen = constraints.maxWidth >= 600;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                isWideScreen
                    ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Expanded(flex: 2, child: StockOverview()),
                    SizedBox(width: 16),
                    Expanded(flex: 2, child: CategoryDistribution()),
                    SizedBox(width: 16),
                    Expanded(flex: 2, child: RecentActivity()),
                  ],
                )
                    : Column(
                  children: const [
                    StockOverview(),
                    SizedBox(height: 16),
                    CategoryDistribution(),
                    SizedBox(height: 16),
                    RecentActivity(),
                  ],
                ),
                const SizedBox(height: 24),

                // Stock Bar Chart / Pie Chart Section
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Stock Levels",
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 250,
                  width: double.infinity,
                  child: const StockPieChart(),
                ),
                const SizedBox(height: 24),

                // Low Stock Alert Section
                if (lowStockItems.isNotEmpty)
                  Card(
                    color: Colors.red.shade50,
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "⚠️ Low Stock Alert",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...lowStockItems.map((item) => Text(
                              '• ${item.name} – Only ${item.stock} left')),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
