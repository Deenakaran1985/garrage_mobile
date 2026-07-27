import 'package:flutter/material.dart';
import '../services/api_service.dart';

class VehicleHistoryScreen extends StatefulWidget {
  const VehicleHistoryScreen({Key? key}) : super(key: key);

  @override
  State<VehicleHistoryScreen> createState() => _VehicleHistoryScreenState();
}

class _VehicleHistoryScreenState extends State<VehicleHistoryScreen> {
  final TextEditingController _searchController = TextEditingController(text: 'REG-0001');
  bool isLoading = false;
  Map<String, dynamic>? resultData;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _searchVehicle();
  }

  Future<void> _searchVehicle() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      isLoading = true;
      errorMessage = '';
      resultData = null;
    });

    final data = await ApiService.getVehicleHistory(query);
    setState(() {
      isLoading = false;
      if (data != null && data['status'] == 'success') {
        resultData = data;
      } else {
        errorMessage = 'No service history records found for "$query". Verify your registration plate or mobile number.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final vehicle = resultData != null ? resultData!['vehicle'] : null;
    final List<dynamic> timeline = resultData != null && resultData!['timeline'] != null
        ? resultData!['timeline']
        : [];

    return Scaffold(
      backgroundColor: const Color(0xFF1B1B26),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // App Header & Search Banner
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6366F1), Color(0xFF3B82F6)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6366F1).withOpacity(0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.manage_history, color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Digital Vehicle Vault',
                                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5),
                              ),
                              Text(
                                'Lifetime service history, warranty parts & repairs',
                                style: TextStyle(fontSize: 13, color: Colors.grey[400]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    // Search Bar
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4)),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                      child: Row(
                        children: [
                          const SizedBox(width: 12),
                          Icon(Icons.directions_car, color: Colors.amber[400], size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                              decoration: InputDecoration(
                                hintText: 'Enter Reg Plate (e.g. REG-0001) or Phone...',
                                hintStyle: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.normal, fontSize: 13),
                                border: InputBorder.none,
                              ),
                              onSubmitted: (_) => _searchVehicle(),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: _searchVehicle,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3B82F6),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                              elevation: 4,
                            ),
                            child: const Text('Search 🔍', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Loading Indicator
            if (isLoading)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(color: Color(0xFF3B82F6)),
                      const SizedBox(height: 16),
                      Text('Retrieving historical workshop audit records...', style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.w600, fontSize: 13)),
                    ],
                  ),
                ),
              ),

            // Error or Empty Result Message
            if (!isLoading && errorMessage.isNotEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 36),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.document_scanner_outlined, size: 70, color: Colors.grey[600]),
                        const SizedBox(height: 16),
                        const Text('No Record Vault Found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 8),
                        Text(
                          errorMessage,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[400], fontSize: 13, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Vehicle Overview Card
            if (!isLoading && vehicle != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [const Color(0xFF3B82F6).withOpacity(0.85), const Color(0xFF4F46E5).withOpacity(0.85)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                      boxShadow: [
                        BoxShadow(color: const Color(0xFF4F46E5).withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 6)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.amber[400]!.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.amber[400]!, width: 1.2),
                              ),
                              child: Text(
                                vehicle['registration'] ?? 'REG',
                                style: const TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.5, fontFamily: 'monospace'),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                              child: Text('${timeline.length} Historic Visits ✓', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          vehicle['make_model'] ?? 'Vehicle Model',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Owner: ${vehicle['owner']} • Mileage: ${vehicle['mileage']}',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.indigo[100]),
                        ),
                        const SizedBox(height: 18),
                        Divider(color: Colors.white.withOpacity(0.2), height: 1),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Lifetime Repair Investment:', style: TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w600)),
                            Text(
                              '₹${vehicle['total_spent']?.toString() ?? '0.00'}',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Chronological Repair Timeline List Header
            if (!isLoading && vehicle != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 24, 22, 10),
                  child: Row(
                    children: [
                      Icon(Icons.timeline, color: Colors.blue[400], size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Chronological Workshop Repairs',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.5),
                      ),
                    ],
                  ),
                ),
              ),

            // Timeline Items
            if (!isLoading && timeline.isNotEmpty)
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = timeline[index];
                    final bool isDone = item['status'] == 'Completed' || item['status'] == 'Ready for Delivery';

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: Colors.white.withOpacity(0.08)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(isDone ? Icons.check_circle : Icons.handyman, color: isDone ? Colors.green[400] : Colors.amber[400], size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      item['code'] ?? '#JC',
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.blueAccent, fontFamily: 'monospace'),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: (isDone ? Colors.green : Colors.amber).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: (isDone ? Colors.greenAccent : Colors.amberAccent).withOpacity(0.4)),
                                  ),
                                  child: Text(
                                    item['status'] ?? 'Active',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDone ? Colors.green[300] : Colors.amber[300]),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Serviced on ${item['date']} by Tech: ${item['mechanic']}',
                              style: TextStyle(fontSize: 12, color: Colors.grey[400], fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('DIAGNOSIS / WORK ORDER:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[500], letterSpacing: 0.5)),
                                  const SizedBox(height: 4),
                                  Text(
                                    item['reported_issues'] ?? 'Standard servicing.',
                                    style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Installed Materials & Services Pills
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                ...(item['services'] as List<dynamic>? ?? []).map((s) => Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
                                      ),
                                      child: Text('🛠️ $s', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blue[300])),
                                    )),
                                ...(item['materials'] as List<dynamic>? ?? []).map((m) => Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: Colors.orangeAccent.withOpacity(0.3)),
                                      ),
                                      child: Text('⚙️ $m', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.orange[300])),
                                    )),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Divider(color: Colors.white.withOpacity(0.08), height: 1),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Service Bill Value:', style: TextStyle(fontSize: 12, color: Colors.grey[400])),
                                Text('₹${item['cost']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF10B981))),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: timeline.length,
                ),
              ),

            // Bottom Spacing
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }
}
