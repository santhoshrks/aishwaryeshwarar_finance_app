import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'add_payment_page.dart';

class TodayCollectionPage extends StatelessWidget {
  const TodayCollectionPage({super.key});

  int remainingDays(DateTime endDate) {
    final diff = endDate.difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : diff;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Today Collection'),
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('customers').snapshots(),
        builder: (context, customerSnap) {
          if (!customerSnap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final customers = customerSnap.data!.docs;

          return ListView(
            children: customers.map((customerDoc) {
              final customer =
              customerDoc.data() as Map<String, dynamic>;

              return StreamBuilder<QuerySnapshot>(
                stream: customerDoc.reference
                    .collection('loans')
                    .snapshots(),
                builder: (context, loanSnap) {
                  if (!loanSnap.hasData) return const SizedBox();

                  final loans = loanSnap.data!.docs;

                  return Column(
                    children: loans.map((loanDoc) {
                      final loan =
                      loanDoc.data() as Map<String, dynamic>;

                      final DateTime endDate =
                      (loan['endDate'] as Timestamp).toDate();
                      final int balance = loan['balance'];

                      if (balance <= 0 ||
                          remainingDays(endDate) == 0) {
                        return const SizedBox();
                      }

                      return Card(
                        margin: const EdgeInsets.all(10),
                        child: ListTile(
                          title: Text(
                            customer['name'],
                            style: const TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text('Loan ID: ${loan['loanId']}'),
                              Text('Balance: ₹$balance'),
                              Text(
                                  'Remaining Days: ${remainingDays(endDate)}'),
                            ],
                          ),
                          trailing: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AddPaymentPage(
                                    customerId: customerDoc.id,
                                    loanId: loanDoc.id,
                                    currentBalance: balance,
                                  ),
                                ),
                              );
                            },
                            child: const Text('Collect'),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
