import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Use '10.0.2.2:8000' for standard Android Emulator connecting to local Laravel server.
  // When testing on Web or Chrome desktop, you can switch to '127.0.0.1:8000' or your LAN IP.
  static String baseUrl = 'http://127.0.0.1:8000/api';

  static Future<Map<String, dynamic>?> getDashboardStats() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/dashboard-stats'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('Error fetching dashboard stats: $e');
    }
    return null;
  }

  static Future<List<dynamic>> getJobCards() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/job-cards'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] ?? [];
      }
    } catch (e) {
      print('Error fetching job cards: $e');
    }
    return [];
  }

  static Future<List<dynamic>> getBookings() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/bookings'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] ?? [];
      }
    } catch (e) {
      print('Error fetching bookings: $e');
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
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'status': 'error', 'message': 'Failed to transmit request: ${response.body}'};
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>?> getVehicleHistory(String query) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/vehicle-history/$query'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('Error fetching vehicle history: $e');
    }
    return null;
  }
}
