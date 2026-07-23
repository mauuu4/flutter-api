import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

class ApiClient {
  static const String baseUrl = 'https://api-pizzas-7v98.onrender.com';

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
      };

  static Future<dynamic> get(String path) async {
    final response = await http.get(Uri.parse('$baseUrl$path'));
    return _handleResponse(response);
  }

  static Future<dynamic> post(String path, Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  static Future<dynamic> put(String path, Map<String, dynamic> body) async {
    final response = await http.put(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  static Future<void> delete(String path) async {
    final response = await http.delete(Uri.parse('$baseUrl$path'));
    if (response.statusCode >= 200 && response.statusCode < 300) return;
    _throwError(response);
  }

  static dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    }
    _throwError(response);
  }

  static Never _throwError(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      final message = decoded['message'] ?? 'Error en la petición';
      final details = decoded['errors'] ?? decoded['details'];
      if (details is List && details.isNotEmpty) {
        throw ApiException('$message: ${details.join(', ')}');
      }
      throw ApiException(message.toString());
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('Error ${response.statusCode} en la petición');
    }
  }
}
