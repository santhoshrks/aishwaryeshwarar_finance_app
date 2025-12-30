import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

import 'package:intl/intl.dart';

class AddLoanPage extends StatefulWidget {
  final String customerId;
  final String customerName;

  const AddLoanPage({
    super.key,
    required this.customerId,
    required this.customerName,
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

  int get durationDays => endDate.difference(startDate).inDays;

  Future<void> saveLoan() async {
    final int principal = int.tryParse(principalCtrl.text) ?? 0;
    final int interest = int.tryParse(interestCtrl.text) ?? 0;
    final int emiAmount = int.tryParse(emiCtrl.text) ?? 0;

    if(principal <= 0 || interest <= 0 || emiAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

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
      'customerName': widget.customerName,
      'collectionType': collectionType,
      'emiAmount': emiAmount,
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
      backgroundColor: Colors.transparent,
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
            AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.white),
              title: Text('Add New Loan', style: GoogleFonts.lato(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildTextField(controller: loanIdCtrl, hint: 'Loan ID (Optional)'),
                    const SizedBox(height: 16),
                    _buildTextField(controller: principalCtrl, hint: 'Principal Amount', keyboardType: TextInputType.number),
                    const SizedBox(height: 16),
                    _buildTextField(controller: interestCtrl, hint: 'Interest Amount', keyboardType: TextInputType.number),
                    const SizedBox(height: 16),
                    _buildTextField(controller: emiCtrl, hint: 'EMI Amount', keyboardType: TextInputType.number),
                    const SizedBox(height: 16),
                    _buildDropdown(),
                    const SizedBox(height: 16),
                    _buildDatePicker('Start Date', startDate, (d) => setState(() => startDate = d)),
                    const SizedBox(height: 16),
                     _buildDatePicker('End Date', endDate, (d) => setState(() => endDate = d)),
                    const SizedBox(height: 16),
                    Text('Duration: $durationDays days', style: GoogleFonts.lato(color: Colors.white, fontSize: 16)),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.secondary, foregroundColor: Colors.black),
                        onPressed: saveLoan,
                        child: Text('Save Loan', style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 18)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hint, TextInputType? keyboardType}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white70),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16)
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
            ),
          child: DropdownButtonFormField<String>(
            value: collectionType,
            dropdownColor: Colors.black87,
            style: const TextStyle(color: Colors.white),
            items: const [
              DropdownMenuItem(value: 'DAILY', child: Text('Daily Collection')),
              DropdownMenuItem(value: 'WEEKLY', child: Text('Weekly Collection')),
            ],
            onChanged: (v) {
              if (v != null) {
                setState(() {
                  collectionType = v;
                });
              }
            },
            decoration: const InputDecoration(
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker(String label, DateTime date, Function(DateTime) onSelect) {
    return ClipRRect(
       borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
           decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
            ),
          child: ListTile(
            title: Text(label, style: GoogleFonts.lato(color: Colors.white70)),
            subtitle: Text(DateFormat('dd MMM yyyy').format(date), style: GoogleFonts.lato(color: Colors.white, fontSize: 16)),
            trailing: const Icon(Icons.calendar_today, color: Colors.white70),
            onTap: () async {
              final d = await showDatePicker(
                context: context,
                initialDate: date,
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
              );
              if (d != null) {
                onSelect(d);
              }
            },
          ),
        ),
      ),
    );
  }
}
