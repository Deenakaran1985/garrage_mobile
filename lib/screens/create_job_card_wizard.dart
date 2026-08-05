import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CreateJobCardWizard extends StatefulWidget {
  const CreateJobCardWizard({Key? key}) : super(key: key);

  @override
  State<CreateJobCardWizard> createState() => _CreateJobCardWizardState();
}

class _CreateJobCardWizardState extends State<CreateJobCardWizard> {
  // Step 1: Vehicle & Customer Master info
  final TextEditingController regCtrl = TextEditingController();
  final TextEditingController custNameCtrl = TextEditingController();
  final TextEditingController custPhoneCtrl = TextEditingController();
  final TextEditingController makeCtrl = TextEditingController();
  final TextEditingController modelCtrl = TextEditingController();
  final TextEditingController yearCtrl = TextEditingController(text: '2025');
  final TextEditingController issuesCtrl = TextEditingController();

  // Step 2: Service Selection & On-the-fly additions
  List<Map<String, dynamic>> availableServices = [
    {'id': 1, 'name': '50-Point AI Diagnostics & Health Scan', 'price': 850.0, 'selected': false},
    {'id': 2, 'name': 'Synthetic Engine Oil & Oil Filter Replacement', 'price': 3200.0, 'selected': false},
    {'id': 3, 'name': 'Laser 3D Wheel Alignment & Balancing', 'price': 1500.0, 'selected': false},
    {'id': 4, 'name': 'AC Compressor Overhaul & Gas Refill', 'price': 2800.0, 'selected': false},
    {'id': 5, 'name': 'Ceramic Paint Protection & Interior Detailing', 'price': 4500.0, 'selected': false},
  ];
  List<Map<String, dynamic>> newCustomServices = [];

  // Step 3: Spare parts (including out of stock items)
  List<Map<String, dynamic>> addedSpareParts = [
    {'name': 'Brake Pad Set (Genuine High Performance)', 'quantity': 1, 'unit_price': 2400.0, 'in_stock': true},
  ];

  bool isSubmitting = false;
  int currentStep = 0;

  double get laborTotal {
    double sum = 0;
    for (var s in availableServices) {
      if (s['selected'] == true) sum += s['price'] as double;
    }
    for (var ns in newCustomServices) {
      sum += ns['price'] as double;
    }
    return sum;
  }

  double get partsTotal {
    double sum = 0;
    for (var p in addedSpareParts) {
      sum += (p['unit_price'] as double) * (p['quantity'] as int);
    }
    return sum;
  }

  double get grandApproxTotal => laborTotal + partsTotal;

