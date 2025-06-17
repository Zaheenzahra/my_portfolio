import 'package:flutter/foundation.dart';

import '../models/bill_item_model.dart';

class BillingProvider with ChangeNotifier {
  final List<BillItem> _items = [];

  List<BillItem> get items => _items;

  void addItem(BillItem item) {
    _items.add(item);
    notifyListeners();
  }

  void removeItem(int index) {
    _items.removeAt(index);
    notifyListeners();
  }

  double get total => _items.fold(0, (sum, item) => sum + item.totalPrice);

  void clear(){
    _items.clear();
    notifyListeners();
  }
}
