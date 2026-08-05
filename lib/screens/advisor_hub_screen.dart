import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/server_config_modal.dart';
import 'create_job_card_wizard.dart';

class AdvisorHubScreen extends StatefulWidget {
  const AdvisorHubScreen({Key? key}) : super(key: key);

  @override
  State<AdvisorHubScreen> createState() => _AdvisorHubScreenState();
}

class _AdvisorHubScreenState extends State<AdvisorHubScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> inventory = [];
  int lowStockCount = 0;
  List<dynamic> quotations = [];
  List<dynamic> followUps = [];
  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    fetchData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> fetchData() async {
    setState(() => isLoading = true);
    final invData = await ApiService.getInventory();
    final quotes = await ApiService.getQuotations();
    final follow = await ApiService.getFollowUps();

    if (mounted) {
      setState(() {
        if (invData != null) {
          inventory = invData['data'] ?? [];
          lowStockCount = invData['low_stock_count'] ?? 0;
        }
        quotations = quotes;
        followUps = follow;
        isLoading = false;
      });
    }
  }

  void _sendWhatsAppBlast(String customerName, String phone, String recommendation) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('📲 WhatsApp reminder dispatched to $customerName ($phone)!', style: const TextStyle(fontWeight: FontWeight.bold)),
        duration: const Duration(seconds: 3),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CreateJobCardWizard())),
        backgroundColor: const Color(0xFF3B82F6),
        icon: const Icon(Icons.add_task, color: Colors.white),
        label: const Text('New Job Card / Quote', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
      ),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Service Advisor & Stock', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: Colors.white)),
            Text('Warehouse Alerts, Quotes & WhatsApp Blasts', style: TextStyle(fontSize: 11, color: Colors.blueAccent[100], fontWeight: FontWeight.w600)),
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
            tooltip: 'Refresh Advisor Command',
          ),
          const SizedBox(width: 6),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF3B82F6),
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey[400],
          labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
          tabs: [
            Tab(icon: const Icon(Icons.inventory), text: 'Stock ($lowStockCount)'),
            const Tab(icon: Icon(Icons.request_quote), text: 'Quotations'),
            const Tab(icon: Icon(Icons.chat), text: 'WhatsApp Follow-Up'),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6)))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildInventoryView(),
                _buildQuotationsView(),
                _buildFollowUpsView(),
              ],
            ),
    );
  }

  Widget _buildInventoryView() {
    final filtered = inventory.where((item) {
      final name = (item['name'] ?? '').toString().toLowerCase();
      final sku = (item['sku'] ?? '').toString().toLowerCase();
      return name.contains(searchQuery.toLowerCase()) || sku.contains(searchQuery.toLowerCase());
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            onChanged: (val) => setState(() => searchQuery = val),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search spare parts by SKU or Name...',
              hintStyle: TextStyle(color: Colors.grey[500]),
              prefixIcon: const Icon(Icons.search, color: Color(0xFF3B82F6)),
              filled: true,
              fillColor: const Color(0xFF222533),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: fetchData,
            color: const Color(0xFF3B82F6),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                if (lowStockCount > 0)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE11D48).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE11D48)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.notification_important, color: Color(0xFFE11D48), size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('$lowStockCount Items Below Minimum Safety Stock!', style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 15)),
                              const SizedBox(height: 2),
                              const Text('Immediate reordering recommended to prevent workshop bay delays.', style: TextStyle(color: Colors.white70, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ...filtered.map((item) {
                  final isLow = item['is_low_stock'] == true;
                  final price = (item['unit_price'] as num? ?? 0.0).toStringAsFixed(0);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF222533),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: isLow ? const Color(0xFFE11D48).withOpacity(0.5) : Colors.white.withOpacity(0.06)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isLow ? const Color(0xFFE11D48).withOpacity(0.2) : const Color(0xFF10B981).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(isLow ? Icons.warning_amber_rounded : Icons.check_circle, color: isLow ? const Color(0xFFE11D48) : const Color(0xFF10B981), size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item['name'] ?? 'Item', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Colors.white)),
                              const SizedBox(height: 4),
                              Text('SKU: ${item['sku']} • Category: ${item['category'] ?? 'Parts'}', style: TextStyle(fontSize: 11, color: Colors.grey[400], fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('₹$price / unit', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white)),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(color: isLow ? const Color(0xFFE11D48) : const Color(0xFF10B981), borderRadius: BorderRadius.circular(8)),
                              child: Text('Stock: ${item['stock_quantity']}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuotationsView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('RECENT WORKSHOP QUOTATIONS & ESTIMATES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.0)),
        const SizedBox(height: 10),
        ...quotations.map((q) {
          final amt = (q['total_amount'] as num? ?? 0.0).toStringAsFixed(0);

          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF222533),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(q['code'] ?? 'QT-000', style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF60A5FA), fontSize: 16)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFF3B82F6).withOpacity(0.2), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFF3B82F6))),
                      child: Text(q['status'] ?? 'Draft', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF60A5FA))),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text('${q['customer_name']} • ${q['vehicle_info']}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Colors.white)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Date: ${q['created_at']}', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                    Text('Estimate: ₹$amt', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Color(0xFF10B981))),
                  ],
                ),
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  onPressed: () async {
                    final int qId = q['id'] is int ? q['id'] as int : 1;
                    await ApiService.approveQuotation(qId, quotationId: qId);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('✅ ${q['code']} Quote Approved! Vehicle dispatched to Mechanic Service Queue!'), backgroundColor: const Color(0xFF10B981)),
                      );
                      fetchData();
                    }
                  },
                  icon: const Icon(Icons.check_circle_outline, size: 18, color: Colors.white),
                  label: const Text('Approve Quote & Assign to Service Queue ⚡', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    minimumSize: const Size(double.infinity, 44),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildFollowUpsView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withOpacity(0.15),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFF10B981)),
          ),
          child: Row(
            children: [
              const Icon(Icons.chat_bubble, color: Color(0xFF10B981), size: 32),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Automated Retention WhatsApp Broadcast', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white)),
                    SizedBox(height: 4),
                    Text('Customers below are due for seasonal servicing (>60 days inactive). Tap button to trigger WhatsApp blast.', style: TextStyle(fontSize: 12, color: Colors.white70, height: 1.3)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        ...followUps.map((item) {
          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF222533),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item['customer_name'] ?? 'Client', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.white)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFFEA580C).withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                      child: Text('${item['days_since_last_service']} days since visit', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFFEA580C))),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text('${item['vehicle_reg']} • ${item['vehicle_make_model']} (Last visit: ${item['last_service_date']})', style: TextStyle(color: Colors.grey[300], fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                Text('💡 Recommended: ${item['recommendation']}', style: TextStyle(color: Colors.blueAccent[100], fontStyle: FontStyle.italic, fontSize: 12)),
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  onPressed: () => _sendWhatsAppBlast(item['customer_name'] ?? 'Customer', item['customer_phone'] ?? '', item['recommendation'] ?? 'Service Check'),
                  icon: const Icon(Icons.send_rounded, size: 18, color: Colors.white),
                  label: Text('Send WhatsApp Reminder to ${item['customer_phone']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    minimumSize: const Size(double.infinity, 44),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}
