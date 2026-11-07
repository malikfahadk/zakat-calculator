import 'package:dotenv/dotenv.dart';

class AppConfig {
  const AppConfig({
    required this.port,
    required this.databaseUrl,
    required this.jwtSecret,
    required this.geminiApiKey,
    required this.geminiModel,
  });

  factory AppConfig.fromEnvironment(DotEnv env) {
    final databaseUrl = env['DATABASE_URL'];
    final jwtSecret = env['JWT_SECRET'];
    if (databaseUrl == null || databaseUrl.isEmpty) {
      throw StateError('DATABASE_URL is required');
    }
    if (jwtSecret == null || jwtSecret.length < 32) {
      throw StateError('JWT_SECRET must be at least 32 characters');
    }
    return AppConfig(
      port: int.tryParse(env['PORT'] ?? '') ?? 8080,
      databaseUrl: databaseUrl,
      jwtSecret: jwtSecret,
      geminiApiKey: env['GEMINI_API_KEY'],
      geminiModel: env['GEMINI_MODEL'] ?? 'gemini-2.5-flash',
    );
  }

  final int port;
  final String databaseUrl;
  final String jwtSecret;
  final String? geminiApiKey;
  final String geminiModel;
}
