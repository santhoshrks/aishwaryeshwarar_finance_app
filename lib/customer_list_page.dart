import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

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
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: _buildAppBar(),
      floatingActionButton: _buildFloatingActionButton(context),
      body: Column(
        children: [
          _buildSearchField(),
          _buildCustomerList(),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFF0F2F5),
      elevation: 0,
      iconTheme: const IconThemeData(color: Color(0xFF333333)),
      title: Text(
        'Customers',
        style: GoogleFonts.lato(
          color: const Color(0xFF333333),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  FloatingActionButton _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: const Color(0xFF4B2C82),
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AddCustomerPage()),
      ),
      child: const Icon(Icons.person_add, color: Colors.white),
    );
  }

  Padding _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search by name or phone',
          prefixIcon: const Icon(Icons.search, color: Colors.black54),
          filled: true,
          fillColor: Colors.white,
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
        stream: FirebaseFirestore.instance
            .collection('customers')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final filteredCustomers = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;

            final name = (data['name'] ?? '').toString().toLowerCase();
            final phone = (data['phone'] ?? '').toString().toLowerCase();

            return name.contains(searchText) || phone.contains(searchText);
          }).toList();

          if (filteredCustomers.isEmpty) {
            return Center(
              child: Text(
                'No matching customers found',
                style: GoogleFonts.lato(),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: filteredCustomers.length,
            itemBuilder: (context, index) {
              final customerDoc = filteredCustomers[index];
              final customer =
              customerDoc.data() as Map<String, dynamic>;

              final name = customer['name'] ?? '';
              final business = customer['business'] ?? '';
              final phone = customer['phone'] ?? '';

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                elevation: 2,
                shadowColor: Colors.black12,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(
                    name,
                    style: GoogleFonts.lato(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '$business • $phone',
                    style: GoogleFonts.lato(),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.edit,
                          color: Colors.blueGrey,
                        ),
                        onPressed: () => _showEditCustomerDialog(
                          context,
                          customerDoc.id,
                          customer,
                        ),
                      ),
                      IconButton(
                        icon: const FaIcon(
                          FontAwesomeIcons.whatsapp,
                          color: Colors.green,
                        ),
                        onPressed: () {
                          final message =
                              'Dear $name,\n\n'
                              'This is a friendly reminder regarding your account.\n'
                              'Please check the app for details.\n\n'
                              'Thank you.';
                          _sendWhatsAppMessage(context, phone, message);
                        },
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_forward_ios,
                          size: 18,
                          color: Colors.black45,
                        ),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CustomerLoansPage(
                              customerId: customerDoc.id,
                              customerData: customer,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showEditCustomerDialog(
      BuildContext context,
      String docId,
      Map<String, dynamic> customerData,
      ) {
    final nameController =
    TextEditingController(text: customerData['name']);
    final businessController =
    TextEditingController(text: customerData['business']);
    final phoneController =
    TextEditingController(text: customerData['phone']);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Edit Customer', style: GoogleFonts.lato()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration:
              const InputDecoration(labelText: 'Customer Name'),
            ),
            TextField(
              controller: businessController,
              decoration:
              const InputDecoration(labelText: 'Business Name'),
            ),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration:
              const InputDecoration(labelText: 'Mobile Number'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.lato()),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('customers')
                  .doc(docId)
                  .update({
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

  Future<void> _sendWhatsAppMessage(
      BuildContext context,
      String phoneNumber,
      String message,
      ) async {
    String cleanPhone =
    phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');

    if (!cleanPhone.startsWith('91')) {
      cleanPhone = '91$cleanPhone';
    }

    final Uri url = Uri.parse(
      'https://wa.me/$cleanPhone?text=${Uri.encodeComponent(message)}',
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open WhatsApp')),
        );
      }
    }
  }
}
