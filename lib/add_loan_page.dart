import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AddLoanPage extends StatefulWidget {
  final String customerId;

  const AddLoanPage({super.key, required this.customerId});

  @override
  State<AddLoanPage> createState() => _AddLoanPageState();
}

class _AddLoanPageState extends State<AddLoanPage> {
  final loanIdCtrl = TextEditingController();
  final principalCtrl = TextEditingController();
  final interestCtrl = TextEditingController();

  DateTime? startDate;
  DateTime? endDate;

  String collectionType = 'Daily'; // Default
  int emiAmount = 0;

  int get durationDays {
    if (startDate == null || endDate == null) return 0;
    return endDate!.difference(startDate!).inDays;
  }

  void calculateEmi() {
    if (durationDays <= 0) return;

    final principal = int.tryParse(principalCtrl.text) ?? 0;
    final interest = int.tryParse(interestCtrl.text) ?? 0;
    final total = principal + interest;

    if (collectionType == 'Daily') {
      emiAmount = (total / durationDays).ceil();
    } else {
      final weeks = (durationDays / 7).ceil();
      emiAmount = (total / weeks).ceil();
    }
  }

  Future<void> pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
        } else {
          endDate = picked;
        }
        calculateEmi();
      });
    }
  }

  Future<void> saveLoan() async {
    if (startDate == null || endDate == null) return;

    final principal = int.parse(principalCtrl.text);
    final interest = int.parse(interestCtrl.text);
    final total = principal + interest;

    await FirebaseFirestore.instance
        .collection('customers')
        .doc(widget.customerId)
        .collection('loans')
        .add({
      'loanId': loanIdCtrl.text,
      'principal': principal,
      'interest': interest,
      'balance': total,
      'startDate': Timestamp.fromDate(startDate!),
      'endDate': Timestamp.fromDate(endDate!),
      'durationDays': durationDays,
      'collectionType': collectionType,
      'emiAmount': emiAmount,
      'createdAt': Timestamp.now(),
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Loan'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: loanIdCtrl,
              decoration: const InputDecoration(
                labelText: 'Loan ID',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: principalCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Principal',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(calculateEmi),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: interestCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Interest',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(calculateEmi),
            ),
            const SizedBox(height: 12),

            // COLLECTION TYPE
            DropdownButtonFormField<String>(
              value: collectionType,
              decoration: const InputDecoration(
                labelText: 'Collection Type',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'Daily', child: Text('Daily')),
                DropdownMenuItem(value: 'Weekly', child: Text('Weekly')),
              ],
              onChanged: (value) {
                setState(() {
                  collectionType = value!;
                  calculateEmi();
                });
              },
            ),
            const SizedBox(height: 12),

            ListTile(
              title: Text(startDate == null
                  ? 'Select Start Date'
                  : 'Start: ${DateFormat('dd MMM yyyy').format(startDate!)}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => pickDate(true),
            ),

            ListTile(
              title: Text(endDate == null
                  ? 'Select End Date'
                  : 'End: ${DateFormat('dd MMM yyyy').format(endDate!)}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => pickDate(false),
            ),

            const SizedBox(height: 10),
            Text(
              'Duration: $durationDays days',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'EMI (${collectionType}): ₹$emiAmount',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveLoan,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.all(14),
              ),
              child: const Text('Save Loan'),
            ),
          ],
        ),
      ),
    );
  }
}
