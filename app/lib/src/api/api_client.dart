import 'dart:async';
import 'dart:convert';
import 'dart:io';

class ApiClient {
  ApiClient({
    required this.baseUri,
    this.accessToken,
    HttpClient? httpClient,
  }) : _httpClient = httpClient ?? HttpClient();

  final Uri baseUri;
  final String? accessToken;
  final HttpClient _httpClient;
  static const _timeout = Duration(seconds: 12);

  Future<Map<String, Object?>> getJson(String path) async {
    final request = await _open('GET', path);
    return _sendForJson(request);
  }

  Future<Map<String, Object?>> postJson(
    String path, {
    Map<String, Object?>? body,
  }) async {
    final request = await _open('POST', path);
    request.headers.contentType = ContentType.json;
    if (body != null) {
      request.write(jsonEncode(body));
    }
    return _sendForJson(request);
  }

  Future<Map<String, Object?>> putJson(
    String path, {
    Map<String, Object?>? body,
  }) async {
    final request = await _open('PUT', path);
    request.headers.contentType = ContentType.json;
    if (body != null) {
      request.write(jsonEncode(body));
    }
    return _sendForJson(request);
  }

  Future<HttpClientRequest> _open(String method, String path) async {
    final uri = baseUri.resolve(path);
    final request = await _httpClient.openUrl(method, uri).timeout(_timeout);
    request.headers.set(HttpHeaders.acceptHeader, ContentType.json.mimeType);
    final token = accessToken;
    if (token != null && token.isNotEmpty) {
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
    }
    return request;
  }

  Future<Map<String, Object?>> _sendForJson(HttpClientRequest request) async {
    try {
      final response = await request.close().timeout(_timeout);
      final text = await utf8.decodeStream(response).timeout(_timeout);
      final statusCode = response.statusCode;
      if (statusCode < 200 || statusCode >= 300) {
        throw ApiException(
          statusCode: statusCode,
          message: _readErrorMessage(text, response.reasonPhrase),
        );
      }
      if (text.isEmpty) {
        return const {};
      }
      final decoded = jsonDecode(text);
      if (decoded is Map<String, Object?>) {
        return decoded;
      }
      if (decoded is Map) {
        return decoded.map((key, value) => MapEntry('$key', value));
      }
      throw const FormatException('Expected a JSON object response.');
    } on TimeoutException {
      throw const ApiException(
        statusCode: 0,
        message: '请求超时，请确认后端服务是否已启动。',
      );
    } on SocketException catch (error) {
      throw ApiException(
        statusCode: 0,
        message: '无法连接后端服务：${error.message}',
      );
    }
  }

  String _readErrorMessage(String text, String fallback) {
    if (text.isEmpty) {
      return fallback;
    }
    try {
      final decoded = jsonDecode(text);
      if (decoded is Map) {
        final message = decoded['message'];
        if (message is String && message.isNotEmpty) {
          return message;
        }
        final error = decoded['error'];
        if (error is String && error.isNotEmpty) {
          return error;
        }
      }
    } catch (_) {
      // Fall back to the raw response text below.
    }
    return text;
  }
}

class ApiException implements Exception {
  const ApiException({
    required this.statusCode,
    required this.message,
  });

  final int statusCode;
  final String message;

  @override
  String toString() => message;
}
