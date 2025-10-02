import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:shelf_router/shelf_router.dart';

// --- IMPORTS PARA VARIÁVEIS DE AMBIENTE E BANCO DE DADOS ---
import 'package:dotenv/dotenv.dart'; // Importação corrigida
import 'package:backend_server/database/db_configuration.dart'; 

// --- SEUS IMPORTS EXISTENTES ---
import 'package:backend_server/services/gemini_service.dart';
import 'package:backend_server/services/package_service.dart';
import 'package:backend_server/routes/package_routes.dart';

/// Ponto de entrada do servidor
Future<void> main() async {
  // Carrega as variáveis de ambiente do arquivo .env
  // Usamos DotEnv().load() para ser mais explícito
  DotEnv().load();

  // O resto do seu código permanece o mesmo
  final dbConfig = await DbConfiguration.create();
  final dbConnection = dbConfig.connection;

  final geminiService = GeminiService();
  final packageService = PackageService(dbConnection);

  final router = Router()
    ..mount('/', packageRoutes(geminiService, packageService));

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