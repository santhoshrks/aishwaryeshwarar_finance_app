import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ExportService {
  static Future<void> exportAllData() async {
    final excel = Excel.createExcel();

    final customerSheet = excel['Customers'];
    final loanSheet = excel['Loans'];
    final paymentSheet = excel['Payments'];

    // HEADERS
    customerSheet.appendRow(
        ['Customer ID', 'Name', 'Phone', 'Business']);
    loanSheet.appendRow([
      'Customer ID',
      'Loan ID',
      'Principal',
      'Interest',
      'Balance',
      'Start Date',
      'End Date',
      'Duration'
    ]);
    paymentSheet.appendRow(
        ['Customer ID', 'Loan ID', 'Amount', 'Paid Date']);

    final customers =
    await FirebaseFirestore.instance.collection('customers').get();

    for (final customer in customers.docs) {
      final c = customer.data();

      customerSheet.appendRow([
        customer.id,
        c['name'],
        c['phone'],
        c['business'],
      ]);

      final loans =
      await customer.reference.collection('loans').get();

      for (final loan in loans.docs) {
        final l = loan.data();

        loanSheet.appendRow([
          customer.id,
          l['loanId'],
          l['principal'],
          l['interest'],
          l['balance'],
          (l['startDate'] as Timestamp).toDate().toString(),
          (l['endDate'] as Timestamp).toDate().toString(),
          l['durationDays'],
        ]);

        final payments =
        await loan.reference.collection('payments').get();

        for (final payment in payments.docs) {
          final p = payment.data();

          paymentSheet.appendRow([
            customer.id,
            l['loanId'],
            p['amount'],
            (p['paidAt'] as Timestamp).toDate().toString(),
          ]);
        }
      }
    }

    final dir = await getApplicationDocumentsDirectory();
    final filePath =
        '${dir.path}/finance_backup_${DateTime.now().millisecondsSinceEpoch}.xlsx';

    final file = File(filePath);
    file.writeAsBytesSync(excel.encode()!);

    await Share.shareXFiles(
      [XFile(filePath)],
      text: 'Aishwaryeshwarar Finance Backup',
    );
  }
}
