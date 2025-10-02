// lib/database/db_configuration.dart
import 'dart:io' show Platform;
import 'package:postgres/postgres.dart';

class DbConfiguration {
  final PostgreSQLConnection _connection;

  // Construtor privado para garantir o uso do método create
  DbConfiguration._(this._connection);

  static Future<DbConfiguration> create() async {
    final dbUrl = Platform.environment['DATABASE_URL'];

    if (dbUrl == null) {
      print('ERRO: Variável de ambiente DATABASE_URL não encontrada.');
      throw Exception('DATABASE_URL environment variable is not set.');
    }

    try {
      final uri = Uri.parse(dbUrl);
      final connection = PostgreSQLConnection(
        uri.host,
        uri.port,
        uri.pathSegments.first,
        username: uri.userInfo.split(':')[0],
        password: uri.userInfo.split(':')[1],
        useSSL: true, // Importante para o Render
      );

      await connection.open();
      print('Conexão com o banco de dados PostgreSQL estabelecida com sucesso! 🐘');
      return DbConfiguration._(connection);
    } catch (e) {
      print('Falha ao conectar ao banco de dados: $e');
      rethrow; // Propaga o erro para parar a inicialização do servidor
    }
  }

  PostgreSQLConnection get connection => _connection;

  Future<void> close() async {
    await _connection.close();
  }
}