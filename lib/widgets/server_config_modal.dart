import 'package:flutter/material.dart';
import '../services/api_service.dart';

void showServerConfigModal(BuildContext context, {required VoidCallback onConfigUpdated}) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (ctx) => _ServerConfigDialog(onConfigUpdated: onConfigUpdated),
  );
}

class _ServerConfigDialog extends StatefulWidget {
  final VoidCallback onConfigUpdated;
  const _ServerConfigDialog({Key? key, required this.onConfigUpdated}) : super(key: key);

  @override
  State<_ServerConfigDialog> createState() => _ServerConfigDialogState();
}

class _ServerConfigDialogState extends State<_ServerConfigDialog> {
  late TextEditingController hostCtrl;
  late TextEditingController passwordCtrl;
  late TextEditingController newPasswordCtrl;
  String selectedProtocol = 'http';
  bool isTesting = false;
  bool isSaving = false;
  bool isPasswordObscured = true;
  bool showChangePassword = false;
  String diagnosticMessage = '';
  Color diagnosticColor = Colors.grey;

  final List<String> quickPresets = [
    '14.139.184.39:8100', // Live Production Server ⭐
    '10.0.2.2:8000',      // Default Android Emulator
    '192.168.1.50:8000',  // Typical Wi-Fi LAN
  ];

  @override
  void initState() {
    super.initState();
    hostCtrl = TextEditingController(text: ApiService.serverHost);
    passwordCtrl = TextEditingController();
    newPasswordCtrl = TextEditingController(text: ApiService.connectionPassword);
    selectedProtocol = ApiService.serverProtocol;
  }

