// lib/services/package_service.dart
import 'package:postgres/postgres.dart';
import '../models/package.dart';

class PackageService {
  final PostgreSQLConnection _dbConnection;

  PackageService(this._dbConnection);

  /// Busca todos os pacotes no banco de dados e retorna uma lista de objetos Package
  Future<List<Package>> getAllPackages() async {
    try {
      // Confirma que o nome da tabela é 'plans'
      final result = await _dbConnection.mappedResultsQuery('SELECT name, description, type, price, features FROM plans');
      
      final packages = result.map((row) {
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