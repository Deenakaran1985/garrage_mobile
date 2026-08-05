import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/server_config_modal.dart';
import 'create_job_card_wizard.dart';

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
      case 'quote pending approval':
      case 'pending approval':
        return Colors.amberAccent;
      case 'in service queue':
      case 'in repair':
      case 'service in progress':
        return Colors.blueAccent;
      case 'pending parts':
        return Colors.orangeAccent;
      case 'completed':
      case 'completed & invoiced':
      case 'delivered':
        return Colors.greenAccent;
      default:
        return Colors.pinkAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CreateJobCardWizard())),
        backgroundColor: const Color(0xFF3B82F6),
        tooltip: 'Create Job Card / Quotation',
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
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
                            const SizedBox(height: 14),
                            if ((jc['status'] ?? '').toString().toLowerCase().contains('pending') || (jc['status'] ?? '').toString().toLowerCase().contains('quote'))
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent, minimumSize: const Size(double.infinity, 44), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                                onPressed: () async {
                                  final int jcId = jc['id'] is int ? jc['id'] as int : 1;
                                  await ApiService.approveQuotation(jcId);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Quotation approved! Vehicle assigned to Mechanic Service Queue.'), backgroundColor: Colors.green));
                                    fetchJobCards();
                                  }
                                },
                                icon: const Icon(Icons.verified_user, color: Colors.black, size: 18),
                                label: const Text('APPROVE QUOTE & ASSIGN TO QUEUE', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 11)),
                              )
                            else if ((jc['status'] ?? '').toString().toLowerCase().contains('queue'))
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B82F6), minimumSize: const Size(double.infinity, 44), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                                onPressed: () async {
                                  final int jcId = jc['id'] is int ? jc['id'] as int : 1;
                                  await ApiService.acceptServiceQueue(jcId);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🔧 Service Accepted! Vehicle now In Progress.'), backgroundColor: Colors.blueAccent));
                                    fetchJobCards();
                                  }
                                },
                                icon: const Icon(Icons.handyman, color: Colors.white, size: 18),
                                label: const Text('ACCEPT SERVICE FROM QUEUE (MECHANIC) 🔧', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12)),
                              )
                            else if ((jc['status'] ?? '').toString().toLowerCase().contains('progress') || (jc['status'] ?? '').toString().toLowerCase().contains('repair') || (jc['status'] ?? '').toString().toLowerCase().contains('diagnos'))
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), minimumSize: const Size(double.infinity, 44), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                                onPressed: () async {
                                  final int jcId = jc['id'] is int ? jc['id'] as int : 1;
                                  final res = await ApiService.completeServiceAndInvoice(jcId);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('🏁 Service Complete! Tax Invoice generated (₹${res['invoice_amount'] ?? jc['estimated_cost']}) & dispatched to Customer Login!'), backgroundColor: Colors.green));
                                    fetchJobCards();
                                  }
                                },
                                icon: const Icon(Icons.receipt_long, color: Colors.white, size: 18),
                                label: const Text('MARK COMPLETED & GENERATE TAX INVOICE 🏁', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11)),
                              )
                            else
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                decoration: BoxDecoration(color: Colors.green.withOpacity(0.15), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.green.withOpacity(0.4))),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.check_circle, color: Colors.greenAccent, size: 18),
                                    SizedBox(width: 8),
                                    Text('Service Completed • Invoice Sent to Customer Portal', style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.w900, fontSize: 12)),
                                  ],
                                ),
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
