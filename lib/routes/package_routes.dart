import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/gemini_service.dart';
import '../services/package_service.dart';

/// Define as rotas relacionadas a pacotes
Router packageRoutes(GeminiService geminiService, PackageService packageService) {
  final router = Router();

  // Endpoint de teste de servidor
  router.get('/ping', (req) => Response.ok(jsonEncode({'status': 'ok', 'message': 'pong'}),
      headers: {'content-type': 'application/json'}));

  // Retorna todos os pacotes mockados
  // router.get('/packages/all', (req) => Response.ok(
  //     jsonEncode({'success': true, 'packages': packageService.all.map((p) => p.toJson()).toList()}),
  //     headers: {'content-type': 'application/json'}));

  // Sugere pacotes com base nas necessidades e orçamento do usuário
  // router.post('/packages/suggest', (req) async {
  //   try {
  //     final content = await req.readAsString();
  //     final data = jsonDecode(content);

  //     final needs = data['needs'] as String? ?? '';
  //     final budget = (data['budget'] as num? ?? 0.0).toDouble();

  //     // Cria consulta amigável para o Gemini
  //     final query = 'O que preciso: $needs. Orçamento máximo: R\$${budget.toStringAsFixed(2)}.';
  //     final suggested = await geminiService.suggestPackages(query, packageService.all);

  //     if (suggested.isEmpty) {
  //       return Response.ok(
  //           jsonEncode({'success': false, 'message': 'Nenhuma sugestão encontrada.'}),
  //           headers: {'content-type': 'application/json'});
  //     }

  //     return Response.ok(
  //         jsonEncode({'success': true, 'suggestions': suggested.map((p) => p.toJson()).toList()}),
  //         headers: {'content-type': 'application/json'});
  //   } catch (e) {
  //     return Response.internalServerError(
  //         body: jsonEncode({'success': false, 'error': e.toString()}),
  //         headers: {'content-type': 'application/json'});
  //   }
  // });

  return router;
}