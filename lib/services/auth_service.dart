// lib/services/auth_service.dart
import 'package:postgres/postgres.dart';

class AuthService {
  final PostgreSQLConnection _dbConnection;

  AuthService(this._dbConnection);

  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      // 1. Busca o usuário pelo email e senha
      final userResult = await _dbConnection.mappedResultsQuery(
        "SELECT id, name, email, current_plan FROM users WHERE email = @email AND password = @password",
        substitutionValues: {
          'email': email,
          'password': password,
        },
      );

      if (userResult.isEmpty) {
        return null; // Usuário não encontrado ou senha incorreta
      }

      final user = userResult.first['users']!;
      final userId = user['id'];

      // 2. Busca o score do usuário
      final scoreResult = await _dbConnection.mappedResultsQuery(
        "SELECT loyalty_score FROM user_scores WHERE user_id = @userId",
        substitutionValues: {'userId': userId},
      );
      
      String clientType;
      int? score;

      if (scoreResult.isEmpty) {
        clientType = 'newClient'; // Sem score, é um cliente novo
      } else {
        score = scoreResult.first['user_scores']!['loyalty_score'] as int;
        if (score > 70) {
          clientType = 'good'; // Score alto
        } else {
          clientType = 'delinquent'; // Score baixo
        }
      }

      // 3. Retorna os dados combinados
      return {
        'user': user,
        'score': score,
        'clientType': clientType,
      };

    } catch (e) {
      print('Erro no serviço de autenticação: $e');
      return null;
    }
  }
}