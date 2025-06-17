import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/inventory_provider.dart';

class StockOverview extends StatelessWidget {
  const StockOverview({super.key});

  @override
  Widget build(BuildContext context) {
    final inventoryProvider = Provider.of<InventoryProvider>(context);
    final products = inventoryProvider.products;

    final int total = products.length;
    final int inStock = products.where((p) => p.stock > 5).length;
    final int lowStock = products.where((p) => p.stock > 0 && p.stock <= 5).length;
    final int outOfStock = products.where((p) => p.stock == 0).length;

    int safeDivide(int part, int total) => total == 0 ? 0 : ((part / total) * 100).round();

    final totalPercent = 100; // Always 100%
    final inStockPercent = safeDivide(inStock, total);
    final lowStockPercent = safeDivide(lowStock, total);
    final outOfStockPercent = safeDivide(outOfStock, total);

    double height = MediaQuery.of(context).size.height;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Stock Overview",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: height * 0.1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBar("Total", totalPercent, Colors.blue, context),
                _buildBar("In Stock", inStockPercent, Colors.green, context),
                _buildBar("Low Stock", lowStockPercent, Colors.orange, context),
                _buildBar("Out of Stock", outOfStockPercent, Colors.red, context),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBar(String label, int percent, Color color, BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Column(
      children: [
        Container(
          width: width * 0.04,
          height: percent.toDouble() * 1.5, // bar height is proportional
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        SizedBox(height: height * 0.02),
        Text("$percent%", style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
