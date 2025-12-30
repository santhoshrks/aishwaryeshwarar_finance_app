import 'package:aishwaryeshwarar_finance/about_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'customer_list_page.dart';
import 'dashboard_page.dart';
import 'interest_calculator_page.dart';
import 'backup_restore_page.dart';
import 'today_collection_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  // ================= LOGOUT =================
  Future<void> _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Logout', style: GoogleFonts.lato()),
        content: Text('Are you sure you want to log out?', style: GoogleFonts.lato()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel', style: GoogleFonts.lato()),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Logout', style: GoogleFonts.lato(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await const FlutterSecureStorage().deleteAll();
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: _buildAppBar(),
      drawer: _buildDrawer(context),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildSummaryCard(),
          const SizedBox(height: 24),
          _buildSectionTitle('Quick Actions'),
          const SizedBox(height: 16),
          _buildActionsGrid(context),
        ],
      ),
    );
  }

  // ================= APP BAR =================
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFF0F2F5),
      elevation: 0,
      iconTheme: const IconThemeData(color: Color(0xFF333333)),
      title: Text(
        'Dashboard',
        style: GoogleFonts.lato(
          color: const Color(0xFF333333),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ================= DRAWER =================
  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4B2C82), Color(0xFF6A4BC7)],
              ),
            ),
            child: Text(
              'Aishwaryeshwarar Finance',
              style: GoogleFonts.lato(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _drawerItem(context, Icons.today, 'Today Collection', const TodayCollectionPage()),
          _drawerItem(context, Icons.people, 'Customers & Loans', const CustomerListPage()),
          _drawerItem(context, Icons.bar_chart, 'Dashboard', const DashboardPage()),
          _drawerItem(context, Icons.backup, 'Backup & Restore', const BackupRestorePage()),
          _drawerItem(context, Icons.calculate, 'Interest Calculator', const InterestCalculatorPage()),
          const Divider(),
          _drawerItem(context, Icons.info, 'About Us', const AboutPage()),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Color(0xFF4B2C82)),
            title: Text('Logout', style: GoogleFonts.lato()),
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }

  // ================= HEADER =================
  Widget _buildHeader() {
    return Text(
      'Welcome Back!',
      style: GoogleFonts.lato(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF333333),
      ),
    );
  }

  // ================= SUMMARY =================
  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4B2C82), Color(0xFF6A4BC7)],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildTotalCustomers(),
          _buildTodaysCollection(), // 🔥 FIXED
        ],
      ),
    );
  }

  Widget _buildTotalCustomers() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('customers').snapshots(),
      builder: (context, snapshot) {
        final count = snapshot.data?.docs.length ?? 0;
        return _summaryItem(count.toString(), 'Total Customers');
      },
    );
  }

  // ================= 🔥 FIXED TODAY COLLECTION =================
  Widget _buildTodaysCollection() {
    final today = DateTime.now();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collectionGroup('payments')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _summaryItem('₹0', "Today's Collection");
        }

        double total = 0;

        for (var doc in snapshot.data!.docs) {
          final data = doc.data() as Map<String, dynamic>?;

          if (data == null) continue;

          final amount = (data['amount'] as num?) ?? 0;
          final paidAt = data['paidAt'];

          if (paidAt is Timestamp) {
            final date = paidAt.toDate();
            if (date.year == today.year &&
                date.month == today.month &&
                date.day == today.day) {
              total += amount;
            }
          }
        }

        final formatted = NumberFormat.currency(
          locale: 'en_IN',
          symbol: '₹',
          decimalDigits: 0,
        ).format(total);

        return _summaryItem(formatted, "Today's Collection");
      },
    );
  }

  Widget _summaryItem(String value, String label) {
    return Column(
      children: [
        Text(value,
            style: GoogleFonts.lato(
                fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 4),
        Text(label,
            style: GoogleFonts.lato(fontSize: 14, color: Colors.white70)),
      ],
    );
  }

  // ================= QUICK ACTIONS =================
  Widget _buildActionsGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _mainCard(context, Icons.today, 'Today Collection', const TodayCollectionPage()),
        _mainCard(context, Icons.people, 'Customers & Loans', const CustomerListPage()),
        _mainCard(context, Icons.bar_chart, 'Dashboard', const DashboardPage()),
        _mainCard(context, Icons.calculate, 'Interest Calculator', const InterestCalculatorPage()),
      ],
    );
  }

  // ================= HELPERS =================
  ListTile _drawerItem(BuildContext context, IconData icon, String title, Widget page) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF4B2C82)),
      title: Text(title, style: GoogleFonts.lato()),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      },
    );
  }

  Widget _mainCard(BuildContext context, IconData icon, String title, Widget page) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 12)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: const Color(0xFF4B2C82)),
            const SizedBox(height: 12),
            Text(title, style: GoogleFonts.lato(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title,
        style: GoogleFonts.lato(
            fontSize: 20, fontWeight: FontWeight.bold));
  }
}
