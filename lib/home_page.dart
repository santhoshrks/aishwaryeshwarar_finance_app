import 'package:aishwaryeshwarar_finance/about_page.dart';
import 'package:flutter/material.dart';

import 'customer_list_page.dart';
import 'dashboard_page.dart';
import 'today_collection_page.dart';
import 'interest_calculator_page.dart';
import 'backup_restore_page.dart'; // ✅ NEW

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
          const DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4B2C82), Color(0xFF6A4BC7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Text(
              'Aishwaryeshwarar Finance',
              style: TextStyle(
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
          _drawerItem(context, Icons.info, 'About Us', const AboutPage()),
        ],
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: const Color(0xFF4B2C82),
      floating: true,
      pinned: true,
      expandedHeight: 200.0,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Aishwaryeshwarar Finance',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
    return const SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'Welcome Back!',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
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
      leading: Icon(icon, color: Colors.deepPurple),
      title: Text(title),
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
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 14, offset: const Offset(0, 8))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.deepPurple),
            const SizedBox(height: 12),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
