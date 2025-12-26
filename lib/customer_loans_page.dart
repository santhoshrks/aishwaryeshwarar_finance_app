import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'add_loan_page.dart';
import 'add_payment_page.dart';
import 'payment_history_page.dart';

class CustomerLoansPage extends StatelessWidget {
  final String customerId;
  final Map<String, dynamic> customerData;

  const CustomerLoansPage({
    super.key,
    required this.customerId,
    required this.customerData,
  });

  // ================= AUTO STATUS =================
  String loanStatus(int balance, DateTime endDate) {
    if (balance <= 0) return 'CLOSED';
    if (DateTime.now().isAfter(endDate)) return 'OVERDUE';
    return 'ACTIVE';
  }

  Color statusColor(String status) {
    switch (status) {
      case 'CLOSED':
        return Colors.green;
      case 'OVERDUE':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  int remainingDays(DateTime endDate) {
    final today = DateTime.now();
    final days = endDate.difference(today).inDays;
    return days < 0 ? 0 : days;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(customerData['name']),
        backgroundColor: Colors.deepPurple,
      ),

      // ➕ ADD LOAN
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddLoanPage(customerId: customerId),
            ),
          );
        },
      ),

      body: Column(
        children: [
          // CUSTOMER INFO
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.deepPurple.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('📞 ${customerData['phone']}'),
                Text('🏪 ${customerData['business']}'),
              ],
            ),
          ),

          // LOANS LIST
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('customers')
                  .doc(customerId)
                  .collection('loans')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                      child: CircularProgressIndicator());
                }

                final loans = snapshot.data!.docs;

                if (loans.isEmpty) {
                  return const Center(child: Text('No loans found'));
                }

                return ListView.builder(
                  itemCount: loans.length,
                  itemBuilder: (context, index) {
                    final loan =
                    loans[index].data() as Map<String, dynamic>;

                    final DateTime startDate =
                    (loan['startDate'] as Timestamp).toDate();
                    final DateTime endDate =
                    (loan['endDate'] as Timestamp).toDate();

                    final int balanceDays =
                    remainingDays(endDate);

                    final int balance = loan['balance'];
                    final String status =
                    loanStatus(balance, endDate);

                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Loan ID: ${loan['loanId']}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusColor(status),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                status,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),

                        subtitle: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text('Principal: ₹${loan['principal']}'),
                            Text('Interest: ₹${loan['interest']}'),
                            Text('Balance: ₹$balance'),
                            Text(
                                'Duration: ${loan['durationDays']} days'),
                            Text(
                              'Remaining Days: $balanceDays',
                              style: TextStyle(
                                color: balanceDays == 0
                                    ? Colors.red
                                    : Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'From ${DateFormat('dd MMM yyyy').format(startDate)} '
                                  'to ${DateFormat('dd MMM yyyy').format(endDate)}',
                            ),
                          ],
                        ),

                        // 🔥 ADMIN ACTIONS
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // ➕ ADD PAYMENT
                            IconButton(
                              icon: const Icon(Icons.add_circle,
                                  color: Colors.green),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AddPaymentPage(
                                      customerId: customerId,
                                      loanId: loans[index].id,
                                      currentBalance: balance,
                                    ),
                                  ),
                                );
                              },
                            ),

                            // 📜 PAYMENT HISTORY
                            IconButton(
                              icon: const Icon(Icons.receipt_long,
                                  color: Colors.deepPurple),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        PaymentHistoryPage(
                                          customerId: customerId,
                                          loanId: loans[index].id,
                                        ),
                                  ),
                                );
                              },
                            ),

                            // ✏️ EDIT LOAN
                            IconButton(
                              icon: const Icon(Icons.edit,
                                  color: Colors.orange),
                              onPressed: () {
                                editLoanDialog(
                                  context,
                                  customerId,
                                  loans[index].id,
                                  loan,
                                );
                              },
                            ),

                            // ❌ DELETE LOAN
                            IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Colors.red),
                              onPressed: () async {
                                final confirm =
                                await showDialog<bool>(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title:
                                    const Text('Delete Loan'),
                                    content: const Text(
                                        'Are you sure you want to delete this loan?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(
                                                context, false),
                                        child:
                                        const Text('Cancel'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () =>
                                            Navigator.pop(
                                                context, true),
                                        style:
                                        ElevatedButton.styleFrom(
                                          backgroundColor:
                                          Colors.red,
                                        ),
                                        child:
                                        const Text('Delete'),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  await FirebaseFirestore.instance
                                      .collection('customers')
                                      .doc(customerId)
                                      .collection('loans')
                                      .doc(loans[index].id)
                                      .delete();
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ======================= EDIT LOAN DIALOG =======================

void editLoanDialog(
    BuildContext context,
    String customerId,
    String loanDocId,
    Map<String, dynamic> loan,
    ) {
  final loanIdCtrl =
  TextEditingController(text: loan['loanId']);
  final principalCtrl =
  TextEditingController(text: loan['principal'].toString());
  final interestCtrl =
  TextEditingController(text: loan['interest'].toString());

  DateTime startDate =
  (loan['startDate'] as Timestamp).toDate();
  DateTime endDate =
  (loan['endDate'] as Timestamp).toDate();

  int durationDays = endDate.difference(startDate).inDays;

  showDialog(
    context: context,
    builder: (_) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('Edit Loan'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: loanIdCtrl,
                decoration:
                const InputDecoration(labelText: 'Loan ID'),
              ),
              TextField(
                controller: principalCtrl,
                keyboardType: TextInputType.number,
                decoration:
                const InputDecoration(labelText: 'Principal'),
              ),
              TextField(
                controller: interestCtrl,
                keyboardType: TextInputType.number,
                decoration:
                const InputDecoration(labelText: 'Interest'),
              ),

              const SizedBox(height: 10),

              ListTile(
                title: Text(
                  'Start: ${DateFormat('dd MMM yyyy').format(startDate)}',
                ),
                trailing:
                const Icon(Icons.calendar_today),
                onTap: () async {
                  final d = await showDatePicker(
                    context: context,
                    initialDate: startDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (d != null) {
                    setState(() {
                      startDate = d;
                      durationDays =
                          endDate.difference(startDate).inDays;
                    });
                  }
                },
              ),

              ListTile(
                title: Text(
                  'End: ${DateFormat('dd MMM yyyy').format(endDate)}',
                ),
                trailing:
                const Icon(Icons.calendar_today),
                onTap: () async {
                  final d = await showDatePicker(
                    context: context,
                    initialDate: endDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (d != null) {
                    setState(() {
                      endDate = d;
                      durationDays =
                          endDate.difference(startDate).inDays;
                    });
                  }
                },
              ),

              Text('Duration: $durationDays days'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final int principal =
              int.parse(principalCtrl.text);
              final int interest =
              int.parse(interestCtrl.text);

              await FirebaseFirestore.instance
                  .collection('customers')
                  .doc(customerId)
                  .collection('loans')
                  .doc(loanDocId)
                  .update({
                'loanId': loanIdCtrl.text,
                'principal': principal,
                'interest': interest,
                'balance': principal + interest,
                'startDate': Timestamp.fromDate(startDate),
                'endDate': Timestamp.fromDate(endDate),
                'durationDays': durationDays,
              });

              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    ),
  );
}
