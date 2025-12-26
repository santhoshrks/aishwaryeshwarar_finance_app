import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
    final int amount = int.parse(paymentCtrl.text);

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

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Payment'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Current Balance: ₹${widget.currentBalance}',
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: paymentCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Payment Amount',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: noteCtrl,
              decoration: const InputDecoration(
                labelText: 'Note (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: savePayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.all(14),
              ),
              child: const Text('Save Payment'),
            ),
          ],
        ),
      ),
    );
  }
}
