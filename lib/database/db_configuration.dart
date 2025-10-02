// lib/database/db_configuration.dart
import 'dart:io' show Platform;
import 'package:postgres/postgres.dart';

class DbConfiguration {
  final PostgreSQLConnection _connection;

  // Construtor privado
  DbConfiguration._(this._connection);

  static Future<DbConfiguration> create() async {
    final dbUrl = Platform.environment['DATABASE_URL'];

    if (dbUrl == null || dbUrl.isEmpty) {
      print('ERRO: Variável de ambiente DATABASE_URL não encontrada.');
      throw Exception('DATABASE_URL environment variable is not set.');
    }

    try {
      // Usamos a classe Uri nativa do Dart para parsear a URL,
      // que é a abordagem correta para a versão 2.x do pacote postgres.
      final uri = Uri.parse(dbUrl);

      final connection = PostgreSQLConnection(
        uri.host,
        uri.port,
        uri.pathSegments.first, // O nome do banco de dados
        username: uri.userInfo.split(':')[0],
        password: uri.userInfo.split(':')[1],
        useSSL: true, // Essencial para o Render
      );

      await connection.open();
      print('✅ Conexão com o banco de dados PostgreSQL estabelecida com sucesso!');
      return DbConfiguration._(connection);

    } on PostgreSQLException catch (e) {
      // O método toDisplayString não existe na v2.x. 
      // Construímos uma mensagem de erro detalhada manualmente.
      print('Falha ao conectar ao banco de dados (PostgreSQLException):');
      print('  Mensagem: ${e.message}');
      print('  Código de erro: ${e.code}');
      print('  Detalhes completos: ${e.toString()}');
      rethrow;
    } catch (e) {
      print('Falha inesperada ao conectar ao banco de dados: $e');
      rethrow;
    }
  }

  PostgreSQLConnection get connection => _connection;

  Future<void> close() async {
    await _connection.close();
  }
}