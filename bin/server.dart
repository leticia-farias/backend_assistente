import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:shelf_router/shelf_router.dart';

// --- NOVOS IMPORTS ---
import 'package:postgres/postgres.dart'; // Importa o pacote do postgres
import 'package:backend_server/database/db_configuration.dart'; // Importa nosso gerenciador de conexão

// --- SEUS IMPORTS EXISTENTES ---
import 'package:backend_server/services/gemini_service.dart';
import 'package:backend_server/services/package_service.dart';
import 'package:backend_server/routes/package_routes.dart';

/// Ponto de entrada do servidor
Future<void> main() async {
  // --- PASSO 1: INICIALIZAR A CONEXÃO COM O BANCO DE DADOS ---
  // A conexão é estabelecida antes de qualquer outra coisa.
  // Se falhar, o servidor não irá iniciar.
  final dbConfig = await DbConfiguration.create();
  final dbConnection = dbConfig.connection;

  // --- PASSO 2: INJETAR A CONEXÃO NOS SERVIÇOS ---
  // O GeminiService não parece precisar do banco, então permanece igual.
  final geminiService = GeminiService(); 
  
  // O PackageService agora recebe a conexão com o banco em seu construtor.
  // (Você precisará ajustar a classe PackageService para aceitar isso).
  final packageService = PackageService(dbConnection);

  // O resto do seu código permanece praticamente o mesmo
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