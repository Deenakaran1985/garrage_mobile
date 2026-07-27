import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SosBookingScreen extends StatefulWidget {
  const SosBookingScreen({Key? key}) : super(key: key);

  @override
  State<SosBookingScreen> createState() => _SosBookingScreenState();
}

class _SosBookingScreenState extends State<SosBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController regCtrl = TextEditingController();
  final TextEditingController makeCtrl = TextEditingController();
  final TextEditingController modelCtrl = TextEditingController();
  final TextEditingController locationCtrl = TextEditingController();
  final TextEditingController notesCtrl = TextEditingController();

  bool isSubmitting = false;

  void _submitSosRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSubmitting = true);

    final result = await ApiService.submitSosBooking(
      name: nameCtrl.text.trim(),
      phone: phoneCtrl.text.trim(),
      vehicleReg: regCtrl.text.trim(),
      make: makeCtrl.text.trim(),
      model: modelCtrl.text.trim(),
      location: locationCtrl.text.trim(),
      notes: notesCtrl.text.trim(),
    );

    setState(() => isSubmitting = false);

    if (result != null && result['status'] == 'success') {
      _showSuccessModal(result['reference_code'] ?? 'SOS-00001');
      _clearFields();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result?['message'] ?? 'Failed to transmit SOS request.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _clearFields() {
    nameCtrl.clear();
    phoneCtrl.clear();
    regCtrl.clear();
    makeCtrl.clear();
    modelCtrl.clear();
    locationCtrl.clear();
    notesCtrl.clear();
  }

  void _showSuccessModal(String refCode) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2A2D3E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.check_circle, color: Colors.greenAccent, size: 32),
            SizedBox(width: 12),
            Text('SOS Transmitted!', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your emergency breakdown location and vehicle details have been received by the Garage Dispatch Center.',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orangeAccent.withOpacity(0.5)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Reference Code:', style: TextStyle(color: Colors.grey)),
                  Text(refCode, style: const TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text('An en-route field technician will contact your phone immediately.', style: TextStyle(color: Colors.greenAccent, fontSize: 13)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: const [
            Icon(Icons.warning_rounded, color: Colors.orangeAccent, size: 26),
            SizedBox(width: 8),
            Text('Emergency On-Site SOS', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE11D48), Color(0xFFEA580C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE11D48).withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.build_circle, color: Colors.white, size: 36),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Stranded on the Road?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                          SizedBox(height: 4),
                          Text('Request instant breakdown repair & mobile mechanic dispatch anywhere!', style: TextStyle(fontSize: 13, color: Colors.white70)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Customer Info
              const Text('1. Driver & Contact Info', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
              const SizedBox(height: 12),
              _buildTextField(ctrl: nameCtrl, label: 'Full Name *', icon: Icons.person, validator: (val) => val!.isEmpty ? 'Required' : null),
              const SizedBox(height: 12),
              _buildTextField(ctrl: phoneCtrl, label: 'Phone Number (For technician call) *', icon: Icons.phone, validator: (val) => val!.isEmpty ? 'Required' : null, type: TextInputType.phone),

              const SizedBox(height: 24),
              // Vehicle Info
              const Text('2. Vehicle Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigoAccent)),
              const SizedBox(height: 12),
              _buildTextField(ctrl: regCtrl, label: 'License Plate / Reg Plate *', icon: Icons.directions_car, validator: (val) => val!.isEmpty ? 'Required' : null),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildTextField(ctrl: makeCtrl, label: 'Make (e.g. Toyota)', icon: Icons.handyman)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildTextField(ctrl: modelCtrl, label: 'Model (e.g. Corolla)', icon: Icons.car_repair)),
                ],
              ),

              const SizedBox(height: 24),
              // Location & Problem
              const Text('3. Breakdown Location & Problem', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orangeAccent)),
              const SizedBox(height: 12),
              _buildTextField(ctrl: locationCtrl, label: 'Exact Address or Highway Landmark *', icon: Icons.my_location, maxLines: 2, validator: (val) => val!.isEmpty ? 'Please specify location' : null),
              const SizedBox(height: 12),
              _buildTextField(ctrl: notesCtrl, label: 'Describe Issue (Flat tire, dead battery, engine overheated...)', icon: Icons.description, maxLines: 3),

              const SizedBox(height: 32),
              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isSubmitting ? null : _submitSosRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEA580C),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 8,
                    shadowColor: Colors.orange.withOpacity(0.5),
                  ),
                  child: isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.broadcast_on_personal, size: 24, color: Colors.white),
                            SizedBox(width: 10),
                            Text('TRANSMIT SOS REQUEST', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.1)),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController ctrl,
    required String label,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
    TextInputType type = TextInputType.text,
  }) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      validator: validator,
      keyboardType: type,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
        prefixIcon: Icon(icon, color: const Color(0xFF3B82F6), size: 20),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
