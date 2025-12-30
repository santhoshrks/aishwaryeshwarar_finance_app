import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

class AddPaymentPage extends StatefulWidget {
  final String customerId;
  final String loanId;
  final int currentBalance;

  const AddPaymentPage({
    super.key,
    required this.customerId,
    required this.loanId,
    required this.currentBalance,
  });

  @override
  State<AddPaymentPage> createState() => _AddPaymentPageState();
}

class _AddPaymentPageState extends State<AddPaymentPage> {
  final paymentCtrl = TextEditingController();
  final noteCtrl = TextEditingController();

  Future<void> savePayment() async {
    final int amount = int.tryParse(paymentCtrl.text) ?? 0;

    if (amount <= 0 || amount > widget.currentBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid payment amount')),
      );
      return;
    }

    final int newBalance = widget.currentBalance - amount;

    final loanRef = FirebaseFirestore.instance
        .collection('customers')
        .doc(widget.customerId)
        .collection('loans')
        .doc(widget.loanId);

    await loanRef.collection('payments').add({
      'amount': amount,
      'paidAt': Timestamp.now(),
      'note': noteCtrl.text,
    });

    await loanRef.update({'balance': newBalance});

    Navigator.pop(context, amount);
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
              title: Text('Add Payment', style: GoogleFonts.lato(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Current Balance: ₹${widget.currentBalance}',
                      style: GoogleFonts.lato(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 32),
                    _buildTextField(controller: paymentCtrl, hint: 'Payment Amount', keyboardType: TextInputType.number),
                    const SizedBox(height: 16),
                    _buildTextField(controller: noteCtrl, hint: 'Note (optional)'),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: savePayment,
                        child: Text('Save Payment', style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hint, TextInputType? keyboardType}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white70),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
