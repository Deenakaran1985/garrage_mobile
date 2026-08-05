import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/server_config_modal.dart';

class MechanicHubScreen extends StatefulWidget {
  const MechanicHubScreen({Key? key}) : super(key: key);

  @override
  State<MechanicHubScreen> createState() => _MechanicHubScreenState();
}

class _MechanicHubScreenState extends State<MechanicHubScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> bays = [];
  Map<String, dynamic>? baysSummary;
  List<dynamic> mechanics = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> fetchData() async {
    setState(() => isLoading = true);
    final bayData = await ApiService.getWorkshopBays();
    final mechData = await ApiService.getMechanicEfficiency();

    if (mounted) {
      setState(() {
        if (bayData != null) {
          bays = bayData['data'] ?? [];
          baysSummary = bayData['summary'];
        }
        mechanics = mechData;
        isLoading = false;
      });
    }
  }

  Future<void> _handleToggleBay(int id, String currentStatus) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🔄 Updating Bay #$id occupancy...', style: const TextStyle(fontWeight: FontWeight.bold)),
        duration: const Duration(seconds: 1),
        backgroundColor: const Color(0xFF3B82F6),
        behavior: SnackBarBehavior.floating,
      ),
    );
    await ApiService.toggleWorkshopBay(id);
    await fetchData();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'vacant':
        return const Color(0xFF10B981);
      case 'occupied':
        return const Color(0xFFE11D48);
      case 'maintenance':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF6366F1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Technician Command & Bays', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: Colors.white)),
            Text('Hydraulic Lifts & 15% Labor Commission Tracker', style: TextStyle(fontSize: 11, color: Colors.blueAccent[100], fontWeight: FontWeight.w600)),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.router, color: Colors.greenAccent),
            tooltip: 'Configure Server Host Address',
            onPressed: () => showServerConfigModal(context, onConfigUpdated: () {
              setState(() {});
              fetchData();
            }),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            onPressed: fetchData,
            tooltip: 'Refresh Bays & Stats',
          ),
          const SizedBox(width: 6),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF3B82F6),
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey[400],
          labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
          tabs: const [
            Tab(icon: Icon(Icons.engineering_outlined), text: 'Hydraulic Lifts & Bays'),
            Tab(icon: Icon(Icons.emoji_events_outlined), text: 'Mechanic Leaderboard'),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6)))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildBaysView(),
                _buildLeaderboardView(),
              ],
            ),
    );
  }

  Widget _buildBaysView() {
    return RefreshIndicator(
      onRefresh: fetchData,
      color: const Color(0xFF3B82F6),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (baysSummary != null) ...[
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E3A8A), Color(0xFF1D4ED8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: const Color(0xFF3B82F6).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 5))],
                border: Border.all(color: Colors.white.withOpacity(0.15)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
                    child: const Icon(Icons.build_circle, size: 32, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${baysSummary!['vacant_bays'] ?? 0} of ${baysSummary!['total_bays'] ?? 0} Lifts Vacant',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          baysSummary!['message'] ?? 'Touch any bay below to dynamically change occupancy.',
                          style: TextStyle(fontSize: 12, color: Colors.blue[100], fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
          const Text('LIVE SERVICE LIFT & BAY DASHBOARD', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.0)),
          const SizedBox(height: 10),
          ...bays.map((bay) {
            final status = bay['status'] ?? 'Vacant';
            final statusColor = _getStatusColor(status);
            final occupancy = bay['occupancy'];

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF222533),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: statusColor.withOpacity(0.35), width: 1.5),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(color: statusColor.withOpacity(0.15), borderRadius: BorderRadius.circular(10), border: Border.all(color: statusColor.withOpacity(0.5))),
                              child: Text(bay['code'] ?? 'BAY', style: TextStyle(fontWeight: FontWeight.w900, color: statusColor, fontSize: 12)),
                            ),
                            const SizedBox(width: 12),
                            Text(bay['name'] ?? 'Hydraulic Lift', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(12)),
                          child: Text(status.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11)),
                        ),
                      ],
                    ),
                    if (occupancy != null) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.06))),
                        child: Row(
                          children: [
                            const Icon(Icons.directions_car, color: Colors.redAccent, size: 22),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Active Job: ${occupancy['job_card_id']} • ${occupancy['vehicle_reg']}', style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 13)),
                                  Text('Technician: ${occupancy['mechanic']} (${occupancy['vehicle_make_model'] ?? 'Vehicle'})', style: TextStyle(color: Colors.grey[400], fontSize: 11)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else if (bay['notes'] != null && bay['notes'].toString().isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text('Specification: ${bay['notes']}', style: TextStyle(color: Colors.grey[400], fontStyle: FontStyle.italic, fontSize: 12)),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _handleToggleBay(bay['id'], status),
                          icon: const Icon(Icons.swap_horizontal_circle, size: 18),
                          label: Text(status == 'Vacant' ? 'Assign & Occupy Lift' : (status == 'Occupied' ? 'Set to Maintenance' : 'Release to Vacant'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: status == 'Vacant' ? const Color(0xFFE11D48) : const Color(0xFF10B981),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            elevation: 4,
                          ),
                        ),
                      ],
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

  Widget _buildLeaderboardView() {
    return RefreshIndicator(
      onRefresh: fetchData,
      color: const Color(0xFF3B82F6),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF374151), Color(0xFF111827)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.5), width: 1.5),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 12, offset: const Offset(0, 6))],
            ),
            child: Row(
              children: [
                const Icon(Icons.workspace_premium, size: 36, color: Color(0xFFF59E0B)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Technician Efficiency & Incentives', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Colors.white)),
                      const SizedBox(height: 4),
                      Text('Mechanics earn a standardized 15% labor commission on completed repair job cards.', style: TextStyle(fontSize: 12, color: Colors.grey[300], height: 1.3)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('WORKSHOP EFFICIENCY LEADERBOARD', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.0)),
          const SizedBox(height: 10),
          ...mechanics.asMap().entries.map((entry) {
            final index = entry.key + 1;
            final m = entry.value;
            final commission = (m['labor_commission_earned'] as num? ?? 0.0).toStringAsFixed(0);
            final efficiency = m['efficiency_rate'] ?? 95;

            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF222533),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: index == 1 ? const Color(0xFFF59E0B).withOpacity(0.6) : Colors.white.withOpacity(0.06)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))],
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: index == 1 ? const Color(0xFFF59E0B) : (index == 2 ? Colors.grey[500] : const Color(0xFF3B82F6).withOpacity(0.2)),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text('#$index', style: TextStyle(fontWeight: FontWeight.w900, color: index <= 2 ? Colors.white : const Color(0xFF3B82F6), fontSize: 14)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(m['name'] ?? 'Mechanic', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Colors.white)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text('Jobs: ${m['completed_jobs'] ?? 0}/${m['total_assigned_jobs'] ?? 0}', style: TextStyle(fontSize: 12, color: Colors.grey[400], fontWeight: FontWeight.w600)),
                            const SizedBox(width: 10),
                            Text('Efficiency: $efficiency%', style: const TextStyle(fontSize: 12, color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('15% COMMISSION', style: TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                      const SizedBox(height: 2),
                      Text('₹$commission', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF10B981))),
                      const SizedBox(height: 2),
                      Text(m['status'] ?? 'Active', style: TextStyle(fontSize: 10, color: Colors.blueAccent[100], fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
