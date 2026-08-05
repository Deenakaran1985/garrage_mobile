import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/api_service.dart';
import '../widgets/server_config_modal.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int activeJobs = 0;
  int pendingJobs = 0;
  int onsiteRequests = 0;
  double totalRevenue = 0.0;
  String companyName = 'AutoPro';
  String companyTagline = 'Service Center';
  List<FlSpot> chartSpots = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStats();
  }

  Future<void> fetchStats() async {
    setState(() => isLoading = true);
    final data = await ApiService.getDashboardStats();
    if (data != null && data['status'] == 'success') {
      setState(() {
        activeJobs = data['active_jobs'] ?? 0;
        pendingJobs = data['pending_jobs'] ?? 0;
        onsiteRequests = data['onsite_requests'] ?? 0;
        totalRevenue = (data['total_revenue'] ?? 0.0).toDouble();
        companyName = data['company_name'] ?? 'AutoPro';
        companyTagline = data['company_tagline'] ?? 'Service Center';
        
        if (data['chart_spots'] != null) {
          chartSpots = (data['chart_spots'] as List).map<FlSpot>((point) {
            return FlSpot((point['x'] as num).toDouble(), (point['y'] as num).toDouble());
          }).toList();
        }
        isLoading = false;
      });
    } else {
      setState(() {
        // Fallback demo spots if server is disconnected
        chartSpots = const [
          FlSpot(1, 1000),
          FlSpot(2, 2500),
          FlSpot(3, 1800),
          FlSpot(4, 4200),
          FlSpot(5, 3800),
          FlSpot(6, 5500),
        ];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(companyName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 22, color: Colors.white)),
            Text(companyTagline, style: TextStyle(fontSize: 11, color: Colors.blueAccent[100], fontWeight: FontWeight.w600, letterSpacing: 0.5)),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0, top: 8.0, bottom: 8.0),
            child: ActionChip(
              avatar: const Icon(Icons.router, size: 16, color: Colors.greenAccent),
              label: Text(
                ApiService.serverHost.length > 16
                    ? '${ApiService.serverHost.substring(0, 14)}..'
                    : ApiService.serverHost,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'monospace'),
              ),
              backgroundColor: Colors.white.withOpacity(0.08),
              side: BorderSide(color: Colors.greenAccent.withOpacity(0.3)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              tooltip: 'Configure Dynamic Server Address & Security Pin',
              onPressed: () => showServerConfigModal(context, onConfigUpdated: () {
                setState(() {});
                fetchStats();
              }),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            onPressed: fetchStats,
            tooltip: 'Refresh Stats',
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6)))
        : RefreshIndicator(
            onRefresh: fetchStats,
            color: const Color(0xFF3B82F6),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Emergency Alert Banner if Onsite SOS exists
                  if (onsiteRequests > 0)
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFFE11D48), Color(0xFFF97316)]),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.redAccent.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.notification_important, color: Colors.white, size: 30),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('$onsiteRequests Active On-Site SOS Requests!', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                                const Text('Mechanic dispatch required immediately.', style: TextStyle(fontSize: 12, color: Colors.white70)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  const Text('Live Workshop Activity', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  
                  // Stat Cards Grid
                  Row(
                    children: [
                      Expanded(child: _buildStatCard('Active Jobs', activeJobs.toString(), Colors.blueAccent, Icons.build_circle)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildStatCard('Pending Booking', pendingJobs.toString(), Colors.amberAccent, Icons.more_time)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildStatCard('On-Site SOS', onsiteRequests.toString(), Colors.redAccent, Icons.local_shipping, isHighlight: onsiteRequests > 0)),
                    ],
                  ),
                  
                  const SizedBox(height: 28),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Revenue & Repair Trend', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.greenAccent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '₹${totalRevenue.toStringAsFixed(0)}',
                          style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.w800, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Chart Panel
                  Container(
                    height: 280,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 5)),
                      ],
                    ),
                    child: chartSpots.isEmpty 
                      ? const Center(child: Text('No performance data available.', style: TextStyle(color: Colors.white54)))
                      : LineChart(
                          LineChartData(
                            gridData: const FlGridData(show: false),
                            titlesData: const FlTitlesData(
                              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            ),
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              LineChartBarData(
                                spots: chartSpots,
                                isCurved: true,
                                color: Colors.greenAccent,
                                barWidth: 4,
                                isStrokeCapRound: true,
                                dotData: FlDotData(
                                  show: true,
                                  getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                                    radius: 4,
                                    color: Colors.white,
                                    strokeWidth: 2,
                                    strokeColor: Colors.greenAccent,
                                  ),
                                ),
                                belowBarData: BarAreaData(
                                  show: true,
                                  gradient: LinearGradient(
                                    colors: [Colors.greenAccent.withOpacity(0.3), Colors.greenAccent.withOpacity(0.01)],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.build_circle, color: Color(0xFF3B82F6), size: 18),
                            const SizedBox(width: 8),
                            const Text(
                              'AutoPro Garage Enterprise OS',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'App developed by Sri Innov Technologies ✨',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.amberAccent[100], letterSpacing: 0.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 70),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon, {bool isHighlight = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
      decoration: BoxDecoration(
        color: isHighlight ? color.withOpacity(0.15) : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isHighlight ? color.withOpacity(0.5) : Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 28, color: color),
          const SizedBox(height: 12),
          Text(title, style: TextStyle(color: Colors.grey[400], fontSize: 12, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: isHighlight ? color : Colors.white)),
        ],
      ),
    );
  }
}
