import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  static const _webBaseUrls = [
    'http://localhost:8080/flutter.api',
    'http://localhost/flutter.api',
  ];
  static const _mobileBaseUrls = [
    'http://10.0.2.2:8080/flutter.api',
    'http://10.0.2.2/flutter.api',
  ];

  static List<String> get _baseUrls {
    if (kIsWeb) {
      return _webBaseUrls;
    }
    return _mobileBaseUrls;
  }

  final http.Client _client;

  ApiClient([http.Client? client]) : _client = client ?? http.Client();

  Future<Map<String, dynamic>> get(
    String path, [
    Map<String, String>? query,
  ]) async {
    return await _requestWithFallback(
      (uri) => _client.get(uri, headers: _defaultHeaders()),
      path,
      query,
    );
  }

  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body,
  ) async {
    return await _requestWithFallback(
      (uri) =>
          _client.post(uri, headers: _defaultHeaders(), body: jsonEncode(body)),
      path,
    );
  }

  Future<Map<String, dynamic>> postForm(
    String path,
    Map<String, String> fields,
  ) async {
    return await _requestWithFallback(
      (uri) => _client.post(uri, headers: _defaultHeaders(), body: fields),
      path,
    );
  }

  Future<Map<String, dynamic>> uploadFile(
    String path,
    String fileField,
    String filePath, {
    Map<String, String>? fields,
    List<int>? fileBytes,
    String? fileName,
  }) async {
    for (final baseUrl in _baseUrls) {
      try {
        final uri = Uri.parse('$baseUrl/$path');
        final request = http.MultipartRequest('POST', uri)
          ..headers.addAll({'Accept': 'application/json'})
          ..fields.addAll(fields ?? {});

        if (fileBytes != null) {
          final file = http.MultipartFile.fromBytes(
            fileField,
            fileBytes,
            filename: fileName ?? 'upload.bin',
          );
          request.files.add(file);
        } else {
          final file = await http.MultipartFile.fromPath(fileField, filePath);
          request.files.add(file);
        }

        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);
        return _decodeResponse(response);
      } catch (e) {
        if (kDebugMode) {
          // ignore: avoid_print
          print('Upload attempt failed for $baseUrl: $e');
        }
      }
    }
    return {
      'success': false,
      'message': 'Unable to reach backend. Checked: ${_baseUrls.join(', ')}',
    };
  }

  Future<Map<String, dynamic>> _requestWithFallback(
    Future<http.Response> Function(Uri) requestFn,
    String path, [
    Map<String, String>? query,
  ]) async {
    for (final baseUrl in _baseUrls) {
      try {
        final uri = Uri.parse('$baseUrl/$path').replace(queryParameters: query);
        print('📡 Attempting request to: $uri');
        final response = await requestFn(uri);
        print('📡 Response status: ${response.statusCode}');
        print('📡 Response body: ${response.body}');
        return _decodeResponse(response);
      } catch (e) {
        if (kDebugMode) {
          // ignore: avoid_print
          print('❌ Request attempt failed for $baseUrl: $e');
        }
      }
    }
    return {
      'success': false,
      'message': 'Unable to reach backend. Checked: ${_baseUrls.join(', ')}',
    };
  }

  Map<String, String> _defaultHeaders() => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Map<String, dynamic> _decodeResponse(http.Response response) {
    final body = response.body.isEmpty ? '{}' : response.body;
    try {
      final decoded = jsonDecode(body) as Map<String, dynamic>;
      print('✅ Response decoded successfully: $decoded');
      return decoded;
    } catch (e) {
      print('❌ Failed to decode response: $e');
      print('   Raw body: $body');
      return {
        'success': false,
        'message': 'Unable to parse server response',
        'statusCode': response.statusCode,
      };
    }
  }
}
