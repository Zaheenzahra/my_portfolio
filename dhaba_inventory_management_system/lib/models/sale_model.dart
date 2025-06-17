import 'package:hive/hive.dart';
import 'bill_item_model.dart';

part 'sale_model.g.dart';

@HiveType(typeId: 2)
class Sale {
  @HiveField(0)
  final DateTime timestamp;

  @HiveField(1)
  final List<BillItem> items;

  @HiveField(2)
  final double total;

  Sale({
    required this.timestamp,
    required this.items,
    required this.total,
  });
}
