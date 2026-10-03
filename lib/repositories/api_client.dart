import 'package:dio/dio.dart';

/// Error from the VINCÓ backend. [code] is the server code (e.g. EMAIL_TAKEN)
/// or a transport code: NETWORK, HTTP_<status>, BAD_RESPONSE.
class ApiException implements Exception {
  final String code;
  final String? detail;

  const ApiException(this.code, [this.detail]);

  @override
  String toString() => detail == null ? code : '$code: $detail';
}

/// RPC client: every call is POST /actions with {"action", "args"}.
/// Auth tokens travel inside args.token, never in headers.
class ApiClient {
  static const baseUrl = 'https://vinco-server-production.up.railway.app';

  final Dio _dio;

  ApiClient({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: baseUrl,
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 20),
              contentType: Headers.jsonContentType,
              responseType: ResponseType.json,
              validateStatus: (_) => true,
            ));

  /// Authenticated call: the session token travels inside args.token.
  Future<dynamic> sendAuthed(String action, String? token, [Map<String, dynamic> args = const {}]) async {
    if (token == null) throw const ApiException('SIGN_IN_REQUIRED');
    return send(action, {...args, 'token': token});
  }

  Future<dynamic> send(String action, [Map<String, dynamic> args = const {}]) async {
    final Response<dynamic> res;
    try {
      res = await _dio.post<dynamic>('/actions', data: {'action': action, 'args': args});
    } on DioException catch (e) {
      throw ApiException('NETWORK', e.message);
    }

    final body = res.data;
    final status = res.statusCode ?? 0;
    if (status != 200) {
      final detail = body is Map ? body['error']?.toString() : null;
      throw ApiException('HTTP_$status', detail);
    }
    if (body is! Map || !body.containsKey('data')) {
      throw ApiException('BAD_RESPONSE', body?.toString());
    }
    final data = body['data'];
    if (data is Map && data['ok'] == false) {
      throw ApiException(data['error']?.toString() ?? 'UNKNOWN');
    }
    return data;
  }
}
