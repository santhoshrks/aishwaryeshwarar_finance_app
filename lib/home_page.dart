import 'package:aishwaryeshwarar_finance/about_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';

import 'customer_list_page.dart';
import 'dashboard_page.dart';
import 'interest_calculator_page.dart';
import 'backup_restore_page.dart';
import 'today_collection_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      drawer: _buildDrawer(context),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          _buildHeader(),
          _buildActionsGrid(context),
        ],
      ),
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4B2C82), Color(0xFF6A4BC7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
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
            title: Text('Logout', style: GoogleFonts.lato(fontSize: 16)),
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: const Color(0xFF4B2C82),
      floating: true,
      pinned: true,
      expandedHeight: 180.0,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Aishwaryeshwarar Finance',
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
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildHeader() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome Back!',
              style: GoogleFonts.lato(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Here are your quick actions',
              style: GoogleFonts.lato(
                fontSize: 18,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverPadding _buildActionsGrid(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.all(16.0),
      sliver: SliverGrid.count(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _mainCard(context, icon: Icons.today, title: 'Today Collection', page: const TodayCollectionPage()),
          _mainCard(context, icon: Icons.people, title: 'Customers & Loans', page: const CustomerListPage()),
          _mainCard(context, icon: Icons.bar_chart, title: 'Dashboard', page: const DashboardPage()),
          _mainCard(context, icon: Icons.calculate, title: 'Interest Calculator', page: const InterestCalculatorPage()),
        ],
      ),
    );
  }

  ListTile _drawerItem(BuildContext context, IconData icon, String title, Widget page) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF4B2C82)),
      title: Text(title, style: GoogleFonts.lato(fontSize: 16)),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      },
    );
  }

  Widget _mainCard(BuildContext context, {required IconData icon, required String title, required Widget page}) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 45, color: const Color(0xFF4B2C82)),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF333333),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
