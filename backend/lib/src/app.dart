import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import 'auth.dart';
import 'config.dart';
import 'database.dart';
import 'gemini.dart';
import 'zakat.dart';

Handler createApp(AppConfig config, Database database) {
  final router = Router();
  final auth = AuthService(database, config);
  final gemini = GeminiService(config);

  router.get('/health', (Request _) => _json({'status': 'ok'}));
  router.post('/api/auth/register', (Request request) async {
    final body = await _body(request);
    return _json(await auth.register(_string(body, 'email'), _string(body, 'password')), 201);
  });
  router.post('/api/auth/login', (Request request) async {
    final body = await _body(request);
    return _json(await auth.login(_string(body, 'email'), _string(body, 'password')));
  });
  router.post('/api/calculate', (Request request) async {
    final input = ZakatInput.fromJson(await _body(request));
    return _json({'calculation': input.toJson()});
  });
  router.post('/api/assistant', (Request request) async {
    final body = await _body(request);
    final calculation = body['calculation'];
    if (calculation is! Map<String, dynamic>) {
      throw const FormatException('calculation must be a JSON object');
    }
    final input = ZakatInput.fromJson(calculation);
    return _json({'answer': await gemini.explain(input, _string(body, 'question'))});
  });
  router.get('/api/me', (Request request) {
    final user = _requireUser(request, auth);
    return _json({'user': {'id': user['sub'], 'email': user['email']}});
  });

  final pipeline = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(_cors())
      .addHandler(router.call);
  return (Request request) async {
    try {
      return await pipeline(request);
    } on AuthException catch (error) {
      return _error(error.message, error.statusCode);
    } on GeminiException catch (error) {
      return _error(error.message, error.statusCode);
    } on FormatException catch (error) {
      return _error(error.message, 400);
    } catch (error) {
      return _error('Internal server error', 500);
    }
  };
}

Future<Map<String, dynamic>> _body(Request request) async {
  final decoded = jsonDecode(await request.readAsString());
  if (decoded is! Map<String, dynamic>) throw const FormatException('JSON object required');
  return decoded;
}

String _string(Map<String, dynamic> body, String key) {
  final value = body[key];
  if (value is! String || value.trim().isEmpty) throw FormatException('$key is required');
  return value;
}

Map<String, dynamic> _requireUser(Request request, AuthService auth) {
  final header = request.headers['authorization'];
  if (header == null || !header.startsWith('Bearer ')) {
    throw const AuthException('Bearer token is required', 401);
  }
  return auth.verify(header.substring(7));
}

Response _json(Object body, [int status = 200]) => Response(
      status,
      body: jsonEncode(body),
      headers: {'content-type': 'application/json'},
    );

Response _error(String message, int status) => _json({'error': message}, status);

Middleware _cors() => (Handler handler) => (Request request) async {
      final response = await handler(request);
      return response.change(headers: {
        ...response.headers,
        'access-control-allow-origin': '*',
        'access-control-allow-headers': 'Content-Type, Authorization',
        'access-control-allow-methods': 'GET, POST, OPTIONS',
      });
    };
