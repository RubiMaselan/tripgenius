import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/trip_input.dart';
import '../models/itinerary.dart';
import 'auth_service.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1/tripgenius';

  // Encode token safely for URL
  Future<String> _encodedToken() async {
    final token = await AuthService.getToken() ?? '';
    return Uri.encodeComponent(token);
  }

  Future<Itinerary> generateItinerary(TripInput input) async {
    final token = await AuthService.getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/generate.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({...input.toJson(), 'token': token}),
    );
    print('Generate response: ${response.body}');
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded.containsKey('error')) throw Exception(decoded['error']);
      return Itinerary.fromJson(decoded);
    }
    throw Exception('Server error: ${response.body}');
  }

  Future<List<Itinerary>> getSavedTrips() async {
    final token = await _encodedToken();
    final response = await http.get(
      Uri.parse('$baseUrl/trips.php?token=$token'),
      headers: {'Content-Type': 'application/json'},
    );
    print('Trips response: ${response.body}');
    final List data = jsonDecode(response.body);
    return data.map((e) => Itinerary.fromJson(e)).toList();
  }

  Future<void> deleteTrip(String id) async {
    final token = await _encodedToken();
    await http.delete(
      Uri.parse('$baseUrl/trips.php?id=$id&token=$token'),
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<List<Map<String, dynamic>>> getDestinations({String search = ''}) async {
    final token = await _encodedToken();
    final response = await http.get(
      Uri.parse('$baseUrl/destinations.php?search=$search&token=$token'),
      headers: {'Content-Type': 'application/json'},
    );
    final List data = jsonDecode(response.body);
    return data.cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> getDestinationDetail(int id) async {
    final token = await _encodedToken();
    final response = await http.get(
      Uri.parse('$baseUrl/destinations.php?id=$id&token=$token'),
      headers: {'Content-Type': 'application/json'},
    );
    return jsonDecode(response.body);
  }

  Future<List<Map<String, dynamic>>> getWishlist() async {
    final token = await _encodedToken();
    final response = await http.get(
      Uri.parse('$baseUrl/wishlist.php?token=$token'),
      headers: {'Content-Type': 'application/json'},
    );
    final List data = jsonDecode(response.body);
    return data.cast<Map<String, dynamic>>();
  }

  Future<void> addToWishlist(int destinationId) async {
    final token = await _encodedToken();
    await http.post(
      Uri.parse('$baseUrl/wishlist.php?token=$token'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'destination_id': destinationId}),
    );
  }

  Future<void> removeFromWishlist(int id) async {
    final token = await _encodedToken();
    await http.delete(
      Uri.parse('$baseUrl/wishlist.php?id=$id&token=$token'),
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<Map<String, dynamic>> getBudget(String tripId) async {
    final token = await _encodedToken();
    final response = await http.get(
      Uri.parse('$baseUrl/budget.php?trip_id=$tripId&token=$token'),
      headers: {'Content-Type': 'application/json'},
    );
    return jsonDecode(response.body);
  }

  Future<void> saveBudget(Map<String, dynamic> budget) async {
    final token = await _encodedToken();
    await http.post(
      Uri.parse('$baseUrl/budget.php?token=$token'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(budget),
    );
  }

  Future<List<Map<String, dynamic>>> getTransport(
      {String from = '', String to = ''}) async {
    final token = await _encodedToken();
    final response = await http.get(
      Uri.parse('$baseUrl/transport.php?from=$from&to=$to&token=$token'),
      headers: {'Content-Type': 'application/json'},
    );
    final List data = jsonDecode(response.body);
    return data.cast<Map<String, dynamic>>();
  }
}