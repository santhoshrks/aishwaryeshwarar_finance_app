import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';

class ChangePinPage extends StatefulWidget {
  const ChangePinPage({super.key});

  @override
  State<ChangePinPage> createState() => _ChangePinPageState();
}

class _ChangePinPageState extends State<ChangePinPage> {
  final _oldPinCtrl = TextEditingController();
  final _newPinCtrl = TextEditingController();
  final _confirmPinCtrl = TextEditingController();
  final _storage = const FlutterSecureStorage();

  Future<void> _changePin() async {
    final storedPin = await _storage.read(key: 'pin');

    if (storedPin != _oldPinCtrl.text) {
      _showError('Incorrect old PIN');
      return;
    }

    if (_newPinCtrl.text != _confirmPinCtrl.text) {
      _showError('New PINs do not match');
      return;
    }

    await _storage.write(key: 'pin', value: _newPinCtrl.text);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PIN changed successfully')));
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Change PIN', style: GoogleFonts.lato())),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _oldPinCtrl, decoration: const InputDecoration(labelText: 'Old PIN'), obscureText: true, keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            TextField(controller: _newPinCtrl, decoration: const InputDecoration(labelText: 'New PIN'), obscureText: true, keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            TextField(controller: _confirmPinCtrl, decoration: const InputDecoration(labelText: 'Confirm New PIN'), obscureText: true, keyboardType: TextInputType.number),
            const SizedBox(height: 32),
            ElevatedButton(onPressed: _changePin, child: Text('Save Changes', style: GoogleFonts.lato())),
          ],
        ),
      ),
    );
  }
}
