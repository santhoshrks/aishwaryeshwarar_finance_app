import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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

      // ===================== DRAWER =====================
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4B2C82), Color(0xFF6A4BC7)],
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

            _drawerItem(
              context,
              Icons.today,
              'Today Collection',
              const TodayCollectionPage(),
            ),
            _drawerItem(
              context,
              Icons.people,
              'Customers & Loans',
              const CustomerListPage(),
            ),
            _drawerItem(
              context,
              Icons.bar_chart,
              'Dashboard',
              const DashboardPage(),
            ),

            // 🔐 BACKUP & RESTORE (NEW)
            _drawerItem(
              context,
              Icons.backup,
              'Backup & Restore',
              const BackupRestorePage(),
            ),

            // 🧮 INTEREST CALCULATOR
            _drawerItem(
              context,
              Icons.calculate,
              'Interest Calculator',
              const InterestCalculatorPage(),
            ),
          ],
        ),
      ),

      // ===================== BODY =====================
      body: SingleChildScrollView(
        child: Column(
          children: [

            // =================== PREMIUM HEADER ===================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 40, 16, 40),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF4B2C82),
                    Color(0xFF6A4BC7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // 🍔 HAMBURGER ICON
                  Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(
                        Icons.menu,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Aishwaryeshwarar',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Finance',
                    style: TextStyle(
                      color: Color(0xFFFFD369),
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Private Finance Management',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            // =================== CONTACT CARD ===================
            Transform.translate(
              offset: const Offset(0, -30),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  elevation: 14,
                  shadowColor: Colors.black26,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Contact',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 10),
                        _ContactRow(
                          icon: Icons.call,
                          text: '+91 74486 05494, 83444 11641',
                        ),
                        _ContactRow(
                          icon: FontAwesomeIcons.whatsapp,
                          text: '+91 87784 22438, 98657 41954',
                        ),
                        _ContactRow(
                          icon: Icons.location_on,
                          text: 'Kattampoondi, Tiruvannamalai',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // =================== MAIN ACTION AREA ===================
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _mainCard(
                    context,
                    icon: Icons.today,
                    title: 'Today Collection',
                    page: const TodayCollectionPage(),
                  ),
                  _mainCard(
                    context,
                    icon: Icons.people,
                    title: 'Customers & Loans',
                    page: const CustomerListPage(),
                  ),
                  _mainCard(
                    context,
                    icon: Icons.bar_chart,
                    title: 'Dashboard',
                    page: const DashboardPage(),
                  ),
                  _mainCard(
                    context,
                    icon: Icons.calculate,
                    title: 'Interest Calculator',
                    page: const InterestCalculatorPage(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= DRAWER ITEM =================
  static Widget _drawerItem(
      BuildContext context,
      IconData icon,
      String title,
      Widget page,
      ) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepPurple),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => page),
        );
      },
    );
  }

  // ================= MAIN ACTION CARD =================
  static Widget _mainCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required Widget page,
      }) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => page),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
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
        child: Row(
          children: [
            Icon(icon, size: 30, color: Colors.deepPurple),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}

// ================= CONTACT ROW =================
class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ContactRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.deepPurple),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
