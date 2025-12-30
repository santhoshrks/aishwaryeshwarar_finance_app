import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

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

  String loanStatus(int balance, DateTime endDate) {
    if (balance <= 0) return 'CLOSED';
    if (DateTime.now().isAfter(endDate)) return 'OVERDUE';
    return 'ACTIVE';
  }

  Color statusColor(String status) {
    switch (status) {
      case 'CLOSED':
        return Colors.green.shade700;
      case 'OVERDUE':
        return Colors.red.shade700;
      default:
        return Colors.orange.shade700;
    }
  }

  int remainingDays(DateTime endDate) {
    final today = DateTime.now();
    final days = endDate.difference(today).inDays;
    return days < 0 ? 0 : days;
  }

  Future<void> _sendWhatsAppMessage(BuildContext context, String phoneNumber, String message) async {
    final url = 'https://wa.me/$phoneNumber/?text=${Uri.encodeComponent(message)}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch WhatsApp')),
      );
    }
  }
  
  // ================= DELETE LOAN =================
  Future<void> _deleteLoan(BuildContext context, QueryDocumentSnapshot loanDoc) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Loan?', style: GoogleFonts.lato()),
        content: Text('This will permanently delete this loan and all its associated payments. This action cannot be undone.', style: GoogleFonts.lato()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel', style: GoogleFonts.lato())),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Delete', style: GoogleFonts.lato(color: Colors.red))),
        ],
      ),
    );

    if (confirm != true) return;

    // Delete all payments in the sub-collection first
    final paymentsSnapshot = await loanDoc.reference.collection('payments').get();
    for (final payment in paymentsSnapshot.docs) {
      await payment.reference.delete();
    }

    // Delete the loan document itself
    await loanDoc.reference.delete();
    
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Loan deleted successfully', style: GoogleFonts.lato())));
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: _buildAppBar(context),
      floatingActionButton: _buildFloatingActionButton(context),
      body: Column(
        children: [
          _buildCustomerHeader(),
          _buildLoanList(context),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFF0F2F5),
      elevation: 0,
      iconTheme: const IconThemeData(color: Color(0xFF333333)),
      title: Text(
        customerData['name'] ?? 'Customer Loans',
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
          MaterialPageRoute(
              builder: (_) => AddLoanPage(
                    customerId: customerId,
                    customerName: customerData['name'] ?? '',
                  ))),
      child: const Icon(Icons.add, color: Colors.white),
    );
  }

  Container _buildCustomerHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('📞 ${customerData['phone'] ?? ''}', style: GoogleFonts.lato(fontSize: 16)),
          const SizedBox(height: 4),
          Text('🏪 ${customerData['business'] ?? ''}', style: GoogleFonts.lato(fontSize: 16)),
        ],
      ),
    );
  }

  Expanded _buildLoanList(BuildContext context) {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('customers').doc(customerId).collection('loans').orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final loans = snapshot.data!.docs;
          if (loans.isEmpty) {
            return Center(child: Text('No loans found for this customer.', style: GoogleFonts.lato()));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: loans.length,
            itemBuilder: (context, index) {
              final loan = loans[index].data() as Map<String, dynamic>;
              final DateTime startDate = (loan['startDate'] as Timestamp).toDate();
              final DateTime endDate = (loan['endDate'] as Timestamp).toDate();
              final int balance = loan['balance'];
              final String status = loanStatus(balance, endDate);
              return _buildLoanCard(context, loans[index], loan, status, startDate, endDate);
            },
          );
        },
      ),
    );
  }

  Widget _buildLoanCard(BuildContext context, QueryDocumentSnapshot loanDoc, Map<String, dynamic> loan, String status, DateTime startDate, DateTime endDate) {
    final daysLeft = remainingDays(endDate);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Loan ID: ${loan['loanId']}', style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 16)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: statusColor(status), borderRadius: BorderRadius.circular(6)),
                  child: Text(status, style: GoogleFonts.lato(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildLoanDetailRow('Principal:', '₹${loan['principal']}'),
            _buildLoanDetailRow('Interest:', '₹${loan['interest']}'),
            _buildLoanDetailRow('Balance:', '₹${loan['balance']}', isBold: true),
            const Divider(height: 24),
            _buildLoanDetailRow('Start Date:', DateFormat('dd MMM yyyy').format(startDate)),
            _buildLoanDetailRow('End Date:', DateFormat('dd MMM yyyy').format(endDate)),
            _buildLoanDetailRow('Remaining Days:', daysLeft.toString(), isBold: true),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                 IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent, size: 24),
                  onPressed: () => _deleteLoan(context, loanDoc),
                ),
                 IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blueGrey, size: 24),
                  onPressed: () => _showEditLoanDialog(context, loanDoc, loan),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.history, size: 20), 
                  label: Text('History', style: GoogleFonts.lato()),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PaymentHistoryPage(customerId: customerId, loanId: loanDoc.id))),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add, size: 20),
                  label: Text('Add Payment', style: GoogleFonts.lato()),
                  onPressed: () async {
                    final paymentAmount = await Navigator.push<int>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddPaymentPage(
                          customerId: customerId,
                          loanId: loanDoc.id,
                          currentBalance: loan['balance'],
                        ),
                      ),
                    );
                    if (paymentAmount != null && paymentAmount > 0) {
                      final message = 'Dear ${customerData['name']}, we have successfully received your payment of ₹$paymentAmount. Thank you.';
                      _sendWhatsAppMessage(context, customerData['phone'], message);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoanDetailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.lato(color: Colors.black54)),
          Text(
            value,
            style: GoogleFonts.lato(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 16 : 14,
              color: isBold && label == 'Remaining Days:' ? (int.tryParse(value) ?? 0) < 7 ? Colors.red : Colors.green : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  void _showEditLoanDialog(BuildContext context, QueryDocumentSnapshot loanDoc, Map<String, dynamic> loan) {
    final loanIdCtrl = TextEditingController(text: loan['loanId']);
    final principalCtrl = TextEditingController(text: loan['principal'].toString());
    final interestCtrl = TextEditingController(text: loan['interest'].toString());
    final emiCtrl = TextEditingController(text: loan['emiAmount'].toString());
    String collectionType = loan['collectionType'];
    DateTime startDate = (loan['startDate'] as Timestamp).toDate();
    DateTime endDate = (loan['endDate'] as Timestamp).toDate();

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Edit Loan', style: GoogleFonts.lato()),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: loanIdCtrl, decoration: const InputDecoration(labelText: 'Loan ID')),
                TextField(controller: principalCtrl, decoration: const InputDecoration(labelText: 'Principal'), keyboardType: TextInputType.number),
                TextField(controller: interestCtrl, decoration: const InputDecoration(labelText: 'Interest'), keyboardType: TextInputType.number),
                TextField(controller: emiCtrl, decoration: const InputDecoration(labelText: 'EMI Amount'), keyboardType: TextInputType.number),
                DropdownButtonFormField<String>(
                  value: collectionType,
                  items: const [DropdownMenuItem(value: 'DAILY', child: Text('Daily')), DropdownMenuItem(value: 'WEEKLY', child: Text('Weekly'))],
                  onChanged: (v) => setState(() => collectionType = v!),
                  decoration: const InputDecoration(labelText: 'Collection Type'),
                ),
                ListTile(
                  title: Text('Start: ${DateFormat('dd MMM yyyy').format(startDate)}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final d = await showDatePicker(context: context, initialDate: startDate, firstDate: DateTime(2020), lastDate: DateTime(2100));
                    if (d != null) setState(() => startDate = d);
                  },
                ),
                ListTile(
                  title: Text('End: ${DateFormat('dd MMM yyyy').format(endDate)}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final d = await showDatePicker(context: context, initialDate: endDate, firstDate: DateTime(2020), lastDate: DateTime(2100));
                    if (d != null) setState(() => endDate = d);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: GoogleFonts.lato())),
            ElevatedButton(
              onPressed: () async {
                final int principal = int.tryParse(principalCtrl.text) ?? 0;
                final int interest = int.tryParse(interestCtrl.text) ?? 0;
                await loanDoc.reference.update({
                  'loanId': loanIdCtrl.text,
                  'principal': principal,
                  'interest': interest,
                  'balance': principal + interest, // Recalculate balance
                  'emiAmount': int.tryParse(emiCtrl.text) ?? 0,
                  'collectionType': collectionType,
                  'startDate': Timestamp.fromDate(startDate),
                  'endDate': Timestamp.fromDate(endDate),
                  'durationDays': endDate.difference(startDate).inDays,
                });
                Navigator.pop(context);
              },
              child: Text('Save', style: GoogleFonts.lato()),
            ),
          ],
        ),
      ),
    );
  }
}
