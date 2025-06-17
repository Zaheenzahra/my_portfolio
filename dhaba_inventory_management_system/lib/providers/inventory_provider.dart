import 'package:dhaba_inventory_management_system/models/product_model.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:hive/hive.dart';

import '../models/activity_model.dart';

class InventoryProvider with ChangeNotifier {
  final Box<Product> _box = Hive.box<Product>('productsBox');
  Box<Product> get productBox => _box;

  final List<Activity> _recentActivities = [];
  List<Activity> get recentActivities => _recentActivities.reversed.toList();

  List<Product> get products => _box.values.toList();

  void _addActivity(String type, String title, String subtitle) {
    _recentActivities.add(Activity(
      type: type,
      title: title,
      subtitle: subtitle,
      timestamp: DateTime.now(),
    ));
    notifyListeners();
  }

  // Add Product
  Future<void> addProduct(Product product) async {
   // await _box.add(product);
    await _box.put(product.id.toString(), product);
    _addActivity('add', 'Product Added', '${product.name} (${product.stock} pcs)');

    print('Adding product: ${product.name}');
    print('Box size after insert: ${_box.length}');

    notifyListeners();
  }

  Future<void> updateProduct(Product product) async {
    final key = product.id.toString();
    if (_box.containsKey(key)) {
      await _box.put(key, product); // Replace object directly
      _addActivity('update', 'Product Updated', '${product.name} (${product.stock} pcs)');
    }
    notifyListeners();
  }


  // Delete Product
  Future<void> deleteProduct(int id) async {
    final product = _box.get(id.toString());
    if (product != null) {
      await _box.delete(id.toString());
      _addActivity('remove', 'Product Removed', product.name);
      notifyListeners();
    }
  }

  // Reduce Stock
  void reduceStock(String productName, int quantity) {
    final product = _box.values.firstWhereOrNull((p) => p.name == productName);
    if (product != null && product.stock >= quantity) {
      product.stock -= quantity;
      product.save();
      _addActivity('remove', 'Stock Reduced', '$productName (-$quantity)');
      if (product.stock <= 5) {
        _addActivity('low_stock', 'Low Stock Alert', '$productName (${product.stock} left)');
      }
      notifyListeners();
    }
  }

  // Increase Stock
  void increaseStock(String productName, int quantity) {
    final product = _box.values.firstWhereOrNull((p) => p.name == productName);
    if (product != null) {
      product.stock += quantity;
      product.save();
      _addActivity('add', 'Stock Increased', '$productName (+$quantity)');
      notifyListeners();
    }
  }

  //  Get product by name
  Product? getProductByName(String name) {
    try {
      return _box.values.firstWhereOrNull((p) => p.name == name);
    } catch (e) {
      return null;
    }
  }
}
