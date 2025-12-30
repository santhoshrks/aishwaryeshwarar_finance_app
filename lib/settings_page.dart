import 'package:aishwaryeshwarar_finance/change_pin_page.dart';
import 'package:aishwaryeshwarar_finance/customize_messages_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _biometricsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadBiometricsPreference();
  }

  Future<void> _loadBiometricsPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _biometricsEnabled = prefs.getBool('biometricsEnabled') ?? true;
    });
  }

  Future<void> _toggleBiometrics(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometricsEnabled', value);
    setState(() {
      _biometricsEnabled = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: Text('Settings', style: GoogleFonts.lato()),
        backgroundColor: const Color(0xFF4B2C82),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSettingsCard(
            children: [
              SwitchListTile(
                title: Text('Enable Biometric Unlock', style: GoogleFonts.lato()),
                value: _biometricsEnabled,
                onChanged: _toggleBiometrics,
                secondary: const Icon(Icons.fingerprint),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.pin),
                title: Text('Change PIN', style: GoogleFonts.lato()),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePinPage())),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSettingsCard(
            children: [
              ListTile(
                leading: const Icon(Icons.message),
                title: Text('Customize Messages', style: GoogleFonts.lato()),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomizeMessagesPage())),
              ),
            ]
          )
        ],
      ),
    );
  }

  Widget _buildSettingsCard({required List<Widget> children}) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(children: children),
    );
  }
}
