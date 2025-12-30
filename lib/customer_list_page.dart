import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui';

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
      backgroundColor: Colors.transparent,
      floatingActionButton: _buildFloatingActionButton(context),
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
            _buildAppBar(context),
            _buildSearchField(),
            _buildCustomerList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      title: Text('Customers', style: GoogleFonts.lato(color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }

  FloatingActionButton _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddCustomerPage())),
      child: const Icon(Icons.person_add, color: Colors.black),
    );
  }

  Padding _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search by name or phone',
          hintStyle: TextStyle(color: Colors.white70),
          prefixIcon: const Icon(Icons.search, color: Colors.white70),
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (value) {
          setState(() {
            searchText = value.trim().toLowerCase();
          });
        },
      ),
    );
  }

  Expanded _buildCustomerList() {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('customers').orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: Colors.white,));
          }
          final filteredCustomers = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final name = (data['name'] ?? '').toString().toLowerCase();
            final phone = (data['phone'] ?? '').toString().toLowerCase();
            return name.contains(searchText) || phone.contains(searchText);
          }).toList();

          if (filteredCustomers.isEmpty) {
            return Center(child: Text('No matching customers found', style: GoogleFonts.lato(color: Colors.white)));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: filteredCustomers.length,
            itemBuilder: (context, index) {
              final customerDoc = filteredCustomers[index];
              final customer = customerDoc.data() as Map<String, dynamic>;

              return _buildCustomerCard(context, customerDoc, customer);
            },
          );
        },
      ),
    );
  }
  
  Widget _buildCustomerCard(BuildContext context, QueryDocumentSnapshot customerDoc, Map<String, dynamic> customer) {
      final name = customer['name'] ?? '';
      final business = customer['business'] ?? '';
      final phone = customer['phone'] ?? '';

      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
             margin: const EdgeInsets.symmetric(vertical: 6),
             padding: const EdgeInsets.all(12),
             decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
            child: Column(
              children: [
                ListTile(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CustomerLoansPage(customerId: customerDoc.id, customerData: customer))),
                  title: Text(name, style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18)),
                  subtitle: Text('$business • $phone', style: GoogleFonts.lato(color: Colors.white70)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.white),
                ),
                const Divider(color: Colors.white30, height: 1, indent: 16, endIndent: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(icon: Icon(Icons.edit, color: Colors.blue[200]), onPressed: () => _showEditCustomerDialog(context, customerDoc.id, customer), tooltip: 'Edit'),
                    IconButton(icon: Icon(Icons.delete, color: Colors.red[300]), onPressed: () => _deleteCustomer(context, customerDoc), tooltip: 'Delete'),
                    IconButton(icon: FaIcon(FontAwesomeIcons.whatsapp, color: Colors.green[300]), onPressed: () {
                      final message = 'Dear $name,\n\nThis is a friendly reminder regarding your account. Please check the app for details.\n\nThank you.';
                      _sendWhatsAppMessage(context, phone, message);
                    }, tooltip: 'Send Reminder'),
                  ],
                )
              ],
            ),
          ),
        ),
      );
  }
  
  void _showEditCustomerDialog(BuildContext context, String docId, Map<String, dynamic> customerData) {
    final nameController = TextEditingController(text: customerData['name']);
    final businessController = TextEditingController(text: customerData['business']);
    final phoneController = TextEditingController(text: customerData['phone']);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Edit Customer', style: GoogleFonts.lato()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Customer Name')),
            TextField(controller: businessController, decoration: const InputDecoration(labelText: 'Business Name')),
            TextField(controller: phoneController, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Mobile Number')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: GoogleFonts.lato())),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('customers').doc(docId).update({
                'name': nameController.text.trim(),
                'business': businessController.text.trim(),
                'phone': phoneController.text.trim(),
              });
              Navigator.pop(context);
            },
            child: Text('Save', style: GoogleFonts.lato()),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCustomer(BuildContext context, QueryDocumentSnapshot customerDoc) async {
    final loansSnapshot = await customerDoc.reference.collection('loans').where('balance', isGreaterThan: 0).get();
    if (loansSnapshot.docs.isNotEmpty) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cannot delete customer with active loans.'), backgroundColor: Colors.redAccent,));
      return;
    }
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Customer?', style: GoogleFonts.lato()),
        content: Text('This will permanently delete this customer and all their closed loans and payments. This action cannot be undone.', style: GoogleFonts.lato()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel', style: GoogleFonts.lato())),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Delete', style: GoogleFonts.lato(color: Colors.red))),
        ],
      ),
    );
    if (confirm != true) return;
    final allLoansSnapshot = await customerDoc.reference.collection('loans').get();
    for (final loan in allLoansSnapshot.docs) {
      final paymentsSnapshot = await loan.reference.collection('payments').get();
      for (final payment in paymentsSnapshot.docs) {
        await payment.reference.delete();
      }
      await loan.reference.delete();
    }
    await customerDoc.reference.delete();
    if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Customer deleted successfully')));
  }

  Future<void> _sendWhatsAppMessage(BuildContext context, String phoneNumber, String message) async {
    String cleanPhone = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    if (!cleanPhone.startsWith('91')) {
      cleanPhone = '91$cleanPhone';
    }
    final Uri url = Uri.parse('https://wa.me/$cleanPhone?text=${Uri.encodeComponent(message)}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open WhatsApp')));
      }
    }
  }
}
