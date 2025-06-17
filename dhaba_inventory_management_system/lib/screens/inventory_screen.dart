import 'package:dhaba_inventory_management_system/models/product_model.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';
import '../widgets/product_form.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final inventory = Provider.of<InventoryProvider>(context);
    final isWideScreen = MediaQuery
        .of(context)
        .size
        .width >= 600;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Center(
          child: Text(
            'Inventory List',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text("Add Product"),
                onPressed: () =>
                    showDialog(
                      context: context,
                      builder: (_) => const ProductForm(),
                    ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: Hive.box<Product>('productsBox').listenable(),
                builder: (context, Box<Product> box, _) {
                  final products = box.values.toList();

                  if (products.isEmpty) {
                    return const Center(child: Text('No products found.'));
                  }

                  return isWideScreen
                      ? _buildDataTable(context, products, inventory)
                      : _buildListView(context, products, inventory);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ListView for Mobile
  Widget _buildListView(BuildContext context, List<Product> products,
      InventoryProvider inventory) {
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (_, index) {
        final product = products[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 5),
          child: ListTile(
            leading: Text('${index + 1}',
                style: const TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 15)),
            title: Text(product.name,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(
                "Stock: ${product.stock} | Price: Rs${product.price}"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.orange),
                  onPressed: () =>
                      showDialog(
                        context: context,
                        builder: (_) => ProductForm(product: product),
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => inventory.deleteProduct(product.id),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// DataTable for Web/Desktop
  Widget _buildDataTable(BuildContext context, List<Product> products,
      InventoryProvider inventory) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal, // Horizontal scroll for wider table
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 800),
        // You can increase this if needed
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical, // Vertical scroll for long lists
          child: DataTable(
            headingRowColor: MaterialStateColor.resolveWith((states) =>
            Colors.teal.shade100),
            columns: const [
              DataColumn(label: Text('S.No')),
              DataColumn(label: Text('Name')),
              DataColumn(label: Text('Stock')),
              DataColumn(label: Text('Price')),
              DataColumn(label: Text('Actions')),
            ],
            rows: products
                .asMap()
                .entries
                .map((entry) {
              final index = entry.key;
              final product = entry.value;
              return DataRow(cells: [
                DataCell(Text('${index + 1}')),
                DataCell(Text(product.name, style: TextStyle(fontWeight: FontWeight.w700),)),
                DataCell(Text('${product.stock}')),
                DataCell(Text('Rs ${product.price}')),
                DataCell(Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.orange),
                      onPressed: () =>
                          showDialog(
                            context: context,
                            builder: (_) => ProductForm(product: product),
                          ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => inventory.deleteProduct(product.id),
                    ),
                  ],
                )),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }
}