  void _addNewServiceModal() {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E2230),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.white.withOpacity(0.1))),
        title: const Row(
          children: [
            Icon(Icons.post_add, color: Colors.cyanAccent),
            SizedBox(width: 10),
            Text('Add Service to Master', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('If this service is not in the existing master list, it will be saved to Master DB on-the-fly and applied to this quote.', style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4)),
            const SizedBox(height: 16),
            TextField(
              controller: nameCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'New Service Name',
                labelStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.black26,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Standard Fee (₹)',
                labelStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.black26,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () {
              if (nameCtrl.text.trim().isNotEmpty) {
                final double val = double.tryParse(priceCtrl.text.trim()) ?? 500.0;
                setState(() {
                  newCustomServices.add({'name': nameCtrl.text.trim(), 'price': val});
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✨ Service added to Master & selected for quotation!'), backgroundColor: Colors.green));
              }
            },
            child: const Text('SAVE TO MASTER & SELECT', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  void _addSparePartModal() {
    final nameCtrl = TextEditingController();
    final qtyCtrl = TextEditingController(text: '1');
    final priceCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E2230),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.white.withOpacity(0.1))),
        title: const Row(
          children: [
            Icon(Icons.settings_input_component, color: Colors.orangeAccent),
            SizedBox(width: 10),
            Expanded(child: Text('Add Spare Part Estimate', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 17))),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.orangeAccent.withOpacity(0.15), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.orangeAccent.withOpacity(0.3))),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orangeAccent, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Even if this part is not in current inventory, the approx valuation will be included in the estimate sent to Customer Login!',
                        style: TextStyle(color: Colors.orangeAccent, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Spare Part / Material Name',
                  labelStyle: TextStyle(color: Colors.grey[400]),
                  filled: true,
                  fillColor: Colors.black26,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: qtyCtrl,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Qty',
                        labelStyle: TextStyle(color: Colors.grey[400]),
                        filled: true,
                        fillColor: Colors.black26,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: priceCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Approx Unit Price (₹)',
                        labelStyle: TextStyle(color: Colors.grey[400]),
                        filled: true,
                        fillColor: Colors.black26,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () {
              if (nameCtrl.text.trim().isNotEmpty) {
                final int qty = int.tryParse(qtyCtrl.text.trim()) ?? 1;
                final double price = double.tryParse(priceCtrl.text.trim()) ?? 500.0;
                setState(() {
                  addedSpareParts.add({
                    'name': nameCtrl.text.trim(),
                    'quantity': qty,
                    'unit_price': price,
                    'in_stock': false, // Flag as uninventoried approximation
                  });
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('📦 Approx part value appended to customer quote!'), backgroundColor: Colors.orangeAccent));
              }
            },
            child: const Text('ADD TO ESTIMATE', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  Future<void> _submitJobCard() async {
    if (regCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('⚠️ Please enter the Vehicle Registration Number!'), backgroundColor: Colors.redAccent));
      return;
    }

    setState(() => isSubmitting = true);

    List<int> selectedIds = [];
    for (var s in availableServices) {
      if (s['selected'] == true) selectedIds.add(s['id'] as int);
    }

    final result = await ApiService.createComprehensiveJobCard(
      regNumber: regCtrl.text.trim(),
      customerName: custNameCtrl.text.trim().isEmpty ? 'Valued Customer' : custNameCtrl.text.trim(),
      customerPhone: custPhoneCtrl.text.trim().isEmpty ? '+91 9876543210' : custPhoneCtrl.text.trim(),
      make: makeCtrl.text.trim().isEmpty ? 'Automobile' : makeCtrl.text.trim(),
      model: modelCtrl.text.trim().isEmpty ? 'Sedan/SUV' : modelCtrl.text.trim(),
      year: yearCtrl.text.trim(),
      selectedServiceIds: selectedIds,
      newCustomServices: newCustomServices,
      spareParts: addedSpareParts,
      reportedIssues: issuesCtrl.text.trim().isEmpty ? 'Comprehensive inspection and routine scheduled service.' : issuesCtrl.text.trim(),
    );

    setState(() => isSubmitting = false);

    if (context.mounted) {
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF1E2230),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: BorderSide(color: Colors.greenAccent.withOpacity(0.4), width: 2)),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.greenAccent, size: 28),
              SizedBox(width: 12),
              Text('Quote Sent to Customer!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(result['message'] ?? 'Job Card created and quotation dispatched!', style: const TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.black38, borderRadius: BorderRadius.circular(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Approximate Valuation: ₹${grandApproxTotal.toStringAsFixed(2)}', style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.w900, fontSize: 16)),
                    const SizedBox(height: 8),
                    const Text('• Status: Quote Pending Approval\n• Customer Notification: Dispatched to Customer Login Portal\n• Master DB: Vehicle & Custom Services automatically synced', style: TextStyle(color: Colors.white60, fontSize: 12, height: 1.5)),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              onPressed: () => Navigator.pop(ctx),
              child: const Text('CLOSE & MONITOR QUEUE', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900)),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0F17),
      appBar: AppBar(
        title: const Text('Advisor Job Card & Quotation Wizard', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Banner
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF1E3A8A), Color(0xFF0F172A)]),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
                    boxShadow: [BoxShadow(color: Colors.blueAccent.withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 4))],
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.auto_awesome, color: Colors.cyanAccent, size: 32),
                      SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Service Advisor AI OS Wizard', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
                            SizedBox(height: 4),
                            Text('Creates Vehicle Master on-the-fly if new, allows custom services, & provides approximate pricing even for unstocked parts!', style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.35)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Step 1: Vehicle & Customer Master
                const Text('STEP 1: VEHICLE & OWNER MASTER RECORD', style: TextStyle(color: Colors.cyanAccent, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1.0)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(color: const Color(0xFF191D2B), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.06))),
                  child: Column(
                    children: [
                      TextField(
                        controller: regCtrl,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16, letterSpacing: 1.5),
                        textCapitalization: TextCapitalization.characters,
                        decoration: InputDecoration(
                          labelText: 'Vehicle Registration No (e.g. MH-12-AB-9988) *',
                          labelStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                          prefixIcon: const Icon(Icons.directions_car, color: Colors.cyanAccent),
                          filled: true,
                          fillColor: Colors.black26,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: custNameCtrl,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(labelText: 'Owner Name (If New)', labelStyle: TextStyle(color: Colors.grey[400], fontSize: 13), filled: true, fillColor: Colors.black26, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14))),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: custPhoneCtrl,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(labelText: 'Owner Phone', labelStyle: TextStyle(color: Colors.grey[400], fontSize: 13), filled: true, fillColor: Colors.black26, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14))),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: makeCtrl,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(labelText: 'Make (e.g. Toyota)', labelStyle: TextStyle(color: Colors.grey[400], fontSize: 13), filled: true, fillColor: Colors.black26, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14))),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: modelCtrl,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(labelText: 'Model (e.g. Fortuner)', labelStyle: TextStyle(color: Colors.grey[400], fontSize: 13), filled: true, fillColor: Colors.black26, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14))),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: issuesCtrl,
                        maxLines: 2,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(labelText: 'Reported Issues & Customer Notes', labelStyle: TextStyle(color: Colors.grey[400], fontSize: 13), prefixIcon: const Icon(Icons.build_circle, color: Colors.amberAccent), filled: true, fillColor: Colors.black26, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14))),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),

                // Step 2: Service Selection & Master Addition
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('STEP 2: SERVICE MASTER SELECTION', style: TextStyle(color: Colors.greenAccent, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1.0)),
                    TextButton.icon(
                      onPressed: _addNewServiceModal,
                      icon: const Icon(Icons.add_circle, color: Colors.greenAccent, size: 18),
                      label: const Text('+ ADD NEW TO MASTER', style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.w800, fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Column(
                  children: availableServices.map((srv) {
                    final bool isSel = srv['selected'] == true;
                    return GestureDetector(
                      onTap: () => setState(() => srv['selected'] = !isSel),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: isSel ? Colors.greenAccent.withOpacity(0.15) : const Color(0xFF191D2B),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: isSel ? Colors.greenAccent : Colors.white.withOpacity(0.06), width: isSel ? 2 : 1),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Text(srv['name'] as String, style: TextStyle(color: isSel ? Colors.white : Colors.grey[300], fontWeight: FontWeight.w700, fontSize: 14))),
                            Text('₹${srv['price']}', style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.w900, fontSize: 14)),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                if (newCustomServices.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Text('✨ Newly Added to Service Master DB (On-the-Fly):', style: TextStyle(color: Colors.amberAccent, fontSize: 12, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  ...newCustomServices.map((ns) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(color: Colors.amberAccent.withOpacity(0.12), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.amberAccent.withOpacity(0.5))),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(ns['name'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                            Text('₹${ns['price']}', style: const TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.w900, fontSize: 14)),
                          ],
                        ),
                      )),
                ],
                const SizedBox(height: 26),

                // Step 3: Replacement Spare Parts
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(child: Text('STEP 3: REPLACEMENT PARTS (APPROX ESTIMATE)', style: TextStyle(color: Colors.orangeAccent, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 0.8))),
                    TextButton.icon(
                      onPressed: _addSparePartModal,
                      icon: const Icon(Icons.add_shopping_cart, color: Colors.orangeAccent, size: 18),
                      label: const Text('+ ADD PART / MATERIAL', style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.w800, fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text('* Note: If parts are out of inventory stock or custom, approx valuation is included in customer quote!', style: TextStyle(color: Colors.grey, fontSize: 11, fontStyle: FontStyle.italic)),
                const SizedBox(height: 12),
                Column(
                  children: addedSpareParts.map((part) {
                    final bool inStock = part['in_stock'] == true;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: const Color(0xFF191D2B), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.06))),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: (inStock ? Colors.green : Colors.orange).withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                            child: Icon(inStock ? Icons.inventory_2 : Icons.timelapse, color: inStock ? Colors.greenAccent : Colors.orangeAccent, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(part['name'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
                                const SizedBox(height: 4),
                                Text(
                                  inStock ? 'Qty: ${part['quantity']} • In Physical Workshop Stock' : 'Qty: ${part['quantity']} • Out of Stock / Custom Approx Estimate',
                                  style: TextStyle(color: inStock ? Colors.greenAccent[200] : Colors.orangeAccent[200], fontSize: 11, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                          Text('₹${(part['unit_price'] as double) * (part['quantity'] as int)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 30),

                // Total Summary & Submit Banner
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF111827), Color(0xFF1F2937)]),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.cyanAccent.withOpacity(0.3)),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 6))],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Labor & Service Masters:', style: TextStyle(color: Colors.grey, fontSize: 14)),
                          Text('₹${laborTotal.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Spare Parts (Approx Value):', style: TextStyle(color: Colors.grey, fontSize: 14)),
                          Text('₹${partsTotal.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                        ],
                      ),
                      const Divider(color: Colors.white24, height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('GRAND APPROX QUOTE:', style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 0.5)),
                          Text('₹${grandApproxTotal.toStringAsFixed(2)}', style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.w900, fontSize: 22)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3B82F6),
                            elevation: 8,
                            shadowColor: Colors.blueAccent.withOpacity(0.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: isSubmitting ? null : _submitJobCard,
                          icon: isSubmitting ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.send_rounded, color: Colors.white, size: 22),
                          label: Text(isSubmitting ? 'DISPATCHING TO CUSTOMER LOGIN...' : 'CREATE JOB CARD & SEND QUOTE TO CUSTOMER 🚀', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 0.5)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