  @override
  void dispose() {
    hostCtrl.dispose();
    passwordCtrl.dispose();
    newPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _runPingTest() async {
    if (hostCtrl.text.trim().isEmpty) {
      setState(() {
        diagnosticMessage = '⚠️ Please input a target server IP address first.';
        diagnosticColor = Colors.orangeAccent;
      });
      return;
    }

    setState(() {
      isTesting = true;
      diagnosticMessage = '🔄 Pinging ${selectedProtocol}://${hostCtrl.text.trim()}/api...';
      diagnosticColor = Colors.blueAccent;
    });

    final result = await ApiService.testServerConnection(hostCtrl.text.trim(), selectedProtocol);
    
    if (mounted) {
      setState(() {
        isTesting = false;
        diagnosticMessage = result['message'] ?? 'Unknown status';
        diagnosticColor = result['success'] ? Colors.greenAccent : Colors.redAccent;
      });
    }
  }

  Future<void> _authorizeAndSave() async {
    final enteredPassword = passwordCtrl.text.trim();

    // Verify against currently saved password (default 'admin')
    if (enteredPassword != ApiService.connectionPassword) {
      setState(() {
        diagnosticMessage = '⛔ Access Denied! Incorrect security authorization password. Default is "admin".';
        diagnosticColor = Colors.redAccent;
      });
      return;
    }

    if (hostCtrl.text.trim().isEmpty) {
      setState(() {
        diagnosticMessage = '⚠️ Server address cannot be empty.';
        diagnosticColor = Colors.orangeAccent;
      });
      return;
    }

    setState(() => isSaving = true);

    final passToSave = showChangePassword && newPasswordCtrl.text.trim().isNotEmpty
        ? newPasswordCtrl.text.trim()
        : ApiService.connectionPassword;

    final success = await ApiService.saveServerConfig(
      host: hostCtrl.text.trim(),
      protocol: selectedProtocol,
      password: passToSave,
    );

    setState(() => isSaving = false);

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Dynamic Server Endpoint configured to ${ApiService.baseUrl}', style: const TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        widget.onConfigUpdated();
        Navigator.of(context).pop();
      }
    } else {
      setState(() {
        diagnosticMessage = '❌ Failed to save settings to local storage.';
        diagnosticColor = Colors.redAccent;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 440),
        decoration: BoxDecoration(
          color: const Color(0xFF222533),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.12), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.6),
              blurRadius: 30,
              spreadRadius: 5,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.4)),
                    ),
                    child: const Icon(Icons.dns_rounded, color: Color(0xFF3B82F6), size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Server Connection Gate',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white),
                        ),
                        Text(
                          'Dynamic Host & Authorization',
                          style: TextStyle(fontSize: 12, color: Colors.grey[400], fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Active URL status box
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.06)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.link, color: Colors.greenAccent, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ACTIVE COMMAND CENTER URL', style: TextStyle(fontSize: 10, color: Colors.grey[400], fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                          Text(ApiService.baseUrl, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'monospace')),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Server IP Field
              const Text('SERVER IP / DOMAIN & PORT *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueAccent, letterSpacing: 0.5)),
              const SizedBox(height: 8),
              TextField(
                controller: hostCtrl,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15, fontFamily: 'monospace'),
                decoration: InputDecoration(
                  hintText: 'e.g. 192.168.1.50:8000',
                  hintStyle: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.normal),
                  prefixIcon: const Icon(Icons.router, color: Colors.blueAccent, size: 22),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.04),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.white.withOpacity(0.08))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.blueAccent, width: 1.5)),
                ),
              ),
              const SizedBox(height: 10),

              // Preset Quick Chips
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: quickPresets.map((preset) => InkWell(
                  onTap: () => setState(() => hostCtrl.text = preset),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: hostCtrl.text == preset ? const Color(0xFF3B82F6).withOpacity(0.2) : Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: hostCtrl.text == preset ? const Color(0xFF3B82F6) : Colors.white.withOpacity(0.1)),
                    ),
                    child: Text(
                      '⚡ $preset',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: hostCtrl.text == preset ? const Color(0xFF60A5FA) : Colors.grey[300]),
                    ),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 20),

              // Authorization Password
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('SECURITY AUTHORIZATION PASSWORD *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.orangeAccent, letterSpacing: 0.5)),
                  Text('Default: admin', style: TextStyle(fontSize: 11, color: Colors.grey[500], fontStyle: FontStyle.italic)),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: passwordCtrl,
                obscureText: isPasswordObscured,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Enter password to modify endpoint...',
                  hintStyle: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.normal, fontSize: 13),
                  prefixIcon: const Icon(Icons.lock_outline, color: Colors.orangeAccent, size: 22),
                  suffixIcon: IconButton(
                    icon: Icon(isPasswordObscured ? Icons.visibility : Icons.visibility_off, color: Colors.grey[400], size: 20),
                    onPressed: () => setState(() => isPasswordObscured = !isPasswordObscured),
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.04),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.white.withOpacity(0.08))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.orangeAccent, width: 1.5)),
                ),
              ),
              
              const SizedBox(height: 14),
              
              // Toggle change password option
              GestureDetector(
                onTap: () => setState(() => showChangePassword = !showChangePassword),
                child: Row(
                  children: [
                    Icon(showChangePassword ? Icons.check_box : Icons.check_box_outline_blank, color: const Color(0xFF3B82F6), size: 20),
                    const SizedBox(width: 8),
                    const Text('Change security connection password for this device', style: TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              if (showChangePassword) ...[
                const SizedBox(height: 10),
                TextField(
                  controller: newPasswordCtrl,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  decoration: InputDecoration(
                    labelText: 'New Security Password / PIN',
                    labelStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                    prefixIcon: const Icon(Icons.key, color: Colors.greenAccent, size: 20),
                    filled: true,
                    fillColor: Colors.black.withOpacity(0.2),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
              ],
              
              // Diagnostic Message output area
              if (diagnosticMessage.isNotEmpty) ...[
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(12),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: diagnosticColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: diagnosticColor.withOpacity(0.4)),
                  ),
                  child: Text(
                    diagnosticMessage,
                    style: TextStyle(fontSize: 13, color: diagnosticColor, fontWeight: FontWeight.bold, height: 1.3),
                  ),
                ),
              ],
              
              const SizedBox(height: 24),

              // Action Buttons Row
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: isTesting || isSaving ? null : _runPingTest,
                      icon: isTesting
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blueAccent))
                          : const Icon(Icons.radar, color: Colors.blueAccent, size: 20),
                      label: Text(isTesting ? 'Pinging...' : 'Test Ping', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent, fontSize: 13)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Colors.blueAccent, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: ElevatedButton.icon(
                      onPressed: isSaving || isTesting ? null : _authorizeAndSave,
                      icon: isSaving
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.verified_user, color: Colors.white, size: 20),
                      label: Text(isSaving ? 'Saving...' : 'Authorize', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Center(
                child: Text(
                  'App developed by Sri Innov Technologies',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.grey[500], letterSpacing: 0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
