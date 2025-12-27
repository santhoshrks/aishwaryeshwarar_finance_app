import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddLoanPage extends StatefulWidget {
  final String customerId;

  const AddLoanPage({
    super.key,
    required this.customerId,
  });

  @override
  State<AddLoanPage> createState() => _AddLoanPageState();
}

class _AddLoanPageState extends State<AddLoanPage> {
  final loanIdCtrl = TextEditingController();
  final principalCtrl = TextEditingController();
  final interestCtrl = TextEditingController();
  final emiCtrl = TextEditingController();

  String collectionType = 'DAILY';

  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now().add(const Duration(days: 30));

  int get durationDays =>
      endDate.difference(startDate).inDays;

  Future<void> saveLoan() async {
    final int principal = int.parse(principalCtrl.text);
    final int interest = int.parse(interestCtrl.text);
    final int emiAmount = int.parse(emiCtrl.text);

    final int balance = principal + interest;

    await FirebaseFirestore.instance
        .collection('customers')
        .doc(widget.customerId)
        .collection('loans')
        .add({
      'loanId': loanIdCtrl.text,
      'principal': principal,
      'interest': interest,
      'balance': balance,

      // 🔔 EMI SYSTEM
      'collectionType': collectionType, // DAILY / WEEKLY
      'emiAmount': emiAmount,

      // 📅 DATES
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'durationDays': durationDays,

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: loanIdCtrl,
              decoration: const InputDecoration(
                labelText: 'Loan ID',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: principalCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Principal Amount',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: interestCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Interest Amount',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // 🔽 COLLECTION TYPE
            DropdownButtonFormField<String>(
              value: collectionType,
              items: const [
                DropdownMenuItem(
                  value: 'DAILY',
                  child: Text('Daily Collection'),
                ),
                DropdownMenuItem(
                  value: 'WEEKLY',
                  child: Text('Weekly Collection'),
                ),
              ],
              onChanged: (v) {
                setState(() {
                  collectionType = v!;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Collection Type',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // 💰 EMI AMOUNT
            TextField(
              controller: emiCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'EMI Amount',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // 📅 START DATE
            ListTile(
              title: Text(
                'Start Date: ${startDate.day}-${startDate.month}-${startDate.year}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: startDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                );
                if (d != null) {
                  setState(() => startDate = d);
                }
              },
            ),

            // 📅 END DATE
            ListTile(
              title: Text(
                'End Date: ${endDate.day}-${endDate.month}-${endDate.year}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: endDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                );
                if (d != null) {
                  setState(() => endDate = d);
                }
              },
            ),

            Text('Duration: $durationDays days'),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: saveLoan,
                child: const Text('Save Loan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
