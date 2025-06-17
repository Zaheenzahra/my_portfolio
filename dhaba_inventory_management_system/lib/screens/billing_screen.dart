import 'package:dhaba_inventory_management_system/models/product_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:dhaba_inventory_management_system/models/bill_item_model.dart';
import 'package:dhaba_inventory_management_system/providers/billing_provider.dart';
import 'package:dhaba_inventory_management_system/providers/inventory_provider.dart';

import 'package:pdf/widgets.dart' as pw;
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;

import '../models/sale_model.dart';
import '../providers/sales_provider.dart';

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  Product? _selectedItem;
  final TextEditingController _qtyController = TextEditingController();

  void _addToBill(BuildContext context) {
    final qty = int.tryParse(_qtyController.text) ?? 1;

    if (_selectedItem != null && qty > 0) {
      if (_selectedItem!.stock >= qty) {
        final item = _selectedItem!;

        Provider.of<BillingProvider>(context, listen: false).addItem(
          BillItem(name: item.name, quantity: qty, unitPrice: item.price),
        );

        Provider.of<InventoryProvider>(context, listen: false)
            .reduceStock(item.name, qty);

        _qtyController.clear();
        setState(() => _selectedItem = null);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Not enough stock")),
        );
      }
    }
  }

  Future<Uint8List> _printBill(
      BuildContext context, List<BillItem> items, double total) async {
    final pdf = pw.Document();
    final logoBytes = await rootBundle.load('images/logo.png');
    final logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Image(logoImage, width: 50, height: 50),
                pw.SizedBox(width: 10),
                pw.Text('Dhaba Bill',
                    style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.TableHelper.fromTextArray(
              headers: ['Item', 'Qty', 'Rate', 'Total'],
              data: items.map((item) {
                return [
                  item.name,
                  item.quantity.toString(),
                  item.unitPrice.toStringAsFixed(2),
                  item.totalPrice.toStringAsFixed(2),
                ];
              }).toList(),
            ),
            pw.SizedBox(height: 10),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                'Total: Rs. ${total.toStringAsFixed(2)}',
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );

    return pdf.save();
  }

  void _completeSale(BuildContext context) {
    final billingProvider = Provider.of<BillingProvider>(context, listen: false);
    final salesProvider = Provider.of<SalesProvider>(context, listen: false);

    final sale = Sale(
      timestamp: DateTime.now(),
      items: List<BillItem>.from(billingProvider.items),
      total: billingProvider.total,
    );

    salesProvider.addSale(sale);
    billingProvider.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Sale completed & saved")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final billingProvider = Provider.of<BillingProvider>(context);
    final inventoryProvider = Provider.of<InventoryProvider>(context);
    final billItems = billingProvider.items;
    final total = billingProvider.total;
    final isWideScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Center(
          child: Text(
            'Billing Screen',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                // Input Section
                isWideScreen
                    ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _inputFields(context, inventoryProvider),
                )
                    : Column(
                  children: _inputFields(context, inventoryProvider),
                ),

                const SizedBox(height: 16),

                // Bill Item List
                Expanded(
                  child: billItems.isEmpty
                      ? const Center(child: Text("No items added to bill."))
                      : ListView.builder(
                    itemCount: billItems.length,
                    itemBuilder: (context, index) {
                      final item = billItems[index];
                      return ListTile(
                        title: Text('${item.name} x${item.quantity}'),
                        subtitle: Text(
                          'Unit: Rs. ${item.unitPrice}  •  Total: Rs. ${item.totalPrice.toStringAsFixed(2)}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            billingProvider.removeItem(index);
                          },
                        ),
                      );
                    },
                  ),
                ),

                // Total
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total:',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('Rs. ${total.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Print Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.print),
                    label: const Text('Print / Save Bill'),
                    onPressed: billItems.isEmpty
                        ? null
                        : () async {
                      await _printBill(context, billItems, total);
                      _completeSale(context);
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Widget> _inputFields(BuildContext context, InventoryProvider inventoryProvider) {
    return [
      Expanded(
        flex: 2,
        child: DropdownButton<Product>(
          value: _selectedItem,
          hint: const Text('Select Item'),
          isExpanded: true,
          items: inventoryProvider.products.map((item) {
            return DropdownMenuItem<Product>(
              value: item,
              child: Text('${item.name} (Rs. ${item.price})'),
            );
          }).toList(),
          onChanged: (value) => setState(() => _selectedItem = value),
        ),
      ),
      const SizedBox(width: 10, height: 8),
      Expanded(
        flex: 2,
        child: TextField(
          controller: _qtyController,
          decoration: const InputDecoration(labelText: 'Qty'),
          keyboardType: TextInputType.number,
        ),
      ),
      const SizedBox(width: 8, height: 8),
      ElevatedButton(
        onPressed: () => _addToBill(context),
        child: const Text("Add to Bill"),
      ),
    ];
  }
}
