import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

import 'export_service.dart'; // ✅ ADD THIS

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.deepPurple,

        // ⬇️ EXPORT BUTTON
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () async {
              await ExportService.exportAllData();
            },
          ),
        ],
      ),

      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchDashboardData(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                summaryGrid(data),

                const SizedBox(height: 30),
                const Text(
                  'Weekly Collection',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 220,
                  child: BarChart(
                    buildBarChart(data['weekly']),
                  ),
                ),

                const SizedBox(height: 30),
                const Text(
                  'Monthly Collection',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 220,
                  child: BarChart(
                    buildBarChart(data['monthly']),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ================= FIRESTORE =================

  Future<Map<String, dynamic>> fetchDashboardData() async {
    int totalCustomers = 0;
    int totalLoans = 0;
    int totalPrincipal = 0;
    int totalInterest = 0;
    int totalPaid = 0;

    Map<String, int> weekly = {};
    Map<String, int> monthly = {};

    final customers =
    await FirebaseFirestore.instance.collection('customers').get();

    totalCustomers = customers.docs.length;

    for (final customer in customers.docs) {
      final loans =
      await customer.reference.collection('loans').get();

      for (final loan in loans.docs) {
        totalLoans++;
        totalPrincipal += loan['principal'] as int;
        totalInterest += loan['interest'] as int;

        final payments =
        await loan.reference.collection('payments').get();

        for (final payment in payments.docs) {
          final amount = payment['amount'] as int;
          final date =
          (payment['paidAt'] as Timestamp).toDate();

          totalPaid += amount;

          final weekKey = '${date.day}/${date.month}';
          weekly[weekKey] = (weekly[weekKey] ?? 0) + amount;

          final monthKey = '${date.month}/${date.year}';
          monthly[monthKey] =
              (monthly[monthKey] ?? 0) + amount;
        }
      }
    }

    return {
      'totalCustomers': totalCustomers,
      'totalLoans': totalLoans,
      'totalPrincipal': totalPrincipal,
      'totalInterest': totalInterest,
      'totalPaid': totalPaid,
      'weekly': weekly,
      'monthly': monthly,
    };
  }

  // ================= UI =================

  Widget summaryGrid(Map<String, dynamic> data) {
    final pending =
        data['totalPrincipal'] +
            data['totalInterest'] -
            data['totalPaid'];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        summaryCard('Customers', data['totalCustomers']),
        summaryCard('Loans', data['totalLoans']),
        summaryCard('Principal', data['totalPrincipal']),
        summaryCard('Interest', data['totalInterest']),
        summaryCard('Paid', data['totalPaid']),
        summaryCard('Pending', pending),
      ],
    );
  }

  Widget summaryCard(String title, int value) {
    return Card(
      elevation: 3,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '₹$value',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.deepPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= BAR CHART =================

  BarChartData buildBarChart(Map<String, int> data) {
    final keys = data.keys.toList();
    final values = data.values.toList();

    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      barTouchData: BarTouchData(enabled: true),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: const AxisTitles(
          sideTitles:
          SideTitles(showTitles: true, reservedSize: 40),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: (value, meta) {
              if (value.toInt() >= keys.length) {
                return const SizedBox();
              }
              return Text(
                keys[value.toInt()],
                style: const TextStyle(fontSize: 10),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      gridData: const FlGridData(show: false),
      barGroups: List.generate(values.length, (i) {
        return BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: values[i].toDouble(),
              width: 16,
              color: Colors.deepPurple,
            ),
          ],
        );
      }),
    );
  }
}
