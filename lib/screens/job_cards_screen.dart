import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/server_config_modal.dart';

class JobCardsScreen extends StatefulWidget {
  const JobCardsScreen({Key? key}) : super(key: key);

  @override
  State<JobCardsScreen> createState() => _JobCardsScreenState();
}

class _JobCardsScreenState extends State<JobCardsScreen> {
  List<dynamic> jobCards = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchJobCards();
  }

  Future<void> fetchJobCards() async {
    setState(() => isLoading = true);
    final data = await ApiService.getJobCards();
    setState(() {
      jobCards = data;
      isLoading = false;
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'diagnosing':
        return Colors.amberAccent;
      case 'in repair':
        return Colors.blueAccent;
      case 'pending parts':
        return Colors.orangeAccent;
      case 'completed':
      case 'delivered':
        return Colors.greenAccent;
      default:
        return Colors.pinkAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Repair Monitor', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.router, color: Colors.greenAccent),
            tooltip: 'Configure Server Host Address',
            onPressed: () => showServerConfigModal(context, onConfigUpdated: () {
              setState(() {});
              fetchJobCards();
            }),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchJobCards,
            tooltip: 'Refresh Status',
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6)))
          : jobCards.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.engineering_outlined, size: 64, color: Colors.grey[600]),
                      const SizedBox(height: 16),
                      Text('No active job cards found.', style: TextStyle(color: Colors.grey[400], fontSize: 16)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: fetchJobCards,
                  color: const Color(0xFF3B82F6),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: jobCards.length,
                    itemBuilder: (context, index) {
                      final jc = jobCards[index];
                      final statusColor = _getStatusColor(jc['status'] ?? 'Unknown');

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.05)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Row: Code & Status
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.blueAccent.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    jc['code'] ?? 'JC-00000',
                                    style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: statusColor.withOpacity(0.4)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        jc['status'] ?? 'Active',
                                        style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Vehicle & Customer
                            Row(
                              children: [
                                const Icon(Icons.directions_car, color: Colors.white70, size: 24),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        jc['vehicle_reg'] ?? 'Plate N/A',
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                      Text(
                                        '${jc['vehicle_model']} • Owner: ${jc['customer_name']}',
                                        style: TextStyle(fontSize: 13, color: Colors.grey[400]),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Reported Issues Box
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: const [
                                      Icon(Icons.handyman_outlined, size: 16, color: Colors.orangeAccent),
                                      SizedBox(width: 6),
                                      Text('Reported Issues & Diagnosis:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.orangeAccent, letterSpacing: 0.5)),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    jc['reported_issues'] ?? 'Standard servicing in progress.',
                                    style: const TextStyle(fontSize: 13, color: Colors.white60, height: 1.3),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Divider(color: Colors.white10),
                            const SizedBox(height: 8),

                            // Footer: Assigned Mechanic & Estimated Cost
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.support_agent, size: 20, color: Colors.greenAccent),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Tech: ${jc['mechanic_name']}',
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.greenAccent),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('Est. Total', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                                    Text(
                                      '₹${jc['estimated_cost'] ?? '0'}',
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
