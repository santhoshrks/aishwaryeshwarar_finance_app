import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

class ExportReportsPage extends StatefulWidget {
  const ExportReportsPage({super.key});

  @override
  State<ExportReportsPage> createState() => _ExportReportsPageState();
}

class _ExportReportsPageState extends State<ExportReportsPage> {
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isExporting = false;

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          // Set endDate to the end of the selected day
          _endDate = DateTime(picked.year, picked.month, picked.day, 23, 59, 59);
        }
      });
    }
  }

  Future<void> _exportToExcel() async {
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both a start and end date.')),
      );
      return;
    }

    setState(() {
      _isExporting = true;
    });

    try {
      // 1. Fetch data from Firestore
      final paymentsSnapshot = await FirebaseFirestore.instance
          .collectionGroup('payments')
          .where('paidAt', isGreaterThanOrEqualTo: _startDate)
          .where('paidAt', isLessThanOrEqualTo: _endDate)
          .orderBy('paidAt', descending: true)
          .get();

      // 2. Create Excel file
      final excel = Excel.createExcel();
      final Sheet sheet = excel['Payments'];

      // Add header row
      sheet.appendRow(['Date', 'Customer Name', 'Loan ID', 'Amount', 'Note']);

      // Add data rows
      for (var doc in paymentsSnapshot.docs) {
        final data = doc.data();
        sheet.appendRow([
          DateFormat('dd-MM-yyyy').format((data['paidAt'] as Timestamp).toDate()),
          data['customerName'] ?? 'N/A',
          data['loanIdString'] ?? 'N/A',
          data['amount'] ?? 0,
          data['note'] ?? '',
        ]);
      }

      // 3. Save and share the file
      final Directory? directory = await getExternalStorageDirectory();
      if(directory == null) {
        throw Exception('Could not get external storage directory');
      }
      
      final String fileName = 'Payment_Report_${DateFormat('yyyy-MM-dd').format(DateTime.now())}.xlsx';
      final String filePath = '${directory.path}/$fileName';

      final fileBytes = excel.save();
      if (fileBytes != null) {
        final File file = File(filePath)
          ..createSync(recursive: true)
          ..writeAsBytesSync(fileBytes);

        await Share.shareXFiles([XFile(file.path)], text: 'Here is your payment report.');
      }

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error exporting to Excel: $e')),
      );
    }

    setState(() {
      _isExporting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Export Reports', style: GoogleFonts.lato()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select a date range to export payment data to an Excel file.',
              style: GoogleFonts.lato(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 32),
            _buildDatePicker(context, 'Start Date', _startDate, () => _selectDate(context, true)),
            const SizedBox(height: 16),
            _buildDatePicker(context, 'End Date', _endDate, () => _selectDate(context, false)),
            const Spacer(),
            if (_isExporting)
              const Center(child: CircularProgressIndicator())
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.download_for_offline),
                  label: const Text('Export to Excel'),
                  onPressed: _exportToExcel,
                ),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context, String title, DateTime? date, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: GoogleFonts.lato(fontSize: 16)),
            Row(
              children: [
                Text(
                  date != null ? DateFormat('dd MMM yyyy').format(date) : 'Select Date',
                  style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.calendar_today, color: Colors.grey),
              ],
            )
          ],
        ),
      ),
    );
  }
}
