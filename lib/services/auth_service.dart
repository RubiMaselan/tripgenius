import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class AuthService {
  static const String baseUrl = 'http://127.0.0.1/tripgenius';
  static const _storage = FlutterSecureStorage();

  static Future<String?> getToken() async {
    if (kIsWeb) {
      return html.window.localStorage['token'];
    }
    return await _storage.read(key: 'token');
  }

  static Future<void> saveToken(String token) async {
    if (kIsWeb) {
      html.window.localStorage['token'] = token;
    } else {
      await _storage.write(key: 'token', value: token);
    }
  }

  static Future<void> saveUser(User user) async {
    if (kIsWeb) {
      html.window.localStorage['user'] = jsonEncode(user.toJson());
    } else {
      await _storage.write(key: 'user', value: jsonEncode(user.toJson()));
    }
  }

  static Future<User?> getUser() async {
    String? raw;
    if (kIsWeb) {
      raw = html.window.localStorage['user'];
    } else {
      raw = await _storage.read(key: 'user');
    }
    if (raw == null) return null;
    return User.fromJson(jsonDecode(raw));
  }

  static Future<void> logout() async {
    if (kIsWeb) {
      html.window.localStorage.remove('token');
      html.window.localStorage.remove('user');
    } else {
      await _storage.deleteAll();
    }
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  static Future<Map<String, String>> authHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth.php?action=register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth.php?action=login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> updateProfile(String name) async {
    final headers = await AuthService.authHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/auth.php?action=profile'),
      headers: headers,
      body: jsonEncode({'name': name}),
    );
    return jsonDecode(response.body);
  }
}