import 'package:flutter/material.dart';
import 'dart:math';

class InterestCalculatorPage extends StatefulWidget {
  const InterestCalculatorPage({super.key});

  @override
  State<InterestCalculatorPage> createState() =>
      _InterestCalculatorPageState();
}

class _InterestCalculatorPageState
    extends State<InterestCalculatorPage> {
  final principalCtrl = TextEditingController();
  final rateCtrl = TextEditingController();
  final timeCtrl = TextEditingController();

  String calculationType = 'Simple Interest';

  double interest = 0;
  double total = 0;
  double emi = 0;

  void calculate() {
    final p = double.tryParse(principalCtrl.text) ?? 0;
    final r = double.tryParse(rateCtrl.text) ?? 0;
    final t = double.tryParse(timeCtrl.text) ?? 0;

    setState(() {
      interest = 0;
      total = 0;
      emi = 0;

      if (calculationType == 'Simple Interest') {
        interest = p * r * t / 100;
        total = p + interest;
      }

      if (calculationType == 'Monthly Interest') {
        interest = p * r * t / 100;
        total = p + interest;
      }

      if (calculationType == 'EMI (Basic)') {
        final monthlyRate = r / 12 / 100;
        final months = t;

        emi = (p *
            monthlyRate *
            pow(1 + monthlyRate, months)) /
            (pow(1 + monthlyRate, months) - 1);

        total = emi * months;
        interest = total - p;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Interest Calculator'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔽 TYPE SELECTOR
            DropdownButtonFormField<String>(
              value: calculationType,
              decoration: const InputDecoration(
                labelText: 'Calculation Type',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                    value: 'Simple Interest',
                    child: Text('Simple Interest')),
                DropdownMenuItem(
                    value: 'Monthly Interest',
                    child: Text('Monthly Interest')),
                DropdownMenuItem(
                    value: 'EMI (Basic)',
                    child: Text('EMI (Basic)')),
              ],
              onChanged: (value) {
                setState(() {
                  calculationType = value!;
                });
              },
            ),

            const SizedBox(height: 16),

            _input(principalCtrl, 'Principal Amount (₹)'),
            _input(rateCtrl, 'Interest Rate (%)'),

            _input(
              timeCtrl,
              calculationType == 'Simple Interest'
                  ? 'Time (Years)'
                  : calculationType == 'Monthly Interest'
                  ? 'Time (Months)'
                  : 'Loan Tenure (Months)',
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: calculate,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding:
                const EdgeInsets.symmetric(horizontal: 40),
              ),
              child: const Text('Calculate'),
            ),

            const SizedBox(height: 30),

            if (total > 0)
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _result('Interest', interest),
                      const SizedBox(height: 8),
                      _result('Total Amount', total, bold: true),
                      if (emi > 0) ...[
                        const SizedBox(height: 8),
                        _result('Monthly EMI', emi),
                      ]
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _input(
      TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _result(String title, double value,
      {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: TextStyle(
                fontWeight:
                bold ? FontWeight.bold : FontWeight.w500)),
        Text(
          '₹${value.toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight:
            bold ? FontWeight.bold : FontWeight.w500,
            color: bold ? Colors.deepPurple : Colors.black,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
