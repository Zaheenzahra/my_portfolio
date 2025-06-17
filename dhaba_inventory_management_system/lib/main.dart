import 'package:dhaba_inventory_management_system/providers/billing_provider.dart';
import 'package:dhaba_inventory_management_system/providers/inventory_provider.dart';
import 'package:dhaba_inventory_management_system/providers/sales_provider.dart';
import 'package:dhaba_inventory_management_system/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'models/bill_item_model.dart';
import 'models/product_model.dart';
import 'models/sale_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(ProductAdapter());
  await Hive.openBox<Product>('productsBox');
  Hive.registerAdapter(BillItemAdapter());
  Hive.registerAdapter(SaleAdapter());
  await Hive.openBox<Sale>('Sales Box');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => InventoryProvider()),
        ChangeNotifierProvider(create: (_) => BillingProvider()),
        ChangeNotifierProvider(create: (_) => SalesProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: '3_bro Dhaba',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        home: const HomeScreen()
      ),
    );
  }
}

