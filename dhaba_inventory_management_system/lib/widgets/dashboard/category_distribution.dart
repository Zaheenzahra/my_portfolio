import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class CategoryDistribution extends StatelessWidget {
  const CategoryDistribution({super.key});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text("Category Distribution", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            SizedBox(height: height*0.1),
            SizedBox(
              height: height*0.2,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(color: Colors.blue, value: 35, title: 'Meals'),
                    PieChartSectionData(color: Colors.orange, value: 25, title: 'Drinks'),
                    PieChartSectionData(color: Colors.pink, value: 18, title: 'Others'),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
