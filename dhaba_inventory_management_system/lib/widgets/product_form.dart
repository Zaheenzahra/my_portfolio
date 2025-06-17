import 'package:dhaba_inventory_management_system/models/product_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';

class ProductForm extends StatefulWidget {
  final Product? product;

  const ProductForm({super.key, this.product});

  @override
  State<ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _category;
  late int _stock;
  late double _price;

  @override
  void initState() {
    super.initState();
    _name = widget.product?.name ?? '';
    _category = widget.product?.category ?? '';
    _stock = widget.product?.stock ?? 0;
    _price = widget.product?.price ?? 0.0;

  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final provider = Provider.of<InventoryProvider>(context, listen: false);
      final product = Product(
        id: widget.product?.id ?? DateTime.now().millisecondsSinceEpoch,
        name: _name,
        category: _category,
        stock: _stock,
        price: _price,
      );

      if (widget.product == null) {
        provider.addProduct(product);
      } else {
        provider.updateProduct(product);
      }

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.product == null ? 'Add Product' : 'Edit Product'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _name,
                decoration: InputDecoration(labelText: 'Product Name'),
                validator: (value) =>
                value == null || value.trim().isEmpty ? 'Product name is required' : null,
                onSaved: (value) => _name = value!.trim(),
              ),
              DropdownButtonFormField<String>(
                value: _category.isNotEmpty ? _category : null,
                decoration: InputDecoration(labelText: 'Category'),
                items: ['Meals', 'Drinks', 'BBQ'].map((c) {
                  return DropdownMenuItem(value: c, child: Text(c));
                }).toList(),
                onChanged: (value) => setState(() => _category = value!),
                validator: (value) =>
                value == null || value.isEmpty ? 'Category is required' : null,
              ),
              TextFormField(
                initialValue: _stock.toString(),
                decoration: InputDecoration(labelText: 'Stock'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Stock is required';
                  final stock = int.tryParse(value);
                  if (stock == null || stock <= 0) return 'Enter a valid integer';
                 // if (stock <= 0) return 'Stock must be greater than 0';
                  return null;
                },
                onSaved: (value) => _stock = int.parse(value!),
              ),
              TextFormField(
                initialValue: _price.toString(),
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Price is required';
                  final price = double.tryParse(value);
                  if (price == null || price <= 0.0) return 'Enter a valid number';
                 // if (price <= 0.0) return 'Price must be greater than 0';
                  return null;
                },
                onSaved: (value) => _price = double.parse(value!),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveForm,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
