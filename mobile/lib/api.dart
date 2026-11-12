import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config.dart';

class ApiError implements Exception {
  final String message;
  final int? status;
  const ApiError(this.message, [this.status]);
  @override
  String toString() => message;
}

class Api {
  final http.Client _client;
  bool readOnly = false;
  Future<String?> Function() token = () async => null;
  Api({http.Client? client}) : _client = client ?? http.Client();
  Future<dynamic> request(String method, String path, {Object? body}) async {
    if (readOnly) {
      throw const ApiError(
        'Você está no modo offline. Entre na conta com conexão para atualizar ou enviar alterações.',
      );
    }
    final auth = await token();
    final request = http.Request(method, Uri.parse('${Config.api}$path'));
    request.headers['Content-Type'] = 'application/json';
    if (auth != null) request.headers['Authorization'] = 'Bearer $auth';
    if (body != null) request.body = jsonEncode(body);
    try {
      final response = await (() async {
        final stream = await _client.send(request);
        return http.Response.fromStream(stream);
      })().timeout(const Duration(seconds: 12));
      final payload = response.body.isEmpty ? null : jsonDecode(response.body);
      if (response.statusCode >= 400) {
        throw ApiError(
          payload?['error'] ?? 'Falha ao conectar.',
          response.statusCode,
        );
      }
      return payload;
    } on TimeoutException {
      throw const ApiError('A conexão demorou. Tente novamente.');
    } on http.ClientException {
      throw const ApiError(
        'Não foi possível acessar o servidor. Verifique a conexão e o endereço da API.',
      );
    } on FormatException {
      throw const ApiError('O servidor retornou uma resposta inválida.');
    }
  }

  void close() => _client.close();
}
