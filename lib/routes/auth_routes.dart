// lib/routes/auth_routes.dart
import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/auth_service.dart';

Router authRoutes(AuthService authService) {
  final router = Router();

  router.post('/login', (Request req) async {
    try {
      final content = await req.readAsString();
      final data = jsonDecode(content);

      final email = data['email'] as String?;
      final password = data['password'] as String?;

      if (email == null || password == null) {
        return Response.badRequest(
            body: jsonEncode({'success': false, 'error': 'Email e senha são obrigatórios.'}));
      }

      final authResult = await authService.login(email, password);

      if (authResult == null) {
        return Response.unauthorized(
            jsonEncode({'success': false, 'error': 'Credenciais inválidas.'}));
      }

      return Response.ok(jsonEncode({'success': true, 'data': authResult}));

    } catch (e) {
      print('Erro na rota de login: $e');
      return Response.internalServerError(
          body: jsonEncode({'success': false, 'error': 'Erro interno do servidor.'}));
    }
  });

  return router;
}