import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomizeMessagesPage extends StatefulWidget {
  const CustomizeMessagesPage({super.key});

  @override
  State<CustomizeMessagesPage> createState() => _CustomizeMessagesPageState();
}

class _CustomizeMessagesPageState extends State<CustomizeMessagesPage> {
  final _reminderCtrl = TextEditingController();
  final _paymentCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _reminderCtrl.text = prefs.getString('reminderMessage') ?? 'Dear {customerName}, this is a friendly reminder regarding your account. Please check the app for details. Thank you.';
      _paymentCtrl.text = prefs.getString('paymentMessage') ?? 'Dear {customerName}, we have successfully received your payment of ₹{amount}. Thank you.';
    });
  }

  Future<void> _saveMessages() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('reminderMessage', _reminderCtrl.text);
    await prefs.setString('paymentMessage', _paymentCtrl.text);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Messages saved successfully')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Customize Messages', style: GoogleFonts.lato())),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('You can use {customerName} and {amount} as placeholders.', style: GoogleFonts.lato()),
            const SizedBox(height: 24),
            Text('Reminder Message', style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
            TextField(controller: _reminderCtrl, maxLines: 3, decoration: const InputDecoration(border: OutlineInputBorder())),
            const SizedBox(height: 24),
            Text('Payment Confirmation Message', style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
            TextField(controller: _paymentCtrl, maxLines: 3, decoration: const InputDecoration(border: OutlineInputBorder())),
            const SizedBox(height: 32),
            ElevatedButton(onPressed: _saveMessages, child: Text('Save Templates', style: GoogleFonts.lato())),
          ],
        ),
      ),
    );
  }
}
