import 'package:aishwaryeshwarar_finance/change_pin_page.dart';
import 'package:aishwaryeshwarar_finance/customize_messages_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';

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
              title: Text('Settings', style: GoogleFonts.lato(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildGlassCard(
                    child: SwitchListTile(
                      title: Text('Enable Biometric Unlock', style: GoogleFonts.lato(color: Colors.white)),
                      value: _biometricsEnabled,
                      onChanged: _toggleBiometrics,
                      secondary: const Icon(Icons.fingerprint, color: Colors.white70),
                       activeColor: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildGlassCard(
                    child: ListTile(
                      leading: const Icon(Icons.pin, color: Colors.white70),
                      title: Text('Change PIN', style: GoogleFonts.lato(color: Colors.white)),
                      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 18),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePinPage())),
                    ),
                  ),
                   const SizedBox(height: 16),
                  _buildGlassCard(
                    child: ListTile(
                      leading: const Icon(Icons.message, color: Colors.white70),
                      title: Text('Customize Messages', style: GoogleFonts.lato(color: Colors.white)),
                      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 18),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomizeMessagesPage())),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: child,
        ),
      ),
    );
  }
}
