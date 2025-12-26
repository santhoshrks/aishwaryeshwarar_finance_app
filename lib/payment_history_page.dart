import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PaymentHistoryPage extends StatelessWidget {
  final String customerId;
  final String loanId;

  const PaymentHistoryPage({
    super.key,
    required this.customerId,
    required this.loanId,
  });

  @override
  Widget build(BuildContext context) {
    final loanRef = FirebaseFirestore.instance
        .collection('customers')
        .doc(customerId)
        .collection('loans')
        .doc(loanId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment History'),
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: loanRef
            .collection('payments')
            .orderBy('paidAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final payments = snapshot.data!.docs;

          if (payments.isEmpty) {
            return const Center(child: Text('No payments found'));
          }

          return ListView.builder(
            itemCount: payments.length,
            itemBuilder: (context, index) {
              final payment =
              payments[index].data() as Map<String, dynamic>;

              final int amount = payment['amount'];
              final DateTime date =
              (payment['paidAt'] as Timestamp).toDate();
              final String note = payment['note'] ?? '';

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  leading: const Icon(
                    Icons.currency_rupee,
                    color: Colors.green,
                  ),
                  title: Text(
                    '₹$amount',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(DateFormat('dd MMM yyyy').format(date)),
                      if (note.isNotEmpty) Text('Note: $note'),
                    ],
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'edit',
                        child: Text('Edit'),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                    onSelected: (value) async {
                      if (value == 'delete') {
                        await loanRef
                            .collection('payments')
                            .doc(payments[index].id)
                            .delete();

                        await loanRef.update({
                          'balance':
                          FieldValue.increment(amount),
                        });
                      }

                      if (value == 'edit') {
                        final ctrl = TextEditingController(
                            text: amount.toString());

                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title:
                            const Text('Edit Payment'),
                            content: TextField(
                              controller: ctrl,
                              keyboardType:
                              TextInputType.number,
                            ),
                            actions: [
                              TextButton(
                                child:
                                const Text('Save'),
                                onPressed: () async {
                                  final newAmount =
                                  int.parse(ctrl.text);
                                  final diff =
                                      newAmount - amount;

                                  await loanRef
                                      .collection('payments')
                                      .doc(payments[index].id)
                                      .update({
                                    'amount': newAmount,
                                  });

                                  await loanRef.update({
                                    'balance':
                                    FieldValue.increment(
                                        -diff),
                                  });

                                  Navigator.pop(context);
                                },
                              )
                            ],
                          ),
                        );
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
