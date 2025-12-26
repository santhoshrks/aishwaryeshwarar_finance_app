import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreTestPage extends StatelessWidget {
  const FirestoreTestPage({super.key});

  Future<void> addTestData() async {
    await FirebaseFirestore.instance
        .collection('test')
        .add({'name': 'Aishwaryeshwarar Finance', 'status': 'working'});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Firestore Test')),
      body: Center(
        child: ElevatedButton(
          onPressed: addTestData,
          child: const Text('Add Test Data'),
        ),
      ),
    );
  }
}