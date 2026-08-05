import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Dynamic network endpoints persisted via SharedPreferences
  static String serverHost = '14.139.184.39:8100';
  static String serverProtocol = 'http';
  static String connectionPassword = 'admin'; // Default fallback administrative password
  static String activeUserRole = 'Admin'; // Options: Admin, Mechanic, Advisor, Customer
  static bool isInitialized = false;

  // Dynamically computed base URL for all REST requests
  static String get baseUrl => '$serverProtocol://$serverHost/api';

  // Asynchronous SharedPreferences boot loader
  static Future<void> loadServerConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String savedHost = prefs.getString('server_host') ?? '14.139.184.39:8100';
      // Automatically migrate from legacy local/emulator defaults to live production server
      if (savedHost == '10.0.2.2:8000' || savedHost == '127.0.0.1:8000' || savedHost == '192.168.1.50:8000') {
        savedHost = '14.139.184.39:8100';
        await prefs.setString('server_host', savedHost);
      }
      serverHost = savedHost;
      serverProtocol = prefs.getString('server_protocol') ?? 'http';
      connectionPassword = prefs.getString('server_password') ?? 'admin';
      activeUserRole = prefs.getString('user_role') ?? 'Admin';
      isInitialized = true;
      print('=== Dynamic AutoPro Server URL Initialized: $baseUrl | Role: $activeUserRole ===');
    } catch (e) {
      print('Error loading SharedPreferences network config: $e');
    }
  }

  // Save dynamically modified server address and security PIN
  static Future<bool> saveServerConfig({
    required String host,
    required String protocol,
    required String password,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cleanedHost = host
          .replaceAll('http://', '')
          .replaceAll('https://', '')
          .replaceAll('/api', '')
          .trim();
          
      await prefs.setString('server_host', cleanedHost);
      await prefs.setString('server_protocol', protocol);
      await prefs.setString('server_password', password);

      serverHost = cleanedHost;
      serverProtocol = protocol;
      connectionPassword = password;
      return true;
    } catch (e) {
      print('Error saving server configuration: $e');
      return false;
    }
  }

  // Switch Active User Persona / Role
  static Future<void> switchUserRole(String role) async {
    activeUserRole = role;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_role', role);
      print('=== Switched Active User Role to: $role ===');
    } catch (e) {
      print('Error saving role: $e');
    }
  }

  // Diagnostic Ping & Connectivity Tester
  static Future<Map<String, dynamic>> testServerConnection(String testHost, String testProtocol) async {
    try {
      final cleanedHost = testHost
          .replaceAll('http://', '')
          .replaceAll('https://', '')
          .replaceAll('/api', '')
          .trim();
      final testUrl = '$testProtocol://$cleanedHost/api/dashboard-stats';
      
      print('Pinging test endpoint: $testUrl');
      final response = await http.get(Uri.parse(testUrl)).timeout(const Duration(seconds: 5));
      
      if (response.statusCode == 200 || response.statusCode == 401 || response.statusCode == 403) {
        return {
          'success': true,
          'message': '✅ Connection Established! Server reached successfully at $cleanedHost (HTTP ${response.statusCode}).',
        };
      } else {
        return {
          'success': false,
          'message': '⚠️ Server reachable at $cleanedHost but returned HTTP status ${response.statusCode}. Ensure Laravel is running.',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': '❌ Connection Failed! Could not reach host. Check that phone and PC are on the same Wi-Fi network and port 8000 is allowed in Firewall.\n($e)',
      };
    }
  }

  static Future<Map<String, dynamic>?> getDashboardStats() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/dashboard-stats')).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('Error fetching dashboard stats from $baseUrl: $e');
    }
    return null;
  }

  static Future<List<dynamic>> getJobCards() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/job-cards')).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] ?? [];
      }
    } catch (e) {
      print('Error fetching job cards from $baseUrl: $e');
    }
    return [];
  }

  static Future<List<dynamic>> getBookings() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/bookings')).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] ?? [];
      }
    } catch (e) {
      print('Error fetching bookings from $baseUrl: $e');
    }
    return [];
  }

  static Future<Map<String, dynamic>?> submitSosBooking({
    required String name,
    required String phone,
    required String vehicleReg,
    required String make,
    required String model,
    required String location,
    required String notes,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/bookings'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: json.encode({
          'customer_name': name,
          'customer_phone': phone,
          'vehicle_reg': vehicleReg,
          'vehicle_make': make,
          'vehicle_model': model,
          'service_type': 'On-Site Breakdown',
          'location_address': location,
          'notes': notes,
        }),
      ).timeout(const Duration(seconds: 12));

      if (response.statusCode == 201 || response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'status': 'error', 'message': 'Failed to transmit request (HTTP ${response.statusCode}): ${response.body}'};
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Network timeout or server offline ($e)'};
    }
  }

  static Future<Map<String, dynamic>?> getVehicleHistory(String query) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/vehicle-history/$query')).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('Error fetching vehicle history from $baseUrl: $e');
    }
    return null;
  }

  // ==================== NEW MULTI-ROLE ENTERPRISE ENDPOINTS ====================

  static Future<Map<String, dynamic>?> getWorkshopBays() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/workshop-bays')).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('Error fetching workshop bays: $e');
    }
    // Fallback demo data for demonstration if offline
    return {
      'status': 'success',
      'summary': {
        'total_bays': 4,
        'vacant_bays': 2,
        'message': '2 Hydraulic Service Lifts Currently Available - Walk-Ins Welcome!',
      },
      'data': [
        {'id': 1, 'code': 'BAY-01', 'name': 'Hydraulic Lift A (Heavy Duty)', 'status': 'Vacant', 'notes': 'Certified 5-Ton'},
        {'id': 2, 'code': 'BAY-02', 'name': 'Hydraulic Lift B (Quick Tune)', 'status': 'Occupied', 'occupancy': {'job_card_id': 'JC-00042', 'vehicle_reg': 'MH-12-DE-9988', 'mechanic': 'Alex Technician'}},
        {'id': 3, 'code': 'BAY-03', 'name': 'Wheel Alignment Bench', 'status': 'Vacant', 'notes': 'Laser 3D Calibrated'},
        {'id': 4, 'code': 'BAY-04', 'name': 'Wash & Detailing Bay', 'status': 'Maintenance', 'notes': 'Pump inspection scheduled'},
      ]
    };
  }

  static Future<Map<String, dynamic>?> toggleWorkshopBay(int id) async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/workshop-bays/$id/toggle')).timeout(const Duration(seconds: 6));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('Error toggling bay $id: $e');
    }
    return {'status': 'success', 'message': 'Bay status toggled (Offline demo mode)'};
  }

  static Future<List<dynamic>> getMechanicEfficiency() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/mechanic-efficiency')).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] ?? [];
      }
    } catch (e) {
      print('Error fetching mechanic efficiency: $e');
    }
    return [
      {'id': 1, 'name': 'Rajesh Master Tech', 'total_assigned_jobs': 12, 'completed_jobs': 11, 'efficiency_rate': 92, 'total_revenue': 45000.0, 'labor_commission_earned': 6750.0, 'status': 'On Active Bay'},
      {'id': 2, 'name': 'Alex Engine Specialist', 'total_assigned_jobs': 8, 'completed_jobs': 8, 'efficiency_rate': 100, 'total_revenue': 32000.0, 'labor_commission_earned': 4800.0, 'status': 'Available for Dispatch'},
      {'id': 3, 'name': 'Sanjay Diagnostics Lead', 'total_assigned_jobs': 15, 'completed_jobs': 13, 'efficiency_rate': 87, 'total_revenue': 58000.0, 'labor_commission_earned': 8700.0, 'status': 'On Active Bay'},
    ];
  }

  static Future<Map<String, dynamic>?> getInventory() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/inventory')).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('Error fetching inventory: $e');
    }
    return {
      'status': 'success',
      'low_stock_count': 2,
      'data': [
        {'id': 1, 'sku': 'SKU-001', 'name': 'Synthetic Engine Oil 5W-30 (5L)', 'category': 'Fluids', 'stock_quantity': 2, 'unit_price': 3500.0, 'is_low_stock': true, 'status': 'LOW STOCK ALERT ⚠️'},
        {'id': 2, 'sku': 'SKU-002', 'name': 'Ceramic Brake Pads Set (Front)', 'category': 'Brakes', 'stock_quantity': 14, 'unit_price': 4200.0, 'is_low_stock': false, 'status': 'Optimal Level ✅'},
        {'id': 3, 'sku': 'SKU-003', 'name': 'High-Performance Spark Plugs (4-Pk)', 'category': 'Ignition', 'stock_quantity': 3, 'unit_price': 1800.0, 'is_low_stock': true, 'status': 'LOW STOCK ALERT ⚠️'},
        {'id': 4, 'sku': 'SKU-004', 'name': 'Oil Filter cartridge standard', 'category': 'Filters', 'stock_quantity': 28, 'unit_price': 650.0, 'is_low_stock': false, 'status': 'Optimal Level ✅'},
      ]
    };
  }

  static Future<List<dynamic>> getQuotations() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/quotations')).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] ?? [];
      }
    } catch (e) {
      print('Error fetching quotations: $e');
    }
    return [
      {'id': 101, 'code': 'QT-00101', 'customer_name': 'Vikram Mehta', 'customer_phone': '+91 9876543210', 'vehicle_info': 'MH-02-ER-5544 - Toyota Fortuner', 'total_amount': 24500.0, 'status': 'Sent to Client', 'created_at': 'Aug 02, 2026'},
      {'id': 102, 'code': 'QT-00102', 'customer_name': 'Ananya Sharma', 'customer_phone': '+91 9811223344', 'vehicle_info': 'DL-01-CA-7788 - Hyundai Creta', 'total_amount': 12800.0, 'status': 'Approved by Client', 'created_at': 'Aug 04, 2026'},
    ];
  }

  static Future<List<dynamic>> getFollowUps() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/follow-ups')).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] ?? [];
      }
    } catch (e) {
      print('Error fetching follow ups: $e');
    }
    return [
      {'id': 1, 'customer_name': 'Rahul Verma', 'customer_phone': '+919988776655', 'vehicle_reg': 'MH-12-PQ-4321', 'vehicle_make_model': 'Honda City', 'last_service_date': 'May 15, 2026', 'days_since_last_service': 82, 'recommendation': 'Seasonal Engine Oil & 50-Point Safety VHI Check Due!'},
      {'id': 2, 'customer_name': 'Sneha Kapoor', 'customer_phone': '+919877665544', 'vehicle_reg': 'KA-05-XY-9012', 'vehicle_make_model': 'Mahindra XUV700', 'last_service_date': 'May 28, 2026', 'days_since_last_service': 69, 'recommendation': 'Brake System Bleeding & Wheel Alignment Inspection Due!'},
    ];
  }
}
