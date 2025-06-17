import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/bill_item_model.dart';
import '../models/sale_model.dart';
import '../providers/sales_provider.dart';

class SalesReportScreen extends StatefulWidget {
  const SalesReportScreen({super.key});

  @override
  State<SalesReportScreen> createState() => _SalesReportScreenState();
}

class _SalesReportScreenState extends State<SalesReportScreen> {
  DateTime? _startDate;
  DateTime? _endDate;

  List<Sale> _filterSales(List<Sale> sales) {
    return sales.where((sale) {
      if (_startDate != null && sale.timestamp.isBefore(_startDate!)) return false;
      if (_endDate != null && sale.timestamp.isAfter(_endDate!)) return false;
      return true;
    }).toList();
  }

  Future<void> _exportToPDF(List<Sale> sales) async {
    final pdf = pw.Document();

    for (var sale in sales) {
      pdf.addPage(
        pw.Page(
          build: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Sale Date: ${DateFormat.yMMMd().add_jm().format(sale.timestamp)}'),
              pw.SizedBox(height: 5),
              pw.TableHelper.fromTextArray(
                headers: ['Item', 'Qty', 'Unit Price', 'Total'],
                data: sale.items.map((item) => [
                  item.name,
                  item.quantity.toString(),
                  item.unitPrice.toString(),
                  item.totalPrice.toString(),
                ]).toList(),
              ),
              pw.Text('Total: Rs. ${sale.total.toStringAsFixed(2)}'),
              pw.Divider(),
            ],
          ),
        ),
      );
    }

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  int weekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final days = date.difference(firstDayOfYear).inDays;
    return ((days + firstDayOfYear.weekday) / 7).ceil();
  }

  @override
  Widget build(BuildContext context) {
    final allSales = Provider.of<SalesProvider>(context).sales;
    final filteredSales = _filterSales(allSales);
    final isWideScreen = MediaQuery.of(context).size.width > 600;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.teal,
          title: const Center(
            child: Text(
              'Sales',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
          ),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.yellow,
            tabs: [
              Tab(text: 'Report'),
              Tab(text: 'Charts'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildReportTab(filteredSales, isWideScreen),
            _buildChartTab(filteredSales, isWideScreen),
          ],
        ),
      ),
    );
  }

  Widget _buildReportTab(List<Sale> filteredSales, bool isWideScreen) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          // Date Filters Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().subtract(const Duration(days: 7)),
                      firstDate: DateTime(2023),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() => _startDate = picked);
                    }
                  },
                  child: Text(
                    _startDate == null
                        ? 'Start Date'
                        : 'From: ${DateFormat.yMMMd().format(_startDate!)}',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2023),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() => _endDate = picked.add(const Duration(hours: 23, minutes: 59)));
                    }
                  },
                  child: Text(
                    _endDate == null
                        ? 'End Date'
                        : 'To: ${DateFormat.yMMMd().format(_endDate!)}',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (isWideScreen)
                ElevatedButton.icon(
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Export PDF'),
                  onPressed: filteredSales.isEmpty ? null : () => _exportToPDF(filteredSales),
                ),
            ],
          ),
          if (!isWideScreen)
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Export PDF'),
                onPressed: filteredSales.isEmpty ? null : () => _exportToPDF(filteredSales),
              ),
            ),
          const Divider(),
          // Report List
          Expanded(
            child: filteredSales.isEmpty
                ? const Center(child: Text('No sales found.'))
                : ListView.builder(
              itemCount: filteredSales.length,
              itemBuilder: (context, index) {
                final sale = filteredSales[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  child: ExpansionTile(
                    title: Text('Date: ${DateFormat.yMMMd().add_jm().format(sale.timestamp)}'),
                    subtitle: Text('Total: Rs. ${sale.total.toStringAsFixed(2)}'),
                    children: sale.items.map((item) {
                      return ListTile(
                        title: Text('${item.name} x${item.quantity}'),
                        subtitle: Text('Rs. ${item.unitPrice} • Total: Rs. ${item.totalPrice}'),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartTab(List<Sale> sales, bool isWideScreen) {
    Map<String, double> dailyTotals = {};
    Map<String, double> weeklyTotals = {};

    for (var sale in sales) {
      String dayKey = DateFormat('yyyy-MM-dd').format(sale.timestamp);
      dailyTotals[dayKey] = (dailyTotals[dayKey] ?? 0) + sale.total;

      var weekKey = '${sale.timestamp.year}-W${weekNumber(sale.timestamp)}';
      weeklyTotals[weekKey] = (weeklyTotals[weekKey] ?? 0) + sale.total;
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: isWideScreen
            ? Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  const Text('Daily Sales',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 250, child: _buildBarChart(dailyTotals)),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                children: [
                  const Text('Weekly Sales',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 250, child: _buildBarChart(weeklyTotals)),
                ],
              ),
            ),
          ],
        )
            : Column(
          children: [
            const Text('Daily Sales',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 250, child: _buildBarChart(dailyTotals)),
            const SizedBox(height: 16),
            const Text('Weekly Sales',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 250, child: _buildBarChart(weeklyTotals)),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart(Map<String, double> data) {
    final sortedKeys = data.keys.toList()..sort();
    final spots = List.generate(sortedKeys.length, (i) {
      final key = sortedKeys[i];
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(toY: data[key]!, color: Colors.teal, width: 14),
        ],
      );
    });

    return BarChart(
      BarChartData(
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, interval: 100),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < sortedKeys.length) {
                  final key = sortedKeys[index];
                  return Text(
                    key.length > 5 ? key.substring(key.length - 5) : key,
                    style: const TextStyle(fontSize: 10),
                  );
                }
                return const Text('');
              },
              reservedSize: 30,
            ),
          ),
        ),
        barGroups: spots,
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: false),
      ),
    );
  }
}
