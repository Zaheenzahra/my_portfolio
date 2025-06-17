import 'package:flutter/material.dart';
import '../models/sale_model.dart';


class SalesProvider with ChangeNotifier {
  final List<Sale> _sales = [];

  List<Sale> get sales => _sales;

  void addSale(Sale sale) {
    _sales.add(sale);
    notifyListeners();
  }

  void clearSales() {
    _sales.clear();
    notifyListeners();
  }
}
