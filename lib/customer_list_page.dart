import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'add_customer_page.dart';
import 'customer_loans_page.dart';

class CustomerListPage extends StatefulWidget {
  const CustomerListPage({super.key});

  @override
  State<CustomerListPage> createState() => _CustomerListPageState();
}

class _CustomerListPageState extends State<CustomerListPage> {
  String searchText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
        backgroundColor: Colors.deepPurple,
      ),

      // ➕ ADD CUSTOMER
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.person_add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddCustomerPage(),
            ),
          );
        },
      ),

      body: Column(
        children: [
          // 🔍 SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search name or phone',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchText = value.toLowerCase();
                });
              },
            ),
          ),

          // 👥 CUSTOMER LIST
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('customers')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                      child: CircularProgressIndicator());
                }

                final allCustomers = snapshot.data!.docs;

                // 🔎 FILTER LOGIC
                final filteredCustomers =
                allCustomers.where((doc) {
                  final data =
                  doc.data() as Map<String, dynamic>;
                  final name =
                  (data['name'] ?? '').toString().toLowerCase();
                  final phone =
                  (data['phone'] ?? '').toString().toLowerCase();

                  return name.contains(searchText) ||
                      phone.contains(searchText);
                }).toList();

                if (filteredCustomers.isEmpty) {
                  return const Center(
                      child: Text('No matching customers'));
                }

                return ListView.builder(
                  itemCount: filteredCustomers.length,
                  itemBuilder: (context, index) {
                    final customerDoc =
                    filteredCustomers[index];
                    final customer =
                    customerDoc.data()
                    as Map<String, dynamic>;

                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        title: Text(
                          customer['name'],
                          style: const TextStyle(
                              fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${customer['business']} • ${customer['phone']}',
                        ),

                        // 🔥 OPEN + DELETE CUSTOMER
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // OPEN CUSTOMER
                            IconButton(
                              icon:
                              const Icon(Icons.arrow_forward),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        CustomerLoansPage(
                                          customerId:
                                          customerDoc.id,
                                          customerData: customer,
                                        ),
                                  ),
                                );
                              },
                            ),

                            // DELETE CUSTOMER (ADMIN)
                            IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Colors.red),
                              onPressed: () {
                                deleteCustomer(
                                  context,
                                  customerDoc.id,
                                );
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

//
// ====================== DELETE CUSTOMER LOGIC ======================
//

Future<void> deleteCustomer(
    BuildContext context,
    String customerId,
    ) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Delete Customer'),
      content: const Text(
        'This will permanently delete the customer,\n'
            'ALL loans and ALL payments.\n\n'
            'Are you sure?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style:
          ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );

  if (confirm != true) return;

  final customerRef =
  FirebaseFirestore.instance.collection('customers').doc(customerId);

  // 1️⃣ GET ALL LOANS
  final loansSnapshot =
  await customerRef.collection('loans').get();

  for (final loanDoc in loansSnapshot.docs) {
    // 2️⃣ GET PAYMENTS UNDER LOAN
    final paymentsSnapshot =
    await loanDoc.reference.collection('payments').get();

    // 3️⃣ DELETE PAYMENTS
    for (final paymentDoc in paymentsSnapshot.docs) {
      await paymentDoc.reference.delete();
    }

    // 4️⃣ DELETE LOAN
    await loanDoc.reference.delete();
  }

  // 5️⃣ DELETE CUSTOMER
  await customerRef.delete();

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
        content: Text('Customer deleted successfully')),
  );
}
