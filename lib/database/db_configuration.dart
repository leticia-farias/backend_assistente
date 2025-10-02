// lib/database/db_configuration.dart
import 'dart:io' show Platform;
import 'package:postgres/postgres.dart';

class DbConfiguration {
  final PostgreSQLConnection _connection;

  DbConfiguration._(this._connection);

  static Future<DbConfiguration> create() async {
    // 1. Lê a variável de ambiente DATABASE_URL
    final dbUrl = Platform.environment['DATABASE_URL'];

    if (dbUrl == null || dbUrl.isEmpty) {
      print('ERRO: Variável de ambiente DATABASE_URL não encontrada.');
      throw Exception('DATABASE_URL environment variable is not set.');
    }

    try {
      final uri = Uri.parse(dbUrl);

      // 2. Lógica para corrigir a porta ausente (essencial para o Render)
      final port = uri.port == 0 ? 5432 : uri.port;

      final connection = PostgreSQLConnection(
        uri.host,
        port,
        uri.pathSegments.first,
        username: uri.userInfo.split(':')[0],
        password: uri.userInfo.split(':')[1],
        useSSL: true,
      );

      print('Tentando conectar ao banco de dados em ${uri.host}:$port...');
      await connection.open();
      print('✅ Conexão com o banco de dados PostgreSQL estabelecida com sucesso!');
      return DbConfiguration._(connection);

    } on PostgreSQLException catch (e) {
      print('❌ Falha ao conectar ao banco de dados (PostgreSQLException):');
      print('   Verifique se a DATABASE_URL no seu ambiente está correta.');
      print('   Mensagem do erro: ${e.message}');
      rethrow;
    } catch (e) {
      print('❌ Falha inesperada ao conectar ao banco de dados: $e');
      rethrow;
    }
  }

  PostgreSQLConnection get connection => _connection;

  Future<void> close() async {
    await _connection.close();
  }
}