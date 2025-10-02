// database_service.dart
import 'dart:io';
import 'package:postgres/postgres.dart';

class DatabaseService {
  late final PostgreSQLConnection _conn;

  DatabaseService() {
    final dbUrl = Platform.environment['DATABASE_URL'];
    if (dbUrl == null || dbUrl.isEmpty) {
      throw Exception('DATABASE_URL is not set');
    }

    final uri = Uri.parse(dbUrl);

    final userInfo = uri.userInfo.split(':');
    final username = userInfo.isNotEmpty ? userInfo[0] : '';
    final password = userInfo.length > 1 ? userInfo[1] : '';

    final host = uri.host;
    final port = (uri.hasPort && uri.port != 0) ? uri.port : 5432;
    final dbName = uri.pathSegments.isNotEmpty ? uri.pathSegments[0] : uri.path.replaceFirst('/', '');

    _conn = PostgreSQLConnection(
      host,
      port,
      dbName,
      username: username,
      password: password,
    );
  }

  Future<void> connect() async {
    await _conn.open();
    print('✅ Conectado ao PostgreSQL: ${_conn.host}:${_conn.port}/${_conn.databaseName}');
  }

  Future<List<Map<String, dynamic>>> getPlans() async {
    // mappedResultsQuery devolve List<Map<table, Map<col, val>>>
    final rows = await _conn.mappedResultsQuery('SELECT * FROM plans;');
    return rows.map((r) {
      final tableRow = r['plans'] ?? r.values.first;
      return Map<String, dynamic>.from(tableRow);
    }).toList();
  }

  Future<void> close() async => await _conn.close();
}