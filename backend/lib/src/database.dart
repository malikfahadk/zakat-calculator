import 'package:postgres/postgres.dart';

import 'config.dart';

class Database {
  Database(this.config);

  final AppConfig config;
  late final Connection connection;

  Future<void> open() async {
    final uri = Uri.parse(config.databaseUrl);
    final userInfo = uri.userInfo.split(':');
    connection = await Connection.open(
      Endpoint(
        host: uri.host,
        port: uri.port == 0
            ? 5432
            : uri.port,
        database: uri.pathSegments.last,
        username: userInfo.first,
        password: userInfo.skip(1).join(':'),
      ),
      settings: const ConnectionSettings(sslMode: SslMode.disable),
    );
  }

  Future<void> close() => connection.close();
}
