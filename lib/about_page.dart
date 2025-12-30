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
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: const Color(0xFF4B2C82),
            floating: true,
            pinned: true,
            expandedHeight: 150.0,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'About Us',
                style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF4B2C82), Color(0xFF6A4BC7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildServicesCard(),
                  const SizedBox(height: 20),
                  _buildContactCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesCard() {
    return Card(
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
            const SizedBox(height: 12),
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
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
            const SizedBox(height: 12),
            _buildContactHeader('By Phone'),
            _buildContactTile(FontAwesomeIcons.phone, '8608260629', () => _makePhoneCall('8608260629')),
            _buildContactTile(FontAwesomeIcons.phone, '7448605494', () => _makePhoneCall('7448605494')),
            _buildContactTile(FontAwesomeIcons.phone, '8344411641', () => _makePhoneCall('8344411641')),
            _buildContactTile(FontAwesomeIcons.phone, '7449208403', () => _makePhoneCall('7449208403')),
            const Divider(height: 30),
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
          Icon(icon, color: const Color(0xFF4B2C82), size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(service, style: GoogleFonts.lato(fontSize: 16))),
        ],
      ),
    );
  }

  ListTile _buildContactTile(IconData icon, String contact, VoidCallback onTap) {
    return ListTile(
      leading: FaIcon(icon, color: const Color(0xFF4B2C82), size: 22),
      title: Text(contact, style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.w500)),
      onTap: onTap,
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black38),
      contentPadding: EdgeInsets.zero,
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
