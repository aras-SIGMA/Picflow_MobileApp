import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../utils/constants.dart';
import 'api_exception.dart';
import 'storage_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  return ApiService(storageService: storageService);
});

/// Lightweight API service wrapping package:http with auto JWT headers and USB reverse detection.
class ApiService {
  final http.Client _client;
  final StorageService storageService;

  ApiService({http.Client? client, required this.storageService})
    : _client = client ?? http.Client();

  Uri _buildUri(String path, [Map<String, dynamic>? queryParameters]) {
    final cleanBase = AppConstants.baseUrl.endsWith('/')
        ? AppConstants.baseUrl.substring(0, AppConstants.baseUrl.length - 1)
        : AppConstants.baseUrl;
    final cleanPath = path.startsWith('/') ? path : '/$path';
    final fullUrl = '$cleanBase$cleanPath';
    final uri = Uri.parse(fullUrl);

    if (queryParameters != null && queryParameters.isNotEmpty) {
      final Map<String, String> stringParams = {};
      queryParameters.forEach((key, value) {
        if (value != null) {
          stringParams[key] = value.toString();
        }
      });
      return uri.replace(queryParameters: stringParams);
    }
    return uri;
  }

  Future<Map<String, String>> _buildHeaders({
    bool auth = true,
    bool isJson = true,
  }) async {
    final headers = <String, String>{};
    if (isJson) {
      headers['Content-Type'] = 'application/json';
      headers['Accept'] = 'application/json';
    }

    if (auth) {
      final token = await storageService.getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  dynamic _processResponse(http.Response response) {
    dynamic bodyData;
    try {
      if (response.body.isNotEmpty) {
        bodyData = jsonDecode(response.body);
      }
    } catch (_) {
      // Body may not be JSON on certain error responses
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return bodyData;
    }

    String message = 'Terjadi kesalahan pada server (${response.statusCode})';
    List<String> errors = [];

    if (bodyData is Map<String, dynamic>) {
      if (bodyData['message'] is String) {
        message = bodyData['message'];
      }
      if (bodyData['errors'] is List) {
        errors = (bodyData['errors'] as List).map((e) => e.toString()).toList();
      }
    }

    throw ApiException(
      message: message,
      statusCode: response.statusCode,
      errors: errors,
    );
  }

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool auth = true,
  }) async {
    try {
      final uri = _buildUri(path, queryParameters);
      final headers = await _buildHeaders(auth: auth);
      final response = await _client
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 15));
      return _processResponse(response);
    } on SocketException catch (e) {
      throw NetworkConnectionException(e.message);
    } on http.ClientException catch (e) {
      throw NetworkConnectionException(e.message);
    } on TimeoutException {
      throw NetworkConnectionException('Request timeout');
    }
  }

  Future<dynamic> post(String path, {dynamic body, bool auth = true}) async {
    try {
      final uri = _buildUri(path);
      final headers = await _buildHeaders(auth: auth);
      final payload = body != null ? jsonEncode(body) : null;
      final response = await _client
          .post(uri, headers: headers, body: payload)
          .timeout(const Duration(seconds: 20));
      return _processResponse(response);
    } on SocketException catch (e) {
      throw NetworkConnectionException(e.message);
    } on http.ClientException catch (e) {
      throw NetworkConnectionException(e.message);
    } on TimeoutException {
      throw NetworkConnectionException('Request timeout');
    }
  }

  Future<dynamic> put(String path, {dynamic body, bool auth = true}) async {
    try {
      final uri = _buildUri(path);
      final headers = await _buildHeaders(auth: auth);
      final payload = body != null ? jsonEncode(body) : null;
      final response = await _client
          .put(uri, headers: headers, body: payload)
          .timeout(const Duration(seconds: 20));
      return _processResponse(response);
    } on SocketException catch (e) {
      throw NetworkConnectionException(e.message);
    } on http.ClientException catch (e) {
      throw NetworkConnectionException(e.message);
    } on TimeoutException {
      throw NetworkConnectionException('Request timeout');
    }
  }

  Future<dynamic> delete(String path, {dynamic body, bool auth = true}) async {
    try {
      final uri = _buildUri(path);
      final headers = await _buildHeaders(auth: auth);
      final payload = body != null ? jsonEncode(body) : null;
      final response = await _client
          .delete(uri, headers: headers, body: payload)
          .timeout(const Duration(seconds: 15));
      return _processResponse(response);
    } on SocketException catch (e) {
      throw NetworkConnectionException(e.message);
    } on http.ClientException catch (e) {
      throw NetworkConnectionException(e.message);
    } on TimeoutException {
      throw NetworkConnectionException('Request timeout');
    }
  }

  Future<dynamic> multipart(
    String path, {
    String method = 'POST',
    Map<String, String>? fields,
    List<http.MultipartFile>? files,
    bool auth = true,
  }) async {
    try {
      final uri = _buildUri(path);
      final request = http.MultipartRequest(method, uri);

      final headers = await _buildHeaders(auth: auth, isJson: false);
      request.headers.addAll(headers);

      if (fields != null) {
        request.fields.addAll(fields);
      }
      if (files != null) {
        request.files.addAll(files);
      }

      final streamedResponse = await _client
          .send(request)
          .timeout(const Duration(seconds: 60));
      final response = await http.Response.fromStream(streamedResponse);
      return _processResponse(response);
    } on SocketException catch (e) {
      throw NetworkConnectionException(e.message);
    } on http.ClientException catch (e) {
      throw NetworkConnectionException(e.message);
    } on TimeoutException {
      throw NetworkConnectionException('Upload timeout');
    }
  }
}
