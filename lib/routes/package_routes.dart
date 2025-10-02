// backend_assistente/lib/routes/package_routes.dart

import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/gemini_service.dart';
import '../services/package_service.dart';

Router packageRoutes(GeminiService geminiService, PackageService packageService) {
  final router = Router();

  router.get('/ping', (req) => Response.ok(jsonEncode({'status': 'ok', 'message': 'pong'}),
      headers: {'content-type': 'application/json'}));

  router.get('/packages/all', (req) async {
    final packages = await packageService.getAllPackages();
    return Response.ok(
      jsonEncode({'success': true, 'packages': packages.map((p) => p.toJson()).toList()}),
      headers: {'content-type': 'application/json'}
    );
  });

  router.post('/packages/suggest', (req) async {
    try {
      final content = await req.readAsString();
      final data = jsonDecode(content);

      final needs = data['needs'] as String? ?? '';
      final budget = (data['budget'] as num? ?? 0.0).toDouble();

      final availablePackages = await packageService.getAllPackages();

      // --- INÍCIO DA MELHORIA ---
      // Se o usuário pedir para ver todos os planos, retornamos a lista completa
      // sem precisar consultar a IA.
      final userRequest = needs.toLowerCase();
      if (userRequest.contains('todos') || userRequest.contains('tudo')) {
        return Response.ok(
            jsonEncode({
              'success': true,
              'suggestions': availablePackages.map((p) => p.toJson()).toList()
            }),
            headers: {'content-type': 'application/json'});
      }
      // --- FIM DA MELHORIA ---

      final query = 'O que preciso: $needs. Orçamento máximo: R\$${budget.toStringAsFixed(2)}.';
      final suggested = await geminiService.suggestPackages(query, availablePackages);

      if (suggested.isEmpty) {
        return Response.ok(
            jsonEncode({'success': false, 'message': 'Nenhuma sugestão encontrada.'}),
            headers: {'content-type': 'application/json'});
      }

      return Response.ok(
          jsonEncode({'success': true, 'suggestions': suggested.map((p) => p.toJson()).toList()}),
          headers: {'content-type': 'application/json'});

    } on FormatException catch (e) {
      return Response.badRequest(
          body: jsonEncode({'success': false, 'error': 'JSON inválido: ${e.message}'}),
          headers: {'content-type': 'application/json'});
    } catch (e) {
      print('Erro interno no endpoint /packages/suggest: $e');
      return Response.internalServerError(
          body: jsonEncode({'success': false, 'error': 'Erro interno do servidor.'}),
          headers: {'content-type': 'application/json'});
    }
  });

  return router;
}