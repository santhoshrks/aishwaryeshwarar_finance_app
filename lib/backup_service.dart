import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class BackupService {
  static Future<File> createBackup() async {
    final firestore = FirebaseFirestore.instance;

    final customersSnapshot =
    await firestore.collection('customers').get();

    List<Map<String, dynamic>> customersData = [];

    for (final customer in customersSnapshot.docs) {
      final customerMap = customer.data();
      customerMap['id'] = customer.id;

      final loansSnapshot =
      await customer.reference.collection('loans').get();

      List<Map<String, dynamic>> loansData = [];

      for (final loan in loansSnapshot.docs) {
        final loanMap = loan.data();
        loanMap['id'] = loan.id;

        final paymentsSnapshot =
        await loan.reference.collection('payments').get();

        loanMap['payments'] =
            paymentsSnapshot.docs.map((e) => e.data()).toList();

        loansData.add(loanMap);
      }

      customerMap['loans'] = loansData;
      customersData.add(customerMap);
    }

    final jsonString = jsonEncode(customersData);

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/finance_backup.json');

    return file.writeAsString(jsonString);
  }
}
