import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/inventory_provider.dart';

class StockPieChart extends StatelessWidget {
  const StockPieChart({super.key});

  @override
  Widget build(BuildContext context) {
    final inventoryProvider = Provider.of<InventoryProvider>(context);
    final products = inventoryProvider.products;

    final totalStock = products.fold<double>(0, (sum, item) => sum + item.stock.toDouble());

    return PieChart(
      PieChartData(
        sections: products.map((product) {
          final percentage = totalStock == 0 ? 0 : (product.stock / totalStock) * 100;
          return PieChartSectionData(
            value: product.stock.toDouble(),
            title: '${product.name}\n${percentage.toStringAsFixed(1)}%',
            color: product.stock < 5 ? Colors.red : _getRandomColor(product.name),
            radius: 60,
            titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
          );
        }).toList(),
        sectionsSpace: 2,
        centerSpaceRadius: 40,
      ),
    );
  }

  /// Simple color generator based on product name hash
  Color _getRandomColor(String name) {
    final hash = name.hashCode;
    final r = (hash & 0xFF0000) >> 16;
    final g = (hash & 0x00FF00) >> 8;
    final b = (hash & 0x0000FF);
    return Color.fromARGB(255, r, g, b);
  }
}
