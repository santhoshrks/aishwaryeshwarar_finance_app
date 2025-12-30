import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';

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

      if (p > 0 && r > 0 && t > 0) {
        if (calculationType == 'Simple Interest') {
          interest = p * r * t / 100;
          total = p + interest;
        } else if (calculationType == 'Monthly Interest') {
          interest = p * r * t / 100;
          total = p + interest;
        } else if (calculationType == 'EMI (Basic)') {
          final monthlyRate = r / 12 / 100;
          final months = t;
          emi = (p * monthlyRate * pow(1 + monthlyRate, months)) / (pow(1 + monthlyRate, months) - 1);
          total = emi * months;
          interest = total - p;
        }
      }
    });
     FocusScope.of(context).unfocus(); // Dismiss keyboard
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Theme.of(context).primaryColor, Colors.black87],
          ),
        ),
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.white),
              title: Text('Interest Calculator', style: GoogleFonts.lato(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildDropdown(),
                    const SizedBox(height: 16),
                    _buildTextField(principalCtrl, 'Principal Amount (₹)'),
                    const SizedBox(height: 16),
                    _buildTextField(rateCtrl, 'Interest Rate (%)'),
                    const SizedBox(height: 16),
                    _buildTextField(
                      timeCtrl,
                      calculationType == 'Simple Interest'
                          ? 'Time (Years)'
                          : calculationType == 'Monthly Interest'
                              ? 'Time (Months)'
                              : 'Loan Tenure (Months)',
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                       width: double.infinity,
                       child: ElevatedButton(onPressed: calculate, child: const Text('Calculate'))
                    ),
                    const SizedBox(height: 32),
                    if (total > 0) _buildResultsCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown() {
     return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
            ),
          child: DropdownButtonFormField<String>(
            value: calculationType,
            dropdownColor: Colors.black87,
            style: const TextStyle(color: Colors.white),
            items: const [
              DropdownMenuItem(value: 'Simple Interest', child: Text('Simple Interest')),
              DropdownMenuItem(value: 'Monthly Interest', child: Text('Monthly Interest')),
              DropdownMenuItem(value: 'EMI (Basic)', child: Text('EMI (Basic)')),
            ],
            onChanged: (v) {
              if (v != null) {
                setState(() => calculationType = v);
              }
            },
            decoration: const InputDecoration(border: InputBorder.none, labelText: 'Calculation Type', labelStyle: TextStyle(color: Colors.white70)),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            labelText: label,
            labelStyle: const TextStyle(color: Colors.white70),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16)
          ),
        ),
      ),
    );
  }

  Widget _buildResultsCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.all(20),
           decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
          child: Column(
            children: [
              _resultRow('Interest', interest),
              const Divider(color: Colors.white30, height: 24),
              _resultRow('Total Amount', total, isBold: true),
              if (emi > 0) ...[
                const Divider(color: Colors.white30, height: 24),
                _resultRow('Monthly EMI', emi),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _resultRow(String title, double value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: GoogleFonts.lato(color: Colors.white70, fontSize: 16)),
        Text(
          '₹${value.toStringAsFixed(2)}',
          style: GoogleFonts.lato(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: Colors.white,
            fontSize: isBold ? 20 : 18,
          ),
        ),
      ],
    );
  }
}
