import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/role_switcher_modal.dart';
import 'dashboard.dart';
import 'sos_booking_screen.dart';
import 'job_cards_screen.dart';
import 'vehicle_history_screen.dart';
import 'mechanic_hub_screen.dart';
import 'advisor_hub_screen.dart';

class HomeNavScreen extends StatefulWidget {
  const HomeNavScreen({Key? key}) : super(key: key);

  @override
  State<HomeNavScreen> createState() => _HomeNavScreenState();
}

class _HomeNavScreenState extends State<HomeNavScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  // Generate role-specific navigation menus and screen workflows
  List<Map<String, dynamic>> get _currentNavigationItems {
    final role = ApiService.activeUserRole;
    if (role == 'Mechanic') {
      return [
        {'title': 'Lifts & Staff', 'icon': Icons.engineering_outlined, 'activeIcon': Icons.engineering, 'screen': const MechanicHubScreen(), 'color': const Color(0xFFE11D48)},
        {'title': 'Live Jobs', 'icon': Icons.build_circle_outlined, 'activeIcon': Icons.build_circle, 'screen': const JobCardsScreen(), 'color': const Color(0xFF3B82F6)},
        {'title': 'Dashboard', 'icon': Icons.dashboard_outlined, 'activeIcon': Icons.dashboard, 'screen': const DashboardScreen(), 'color': const Color(0xFF10B981)},
        {'title': 'Vault 📜', 'icon': Icons.manage_history, 'activeIcon': Icons.history_edu, 'screen': const VehicleHistoryScreen(), 'color': const Color(0xFFF59E0B)},
      ];
    } else if (role == 'Advisor') {
      return [
        {'title': 'Advisor & Stock', 'icon': Icons.inventory_2_outlined, 'activeIcon': Icons.inventory_2, 'screen': const AdvisorHubScreen(), 'color': const Color(0xFF10B981)},
        {'title': 'Live Jobs', 'icon': Icons.build_circle_outlined, 'activeIcon': Icons.build_circle, 'screen': const JobCardsScreen(), 'color': const Color(0xFF3B82F6)},
        {'title': 'Dashboard', 'icon': Icons.dashboard_outlined, 'activeIcon': Icons.dashboard, 'screen': const DashboardScreen(), 'color': const Color(0xFFE11D48)},
        {'title': 'Vault 📜', 'icon': Icons.manage_history, 'activeIcon': Icons.history_edu, 'screen': const VehicleHistoryScreen(), 'color': const Color(0xFFF59E0B)},
      ];
    } else if (role == 'Customer') {
      return [
        {'title': 'SOS 🚨', 'icon': Icons.support_agent, 'activeIcon': Icons.support_agent, 'screen': const SosBookingScreen(), 'color': const Color(0xFFEA580C), 'isHighlight': true},
        {'title': 'Vault 📜', 'icon': Icons.manage_history, 'activeIcon': Icons.history_edu, 'screen': const VehicleHistoryScreen(), 'color': const Color(0xFF3B82F6)},
        {'title': 'Track Repair', 'icon': Icons.build_circle_outlined, 'activeIcon': Icons.build_circle, 'screen': const JobCardsScreen(), 'color': const Color(0xFF10B981)},
        {'title': 'Overview', 'icon': Icons.dashboard_outlined, 'activeIcon': Icons.dashboard, 'screen': const DashboardScreen(), 'color': const Color(0xFF6366F1)},
      ];
    } else {
      // Default Executive Admin - Full access across 5 main items
      return [
        {'title': 'Dashboard', 'icon': Icons.dashboard_outlined, 'activeIcon': Icons.dashboard, 'screen': const DashboardScreen(), 'color': const Color(0xFF3B82F6)},
        {'title': 'SOS 🚨', 'icon': Icons.support_agent, 'activeIcon': Icons.support_agent, 'screen': const SosBookingScreen(), 'color': const Color(0xFFEA580C), 'isHighlight': true},
        {'title': 'Lifts & Bays', 'icon': Icons.engineering_outlined, 'activeIcon': Icons.engineering, 'screen': const MechanicHubScreen(), 'color': const Color(0xFFE11D48)},
        {'title': 'Stock & Advisor', 'icon': Icons.inventory_2_outlined, 'activeIcon': Icons.inventory_2, 'screen': const AdvisorHubScreen(), 'color': const Color(0xFF10B981)},
        {'title': 'Vault 📜', 'icon': Icons.manage_history, 'activeIcon': Icons.history_edu, 'screen': const VehicleHistoryScreen(), 'color': const Color(0xFFF59E0B)},
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final navItems = _currentNavigationItems;
    if (_currentIndex >= navItems.length) {
      _currentIndex = 0;
    }

    final currentRole = ApiService.activeUserRole;
    Color roleBadgeColor;
    if (currentRole == 'Mechanic') roleBadgeColor = const Color(0xFFE11D48);
    else if (currentRole == 'Advisor') roleBadgeColor = const Color(0xFF10B981);
    else if (currentRole == 'Customer') roleBadgeColor = const Color(0xFFF59E0B);
    else roleBadgeColor = const Color(0xFF3B82F6);

    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: navItems.map<Widget>((item) => item['screen'] as Widget).toList(),
          ),
          // Ultra Modern Floating Persona Badge inside SafeArea
          Positioned(
            bottom: 12,
            right: 16,
            child: FloatingActionButton.extended(
              onPressed: () => showRoleSwitcherModal(context, onRoleSwitched: () => setState(() {})),
              icon: const Icon(Icons.person_pin, color: Colors.white, size: 20),
              label: Text('Role: $currentRole', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12)),
              backgroundColor: roleBadgeColor.withOpacity(0.9),
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22), side: BorderSide(color: Colors.white.withOpacity(0.3))),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2A2D3E),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 18,
              offset: const Offset(0, -5),
            ),
          ],
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.08))),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            backgroundColor: const Color(0xFF222533),
            selectedItemColor: navItems[_currentIndex]['color'] as Color? ?? const Color(0xFF3B82F6),
            unselectedItemColor: Colors.grey[500],
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 10),
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            items: navItems.map<BottomNavigationBarItem>((item) {
              final isHighlight = item['isHighlight'] == true;
              final color = item['color'] as Color? ?? const Color(0xFF3B82F6);

              if (isHighlight) {
                return BottomNavigationBarItem(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFE11D48), Color(0xFFEA580C)]),
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: const Color(0xFFEA580C).withOpacity(0.4), blurRadius: 6, offset: const Offset(0, 2))],
                    ),
                    child: Icon(item['icon'] as IconData, color: Colors.white, size: 20),
                  ),
                  activeIcon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFE11D48), Color(0xFFEA580C)]),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [BoxShadow(color: const Color(0xFFEA580C).withOpacity(0.7), blurRadius: 10, offset: const Offset(0, 3))],
                    ),
                    child: Icon(item['activeIcon'] as IconData, color: Colors.white, size: 22),
                  ),
                  label: item['title'] as String,
                );
              }

              return BottomNavigationBarItem(
                icon: Icon(item['icon'] as IconData, size: 22),
                activeIcon: Icon(item['activeIcon'] as IconData, color: color, size: 26),
                label: item['title'] as String,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
