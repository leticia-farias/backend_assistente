import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:backend_server/services/gemini_service.dart';
import 'package:backend_server/services/package_service.dart';
import 'package:backend_server/routes/package_routes.dart';

/// Ponto de entrada do servidor
Future<void> main() async {
  final geminiService = GeminiService(); // Serviço Gemini
  final packageService = PackageService(); // Serviço de pacotes

  // Cria o router principal com as rotas de pacotes
  final router = Router()
    ..mount('/', packageRoutes(geminiService, packageService));

  // Middleware: logs e CORS
  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsHeaders(headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
        'Access-Control-Allow-Headers': 'Origin, Content-Type',
      }))
      .addHandler(router);

  // Inicializa o servidor
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await io.serve(handler, InternetAddress.anyIPv4, port);
  print('Rodando em porta $port');
}
