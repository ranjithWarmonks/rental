import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';
import 'api_name.dart' as api_const;

class ApiManager {
  static String get baseUrl => api_const.baseUrl;

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("user_token") ?? prefs.getString("token");
    return token;
  }

  /// Common headers (with optional token)
  static Future<Map<String, String>> _headers({bool withToken = true}) async {
    final headers = {
      "Content-Type": "application/json",
      "Accept": "application/json",
    };

    if (withToken) {
      final token = await _getToken();
      if (token != null && token.isNotEmpty) {
        headers["Authorization"] = "Bearer $token";
        debugPrint(token);
      }
    }
    return headers;
  }

  // GET Request
  static Future<dynamic> get(
    String endpoint, {
    Map<String, String>? queryParams,
  }) async {
    try {
      final uri = Uri.parse(endpoint);
      final response = await http.get(
        uri,
        headers: await _headers(withToken: true),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception("GET Error: $e");
    }
  }

  // GET Request returning http.Response object
  Future<http.Response> getCall(String endpoint) async {
    final uri = Uri.parse(endpoint);

    debugPrint(endpoint);

    var response=await http.get(
      uri,
      headers: await _headers(withToken: true),
    );

    debugPrint(response.body);
    return response;

  }

  // POST Request
  static Future<dynamic> post(
    String endpoint, {
    dynamic body,
    bool withUrl = false,
  }) async {
    try {
      final uri = Uri.parse(endpoint);
      final response = await http.post(
        uri,
        headers: await _headers(withToken: true),
        body: body is String ? body : jsonEncode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception("POST Error: $e");
    }
  }

  // POST Request returning http.Response object
  Future<http.Response> postCall(String endpoint, dynamic body) async {
    final uri = Uri.parse(endpoint);

    debugPrint(jsonEncode(body));
   var response=  await http.post(
      uri,
      headers: await _headers(withToken: true),
      body: body is String ? body : jsonEncode(body),
    );
    print(body);

   debugPrint(response.body);
    return response;
  }

  // PATCH Request
  static Future<dynamic> patch(
    String endpoint, {
    dynamic body,
  }) async {
    try {
      final uri = Uri.parse(endpoint);
      final response = await http.patch(
        uri,
        headers: await _headers(withToken: true),
        body: body is String ? body : jsonEncode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception("PATCH Error: $e");
    }
  }

  // PATCH Request returning http.Response object
  Future<http.Response> patchCall(String endpoint, dynamic body) async {
    final uri = Uri.parse(endpoint);
    return await http.patch(
      uri,
      headers: await _headers(withToken: true),
      body: body is String ? body : jsonEncode(body),
    );
  }

  // PUT Request returning http.Response object
  Future<http.Response> putCall(String endpoint, dynamic body) async {
    final uri = Uri.parse(endpoint);
    debugPrint(jsonEncode(body));
    var response = await http.put(
      uri,
      headers: await _headers(withToken: true),
      body: body is String ? body : jsonEncode(body),
    );
    debugPrint(response.body);
    return response;
  }

  // PUT Request
  static Future<dynamic> put(
    String endpoint, {
    dynamic body,
  }) async {
    try {
      final uri = Uri.parse(endpoint);
      final response = await http.put(
        uri,
        headers: await _headers(withToken: true),
        body: body is String ? body : jsonEncode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception("PUT Error: $e");
    }
  }

  // DELETE Request
  static Future<dynamic> delete(
    String endpoint, {
    dynamic body,
  }) async {
    try {
      final uri = Uri.parse(endpoint);
      final response = await http.delete(
        uri,
        headers: await _headers(withToken: true),
        body: body != null ? (body is String ? body : jsonEncode(body)) : null,
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception("DELETE Error: $e");
    }
  }

  // DELETE Request returning http.Response object
  Future<http.Response> deleteCall(String endpoint) async {
    final uri = Uri.parse(endpoint);
    return await http.delete(
      uri,
      headers: await _headers(withToken: true),
    );
  }

  // MULTIPART POST
  static Future<dynamic> multipartPost(
    String endpoint, {
    required Map<String, String> fields,
    required String fileKey,
    String? filePath,
  }) async {
    try {
      final uri = Uri.parse(endpoint);
      final request = http.MultipartRequest("POST", uri);
      final headers = await _headers(withToken: true);
      headers.remove("Content-Type");
      request.headers.addAll(headers);
      request.fields.addAll(fields);

      if (filePath != null && filePath.isNotEmpty) {
        final extension = filePath.split('.').last.toLowerCase();
        MediaType? contentType;
        if (extension == 'jpg' || extension == 'jpeg') {
          contentType = MediaType('image', 'jpeg');
        } else if (extension == 'png') {
          contentType = MediaType('image', 'png');
        } else if (extension == 'webp') {
          contentType = MediaType('image', 'webp');
        }

        request.files.add(
          await http.MultipartFile.fromPath(
            fileKey,
            filePath,
            contentType: contentType,
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } catch (e) {
      throw Exception("Multipart POST Error: $e");
    }
  }

  // Common Response Handler
  static dynamic _handleResponse(http.Response response) async {
    final statusCode = response.statusCode;
    final responseBody =
        response.body.isNotEmpty ? jsonDecode(response.body) : null;

    if (statusCode >= 200 && statusCode < 300) {
      return responseBody;
    } else if (statusCode == 401) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.clear();
      throw Exception("Unauthorized (401) - Token expired");
    } else if (statusCode == 403) {
      throw Exception("Forbidden (403)");
    } else if (statusCode == 404) {
      throw Exception("API Not Found (404)");
    } else if (statusCode >= 500) {
      throw Exception("Server Error ($statusCode)");
    } else {
      throw Exception(
        responseBody?["message"] ?? "Request failed ($statusCode)",
      );
    }
  }
}