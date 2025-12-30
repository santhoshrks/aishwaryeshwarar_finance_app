import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PinSetupPage extends StatefulWidget {
  const PinSetupPage({super.key});

  @override
  State<PinSetupPage> createState() => _PinSetupPageState();
}

class _PinSetupPageState extends State<PinSetupPage> {
  final _pinCtrl = TextEditingController();
  final _confirmPinCtrl = TextEditingController();
  final _storage = const FlutterSecureStorage();

  Future<void> _savePin() async {
    if (_pinCtrl.text == _confirmPinCtrl.text) {
      await _storage.write(key: 'pin', value: _pinCtrl.text);
      _navigateToHome();
    } else {
      // Show error message
    }
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set Up PIN')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _pinCtrl,
              decoration: const InputDecoration(labelText: 'Enter PIN'),
              obscureText: true,
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _confirmPinCtrl,
              decoration: const InputDecoration(labelText: 'Confirm PIN'),
              obscureText: true,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _savePin, child: const Text('Save PIN')),
          ],
        ),
      ),
    );
  }
}
