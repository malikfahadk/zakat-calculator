import 'dart:io';

import 'package:dotenv/dotenv.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

import '../lib/src/app.dart';
import '../lib/src/config.dart';
import '../lib/src/database.dart';

Future<void> main() async {
  final env = DotEnv(includePlatformEnvironment: true)..load();
  final config = AppConfig.fromEnvironment(env);
  final database = Database(config);
  await database.open();

  final handler = createApp(config, database);
  final server = await shelf_io.serve(
    handler,
    InternetAddress.anyIPv4,
    config.port,
  );
  server.autoCompress = true;
  stdout.writeln('Zakat API listening on http://${server.address.host}:${server.port}');

  ProcessSignal.sigint.watch().listen((_) async {
    await database.close();
    await server.close();
    exit(0);
  });
}
