import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF0F2F5),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF333333)),
        title: Text(
          'About Us',
          style: GoogleFonts.lato(
            color: const Color(0xFF333333),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildServicesCard(),
          const SizedBox(height: 24),
          _buildContactCard(),
        ],
      ),
    );
  }

  Widget _buildServicesCard() {
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Our Services',
              style: GoogleFonts.lato(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF4B2C82),
              ),
            ),
            const SizedBox(height: 16),
            _buildServiceItem(Icons.monetization_on, 'Daily Thandal'),
            _buildServiceItem(Icons.calendar_view_week, 'Weekly Thandal'),
            _buildServiceItem(Icons.cake, 'Diwali Chit Funds'),
            _buildServiceItem(Icons.business_center, 'Other financial services for business people'),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard() {
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact Us',
              style: GoogleFonts.lato(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF4B2C82),
              ),
            ),
            const SizedBox(height: 16),
            _buildContactHeader('By Phone'),
            _buildContactTile(FontAwesomeIcons.phone, '8608260629', () => _makePhoneCall('8608260629')),
            _buildContactTile(FontAwesomeIcons.phone, '7448605494', () => _makePhoneCall('7448605494')),
            _buildContactTile(FontAwesomeIcons.phone, '8344411641', () => _makePhoneCall('8344411641')),
            _buildContactTile(FontAwesomeIcons.phone, '7449208403', () => _makePhoneCall('7449208403')),
            const Divider(height: 30, thickness: 1, color: Colors.black12),
            _buildContactHeader('By WhatsApp'),
            _buildContactTile(FontAwesomeIcons.whatsapp, '8778422438', () => _openWhatsApp('8778422438')),
            _buildContactTile(FontAwesomeIcons.whatsapp, '8825450896', () => _openWhatsApp('8825450896')),
          ],
        ),
      ),
    );
  }

  Widget _buildContactHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(title, style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black54)),
    );
  }

  Widget _buildServiceItem(IconData icon, String service) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF4B2C82), size: 22),
          const SizedBox(width: 16),
          Expanded(child: Text(service, style: GoogleFonts.lato(fontSize: 16, color: const Color(0xFF333333)))),
        ],
      ),
    );
  }

  ListTile _buildContactTile(IconData icon, String contact, VoidCallback onTap) {
    return ListTile(
      leading: FaIcon(icon, color: const Color(0xFF4B2C82), size: 24),
      title: Text(contact, style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.w500)),
      onTap: onTap,
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black38),
      contentPadding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  Future<void> _openWhatsApp(String phoneNumber) async {
    final Uri launchUri = Uri.parse('https://wa.me/$phoneNumber');
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri, mode: LaunchMode.externalApplication);
    }
  }
}
