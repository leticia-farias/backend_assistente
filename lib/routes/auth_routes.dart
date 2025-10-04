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

  router.post('/register', (Request req) async {
    try {
      final content = await req.readAsString();
      final data = jsonDecode(content);

      final name = data['name'] as String?;
      final email = data['email'] as String?;
      final phone = data['phone'] as String?;
      final password = data['password'] as String?; 

      if (name == null || email == null || phone == null || password == null) {
        return Response.badRequest(
            body: jsonEncode({
          'success': false,
          'error': 'Nome, email, telefone e senha são obrigatórios.'
        }));
      }

      final result = await authService.register(name, email, phone, password);

      if (result['success']) {
        return Response.ok(jsonEncode(result));
      } else {
        return Response(409, 
            body: jsonEncode(result));
      }
    } catch (e) {
      print('Erro na rota de cadastro: $e');
      return Response.internalServerError(
          body: jsonEncode(
              {'success': false, 'error': 'Erro interno do servidor.'}));
    }
  });


  return router;
}