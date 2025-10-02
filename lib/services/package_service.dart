// lib/services/package_service.dart
import 'package:postgres/postgres.dart';

class PackageService {
  // Propriedade para armazenar a conexão com o banco
  final PostgreSQLConnection _dbConnection;

  // O construtor agora exige a conexão com o banco
  PackageService(this._dbConnection);

  // Exemplo de como usar a conexão em um método
  Future<List<Map<String, dynamic>>> getAllPackages() async {
    try {
      final result = await _dbConnection.query('SELECT * FROM pacotes');
      
      // Converte o resultado para uma lista de mapas
      final packages = result.map((row) => row.toColumnMap()).toList();
      return packages;
    } catch (e) {
      print('Erro ao buscar pacotes: $e');
      return []; // ou lançar uma exceção
    }
  }

  // ... seus outros métodos ...
}