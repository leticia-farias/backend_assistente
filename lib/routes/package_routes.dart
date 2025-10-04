import 'dart:convert'; 
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/gemini_service.dart';
import '../services/package_service.dart';

// --- SERVIÇOS ADICIONAIS (a serem criados) ---
// Para buscar dados de usuário e score
// import '../services/user_service.dart';
// import '../services/score_service.dart';

Router packageRoutes(
    GeminiService geminiService,
    PackageService packageService,
    // UserService userService, // Adicionar quando criar o serviço
    // ScoreService scoreService, // Adicionar quando criar o serviço
) {
  final router = Router();

  router.get(
      '/ping',
      (req) => Response.ok(jsonEncode({'status': 'ok', 'message': 'pong'}),
          headers: {'content-type': 'application/json'}));

  router.get('/packages/all', (req) async {
    final packages = await packageService.getAllPackages();
    return Response.ok(
        jsonEncode({
          'success': true,
          'packages': packages.map((p) => p.toJson()).toList()
        }),
        headers: {'content-type': 'application/json'});
  });

  router.post('/packages/suggest', (req) async {
    try {
      final content = await req.readAsString();
      final data = jsonDecode(content);

      final needs = data['needs'] as String? ?? '';
      final budget = (data['budget'] as num? ?? 0.0).toDouble();
      
      // --- MELHORIA: IDENTIFICAR O USUÁRIO ---
      // No mundo real, você obteria o ID do usuário a partir de um token de autenticação (JWT, por exemplo)
      // Por enquanto, vamos simular com um ID fixo para exemplificar.
      final userId = data['userId'] as int? ?? 1; // Simulando que o João (ID 1) está logado

      final availablePackages = await packageService.getAllPackages();
      
      final userRequest = needs.toLowerCase();
      if (userRequest.contains('todos') || userRequest.contains('tudo')) {
        return Response.ok(
            jsonEncode({
              'success': true,
              'suggestions': availablePackages.map((p) => p.toJson()).toList()
            }),
            headers: {'content-type': 'application/json'});
      }

      // --- MELHORIA: ENRIQUECER O PROMPT COM DADOS DO USUÁRIO ---
      String query;

      // --- LÓGICA DE EXEMPLO PARA BUSCAR USUÁRIO E SCORE ---
      // Você precisará criar um UserService e ScoreService para implementar a lógica abaixo
      /*
      final user = await userService.findUserById(userId);
      final score = await scoreService.findScoreByUserId(userId);

      if (user != null && score != null) {
        query = '''
          O usuário ${user.name}, que atualmente tem o plano ${user.currentPlan}, pediu: "$needs".
          Ele tem um orçamento de R\$${budget.toStringAsFixed(2)}.
          Seu perfil de cliente é: ${score.loyaltyScore > 70 ? 'premium' : 'padrão'}.
          Sugira o melhor plano para ele com base nas opções disponíveis, levando em conta seu perfil.
          ''';
      } else {
      */
        // Fallback para novos usuários ou se não encontrar os dados
        query =
            'O que preciso: $needs. Orçamento máximo: R\$${budget.toStringAsFixed(2)}.';
      /*
      }
      */

      final suggested =
          await geminiService.suggestPackages(query, availablePackages);

      if (suggested.isEmpty) {
        return Response.ok(
            jsonEncode(
                {'success': false, 'message': 'Nenhuma sugestão encontrada.'}),
            headers: {'content-type': 'application/json'});
      }

      return Response.ok(
          jsonEncode({
            'success': true,
            'suggestions': suggested.map((p) => p.toJson()).toList()
          }),
          headers: {'content-type': 'application/json'});
    } on FormatException catch (e) {
      return Response.badRequest(
          body:
              jsonEncode({'success': false, 'error': 'JSON inválido: ${e.message}'}),
          headers: {'content-type': 'application/json'});
    } catch (e) {
      print('Erro interno no endpoint /packages/suggest: $e');
      return Response.internalServerError(
          body: jsonEncode(
              {'success': false, 'error': 'Erro interno do servidor.'}),
          headers: {'content-type': 'application/json'});
    }
  });

  return router;
}