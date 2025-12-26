import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditCustomerPage extends StatefulWidget {
  final String customerId;
  final Map<String, dynamic> customer;

  const EditCustomerPage({
    super.key,
    required this.customerId,
    required this.customer,
  });

  @override
  State<EditCustomerPage> createState() => _EditCustomerPageState();
}

class _EditCustomerPageState extends State<EditCustomerPage> {
  late TextEditingController nameCtrl;
  late TextEditingController phoneCtrl;
  late TextEditingController businessCtrl;
  late TextEditingController addressCtrl;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.customer['name']);
    phoneCtrl = TextEditingController(text: widget.customer['phone']);
    businessCtrl = TextEditingController(text: widget.customer['businessName']);
    addressCtrl = TextEditingController(text: widget.customer['address']);
  }

  Future<void> updateCustomer() async {
    await FirebaseFirestore.instance
        .collection('customers')
        .doc(widget.customerId)
        .update({
      'name': nameCtrl.text,
      'phone': phoneCtrl.text,
      'businessName': businessCtrl.text,
      'address': addressCtrl.text,
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Customer')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Customer Name')),
            const SizedBox(height: 10),
            TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone')),
            const SizedBox(height: 10),
            TextField(controller: businessCtrl, decoration: const InputDecoration(labelText: 'Business')),
            const SizedBox(height: 10),
            TextField(controller: addressCtrl, decoration: const InputDecoration(labelText: 'Address')),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: updateCustomer, child: const Text('Update')),
          ],
        ),
      ),
    );
  }
}
