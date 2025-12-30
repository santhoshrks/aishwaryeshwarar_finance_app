import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'dart:ui';

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
      final paymentsSnapshot = await FirebaseFirestore.instance.collectionGroup('payments').get();

      final excel = Excel.createExcel();
      final Sheet sheet = excel['Payments'];

      sheet.appendRow(['Date', 'Customer Name', 'Loan ID', 'Amount', 'Note']);

      for (var doc in paymentsSnapshot.docs) {
        final data = doc.data();
        
        //  🔥 CRITICAL BUG FIX: Safely handle missing or invalid 'paidAt' fields.
        if (data['paidAt'] == null || data['paidAt'] is! Timestamp) {
          continue; // Skip this record if the date is invalid.
        }

        final paidAt = (data['paidAt'] as Timestamp).toDate();

        if ((paidAt.isAfter(_startDate!) || paidAt.isAtSameMomentAs(_startDate!)) && paidAt.isBefore(_endDate!)) {
           sheet.appendRow([
            DateFormat('dd-MM-yyyy').format(paidAt),
            data['customerName'] ?? 'N/A',
            data['loanIdString'] ?? 'N/A',
            data['amount'] ?? 0,
            data['note'] ?? '',
          ]);
        }
      }

      final Directory? directory = await getExternalStorageDirectory();
      if (directory == null) {
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
              title: Text('Export Reports', style: GoogleFonts.lato(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select a date range to export payment data to an Excel file.',
                      style: GoogleFonts.lato(fontSize: 16, color: Colors.white70),
                    ),
                    const SizedBox(height: 32),
                    _buildDatePicker(context, 'Start Date', _startDate, () => _selectDate(context, true)),
                    const SizedBox(height: 16),
                    _buildDatePicker(context, 'End Date', _endDate, () => _selectDate(context, false)),
                    const Spacer(),
                    if (_isExporting)
                      const Center(child: CircularProgressIndicator(color: Colors.white))
                    else
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                           style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.secondary, foregroundColor: Colors.black),
                          icon: const Icon(Icons.download_for_offline),
                          label: Text('Export to Excel', style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 18)),
                          onPressed: _exportToExcel,
                        ),
                      ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context, String title, DateTime? date, VoidCallback onTap) {
    return ClipRRect(
       borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
             border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: ListTile(
            onTap: onTap,
            title: Text(title, style: GoogleFonts.lato(color: Colors.white70)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  date != null ? DateFormat('dd MMM yyyy').format(date) : 'Select Date',
                  style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.calendar_today, color: Colors.white70),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
