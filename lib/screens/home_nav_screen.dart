import 'package:flutter/material.dart';
import 'dashboard.dart';
import 'sos_booking_screen.dart';
import 'job_cards_screen.dart';
import 'vehicle_history_screen.dart';

class HomeNavScreen extends StatefulWidget {
  const HomeNavScreen({Key? key}) : super(key: key);

  @override
  State<HomeNavScreen> createState() => _HomeNavScreenState();
}

class _HomeNavScreenState extends State<HomeNavScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    SosBookingScreen(),
    JobCardsScreen(),
    VehicleHistoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2A2D3E),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, -4),
            ),
          ],
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            backgroundColor: const Color(0xFF222533),
            selectedItemColor: _currentIndex == 1 ? const Color(0xFFEA580C) : const Color(0xFF3B82F6),
            unselectedItemColor: Colors.grey[500],
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_outlined),
                activeIcon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFE11D48), Color(0xFFEA580C)]),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: const Color(0xFFEA580C).withOpacity(0.4), blurRadius: 6, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: const Icon(Icons.support_agent, color: Colors.white, size: 22),
                ),
                activeIcon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFE11D48), Color(0xFFEA580C)]),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(color: const Color(0xFFEA580C).withOpacity(0.6), blurRadius: 10, offset: const Offset(0, 3)),
                    ],
                  ),
                  child: const Icon(Icons.support_agent, color: Colors.white, size: 24),
                ),
                label: 'SOS 🚨',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.build_circle_outlined),
                activeIcon: Icon(Icons.build_circle),
                label: 'Track Jobs',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.manage_history),
                activeIcon: Icon(Icons.history_edu, color: Color(0xFF3B82F6), size: 26),
                label: 'Vault 📜',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
