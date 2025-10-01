import '../models/package.dart';

/// Serviço que gerencia os pacotes disponíveis
/// Contém a lista mockada e funções de acesso
class PackageService {
  final List<Package> _packages = [
    Package(
        name: 'Essencial Mobile',
        description: '30GB de dados móveis 5G e chamadas ilimitadas.',
        type: 'mobile_data',
        price: 79.90,
        features: '30GB 5G + Ilimitado'),
    Package(
        name: 'Pro Web 500',
        description: 'Internet banda larga de 500MB de fibra ótica.',
        type: 'fixed_internet',
        price: 99.90,
        features: '500MB Fibra'),
    Package(
        name: 'Ultra Família Plus',
        description: '50GB móveis + 1GB fibra. Ideal para casa e rua.',
        type: 'mobile_data',
        price: 149.90,
        features: '50GB 5G + 1GB Fibra'),
    Package(
        name: 'Econômico Fixo',
        description: 'Internet fixa básica de 100MB para tarefas simples.',
        type: 'fixed_internet',
        price: 69.90,
        features: '100MB Fibra'),
  ];

  /// Retorna todos os pacotes disponíveis
  List<Package> get all => _packages;
}