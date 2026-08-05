import 'package:flutter/material.dart';
import '../services/api_service.dart';

void showRoleSwitcherModal(BuildContext context, {required VoidCallback onRoleSwitched}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) => _RoleSwitcherSheet(onRoleSwitched: onRoleSwitched),
  );
}

class _RoleSwitcherSheet extends StatelessWidget {
  final VoidCallback onRoleSwitched;
  const _RoleSwitcherSheet({Key? key, required this.onRoleSwitched}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final roles = [
      {
        'role': 'Admin',
        'title': 'Executive Admin Command 👑',
        'desc': 'Full 360° enterprise control: Financial analytics, hydraulic bay lifts, warehouse stock alerts & staff efficiency.',
        'color': const Color(0xFF3B82F6),
        'icon': Icons.admin_panel_settings,
      },
      {
        'role': 'Mechanic',
        'title': 'Workshop Technician / Mechanic 🔧',
        'desc': 'Touchscreen hydraulic lift bay toggles, digital repair work orders, and real-time 15% labor commission earnings.',
        'color': const Color(0xFFE11D48),
        'icon': Icons.handyman,
      },
      {
        'role': 'Advisor',
        'title': 'Service Advisor & Warehouse Mgr 📦',
        'desc': 'Low-stock parts inventory alarms, workshop quotations converter, and automated WhatsApp retention broadcasts.',
        'color': const Color(0xFF10B981),
        'icon': Icons.support_agent,
      },
      {
        'role': 'Customer',
        'title': 'Customer / Roadside Vehicle Owner 🚗',
        'desc': 'Instant 24/7 GPS emergency roadside SOS breakdown dispatch & Digital Medical Vault timeline logbooks.',
        'color': const Color(0xFFF59E0B),
        'icon': Icons.directions_car,
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C),
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28)),
        border: Border.all(color: Colors.white.withOpacity(0.12), width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.7), blurRadius: 30, offset: const Offset(0, -5))],
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 34),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 46,
              height: 5,
              decoration: BoxDecoration(color: Colors.grey[600], borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: const Color(0xFF3B82F6).withOpacity(0.2), shape: BoxShape.circle),
                child: const Icon(Icons.manage_accounts, color: Color(0xFF3B82F6), size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Switch User Persona Mode', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900, color: Colors.white)),
                    Text('Select operational role to test customized UI workflows', style: TextStyle(fontSize: 12, color: Colors.grey[400], fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          ...roles.map((item) {
            final roleName = item['role'] as String;
            final isSelected = ApiService.activeUserRole == roleName;
            final color = item['color'] as Color;

            return InkWell(
              onTap: () async {
                await ApiService.switchUserRole(roleName);
                if (context.mounted) {
                  Navigator.of(context).pop();
                  onRoleSwitched();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(item['icon'] as IconData, color: Colors.white, size: 22),
                          const SizedBox(width: 12),
                          Expanded(child: Text('Persona Switched to: $roleName Mode!', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14))),
                        ],
                      ),
                      backgroundColor: color,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                }
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isSelected ? color.withOpacity(0.18) : const Color(0xFF252836),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isSelected ? color : Colors.white.withOpacity(0.06), width: isSelected ? 2.0 : 1.0),
                  boxShadow: isSelected ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))] : [],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(16)),
                      child: Icon(item['icon'] as IconData, color: color, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(item['title'] as String, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: isSelected ? Colors.white : Colors.grey[200])),
                              if (isSelected)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
                                  child: const Text('ACTIVE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10)),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(item['desc'] as String, style: TextStyle(fontSize: 12, color: Colors.grey[400], height: 1.35, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
