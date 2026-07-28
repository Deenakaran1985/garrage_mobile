import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Dynamic network endpoints persisted via SharedPreferences
  static String serverHost = '127.0.0.1:8000';
  static String serverProtocol = 'http';
  static String connectionPassword = 'admin'; // Default fallback administrative password
  static bool isInitialized = false;

  // Dynamically computed base URL for all REST requests
  static String get baseUrl => '$serverProtocol://$serverHost/api';

  // Asynchronous SharedPreferences boot loader
  static Future<void> loadServerConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      serverHost = prefs.getString('server_host') ?? '10.0.2.2:8000'; // Default to Android emulator LAN IP
      serverProtocol = prefs.getString('server_protocol') ?? 'http';
      connectionPassword = prefs.getString('server_password') ?? 'admin';
      isInitialized = true;
      print('=== Dynamic AutoPro Server URL Initialized: $baseUrl ===');
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
}
