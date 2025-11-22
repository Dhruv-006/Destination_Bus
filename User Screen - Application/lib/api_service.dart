import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Change this to your Flask server URL
  // For Android emulator: use http://10.0.2.2:5000
  // For iOS simulator: use http://localhost:5000
  // For physical device: use your computer's IP address, e.g., http://192.168.1.100:5000
  static const String baseUrl = 'http://10.0.2.2:5000/api/public';
  
  // Get all buses
  static Future<List<Map<String, dynamic>>> getBuses() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/buses'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load buses: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching buses: $e');
      throw Exception('Failed to load buses: $e');
    }
  }
  
  // Get all routes
  static Future<List<Map<String, dynamic>>> getRoutes() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/routes'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load routes: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching routes: $e');
      throw Exception('Failed to load routes: $e');
    }
  }
  
  // Get all drivers
  static Future<List<Map<String, dynamic>>> getDrivers() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/drivers'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load drivers: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching drivers: $e');
      throw Exception('Failed to load drivers: $e');
    }
  }
  
  // Update bus location
  static Future<bool> updateLocation({
    required int busId,
    required double lat,
    required double lng,
    double? speed,
    int? occupancy,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/location-update'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'bus_id': busId,
          'lat': lat,
          'lng': lng,
          'speed': speed ?? 0,
          'occupancy': occupancy ?? 0,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error updating location: $e');
      return false;
    }
  }
}

