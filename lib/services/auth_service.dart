// lib/services/auth_service.dart
import 'package:postgres/postgres.dart';

class AuthService {
  final PostgreSQLConnection _dbConnection;

  AuthService(this._dbConnection);

  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
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

  Future<Map<String, dynamic>> register(
      String name, String email, String phone, String password) async {
    try {
      // Verifica se o email já existe
      final existingEmail = await _dbConnection.mappedResultsQuery(
        "SELECT id FROM users WHERE email = @email",
        substitutionValues: {'email': email},
      );

      if (existingEmail.isNotEmpty) {
        return {'success': false, 'error': 'Este email já está em uso.'};
      }

      final existingPhone = await _dbConnection.mappedResultsQuery(
        "SELECT id FROM users WHERE phone = @phone",
        substitutionValues: {'phone': phone},
      );

      if (existingPhone.isNotEmpty) {
        return {'success': false, 'error': 'Este telefone já está em uso.'};
      }
      // ----------------------------------------------------------------

      // Insere o novo usuário
      await _dbConnection.execute(
        "INSERT INTO users (name, email, phone, password) VALUES (@name, @email, @phone, @password)",
        substitutionValues: {
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
        },
      );

      return {'success': true, 'message': 'Usuário criado com sucesso!'};
    } catch (e) {
      print('Erro CRÍTICO no serviço de cadastro: $e');
      return {'success': false, 'error': 'Erro interno ao tentar criar o usuário.'};
    }
  }
}