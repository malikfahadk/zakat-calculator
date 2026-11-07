import 'package:bcrypt/bcrypt.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:postgres/postgres.dart';
import 'package:uuid/uuid.dart';

import 'config.dart';
import 'database.dart';

class AuthService {
  AuthService(this.database, this.config);

  final Database database;
  final AppConfig config;
  static const _uuid = Uuid();

  Future<Map<String, dynamic>> register(String email, String password) async {
    _validateCredentials(email, password);
    final normalizedEmail = email.trim().toLowerCase();
    final id = _uuid.v4();
    final hash = BCrypt.hashpw(password, BCrypt.gensalt());
    try {
      await database.connection.execute(
        Sql.named(
          'INSERT INTO users (id, email, password_hash) '
          'VALUES (@id, @email, @password_hash)',
        ),
        parameters: {'id': id, 'email': normalizedEmail, 'password_hash': hash},
      );
    } on ServerException catch (error) {
      if (error.code == '23505') {
        throw AuthException('An account with this email already exists', 409);
      }
      rethrow;
    }
    return _session(id, normalizedEmail);
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    _validateCredentials(email, password);
    final rows = await database.connection.execute(
      Sql.named('SELECT id, email, password_hash FROM users WHERE email = @email'),
      parameters: {'email': email.trim().toLowerCase()},
    );
    if (rows.isEmpty || !BCrypt.checkpw(password, rows.first[2] as String)) {
      throw AuthException('Invalid email or password', 401);
    }
    return _session(rows.first[0] as String, rows.first[1] as String);
  }

  Map<String, dynamic> verify(String token) {
    try {
      final payload = JWT.verify(token, SecretKey(config.jwtSecret)).payload;
      return Map<String, dynamic>.from(payload as Map);
    } on JWTException {
      throw AuthException('Invalid or expired token', 401);
    }
  }

  Map<String, dynamic> _session(String id, String email) {
    final token = JWT({
      'sub': id,
      'email': email,
    }).sign(SecretKey(config.jwtSecret), expiresIn: const Duration(days: 30));
    return {'token': token, 'user': {'id': id, 'email': email}};
  }

  void _validateCredentials(String email, String password) {
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email.trim())) {
      throw AuthException('A valid email is required', 400);
    }
    if (password.length < 8) {
      throw AuthException('Password must be at least 8 characters', 400);
    }
  }
}

class AuthException implements Exception {
  const AuthException(this.message, this.statusCode);

  final String message;
  final int statusCode;
}
