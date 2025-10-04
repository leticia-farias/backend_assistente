// backend_assistente/lib/services/package_service.dart
import 'package:postgres/postgres.dart';
import '../models/package.dart';

class PackageService {
  final PostgreSQLConnection _dbConnection;

  PackageService(this._dbConnection);

  Future<List<Package>> getAllPackages() async {
    print('[PackageService] Buscando todos os pacotes do banco de dados...');
    try {
      final result = await _dbConnection.mappedResultsQuery(
          'SELECT id, name, description, type, price, features FROM plans');

      if (result.isEmpty) {
        print('[PackageService] AVISO: A consulta ao banco de dados não retornou nenhum plano.');
        return [];
      }
      
      print('[PackageService] Planos brutos encontrados: ${result.length}');

      final packages = result.map((row) {
        final tableRow = row['plans']!;
        return Package.fromMap(tableRow);
      }).toList();

      print('[PackageService] Planos convertidos com sucesso: ${packages.length} pacotes.');
      return packages;

    } catch (e) {
      print('--- ERRO CRÍTICO no PackageService ---');
      print('Erro ao buscar ou converter pacotes do banco de dados: $e');
      print('-----------------------------------------');
      return []; // Retorna lista vazia em caso de erro
    }
  }
}