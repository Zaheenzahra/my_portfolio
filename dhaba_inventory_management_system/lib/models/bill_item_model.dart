import 'package:hive/hive.dart';

part 'bill_item_model.g.dart'; // Required for Hive type adapter

@HiveType(typeId: 1)
class BillItem {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final int quantity;

  @HiveField(2)
  final double unitPrice;

  BillItem({
    required this.name,
    required this.quantity,
    required this.unitPrice,
  });

  double get totalPrice => quantity * unitPrice;
}


