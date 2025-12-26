import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

class RestoreService {
  static Future<void> restoreFromFile(File file) async {
    final firestore = FirebaseFirestore.instance;

    final jsonString = await file.readAsString();
    final List customersData = jsonDecode(jsonString);

    for (final customer in customersData) {
      final customerMap = Map<String, dynamic>.from(customer);
      final loans = customerMap.remove('loans');

      final customerRef =
      await firestore.collection('customers').add(customerMap);

      if (loans != null) {
        for (final loan in loans) {
          final loanMap = Map<String, dynamic>.from(loan);
          final payments = loanMap.remove('payments');

          final loanRef =
          await customerRef.collection('loans').add(loanMap);

          if (payments != null) {
            for (final payment in payments) {
              await loanRef
                  .collection('payments')
                  .add(Map<String, dynamic>.from(payment));
            }
          }
        }
      }
    }
  }
}
