// lib/services/package_service.dart
import 'package:postgres/postgres.dart';
import '../models/package.dart';

class PackageService {
  final PostgreSQLConnection _dbConnection;

  PackageService(this._dbConnection);

  /// Busca todos os pacotes no banco de dados e retorna uma lista de objetos Package
  Future<List<Package>> getAllPackages() async {
    try {
      // Assumindo que sua tabela se chama 'plans' como em database_service.dart
      final result = await _dbConnection.mappedResultsQuery('SELECT name, description, type, price, features FROM plans');
      
      final packages = result.map((row) {
        // O nome da tabela é a chave do mapa de resultados
        final tableRow = row['plans']!; 
        return Package.fromMap(tableRow);
      }).toList();
      
      return packages;
    } catch (e) {
      print('Erro ao buscar pacotes do banco de dados: $e');
      return []; // Retorna lista vazia em caso de erro
    }
  }
}