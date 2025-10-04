import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:shelf_router/shelf_router.dart';

import 'package:dotenv/dotenv.dart';
import 'package:backend_server/database/db_configuration.dart';

import 'package:backend_server/services/gemini_service.dart';
import 'package:backend_server/services/package_service.dart';
import 'package:backend_server/routes/package_routes.dart';

// --- NOVAS IMPORTAÇÕES ---
import 'package:backend_server/services/auth_service.dart';
import 'package:backend_server/routes/auth_routes.dart';

Future<void> main() async {
  DotEnv().load();

  final dbConfig = await DbConfiguration.create();
  final dbConnection = dbConfig.connection;

  final geminiService = GeminiService();
  final packageService = PackageService(dbConnection);
  final authService = AuthService(dbConnection); // --- NOVO SERVIÇO ---

  final router = Router()
    ..mount('/packages/', packageRoutes(geminiService, packageService))
    ..mount('/auth/', authRoutes(authService)); // --- NOVAS ROTAS ---

  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsHeaders(headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
        'Access-Control-Allow-Headers': 'Origin, Content-Type',
      }))
      .addHandler(router);

  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await io.serve(handler, InternetAddress.anyIPv4, port);
  print('✅ Servidor rodando na porta ${server.port}');
}