/// Modelo que representa um pacote de serviços (internet, mobile, etc.)
class Package {
  final String name;        // Nome do pacote
  final String description; // Descrição detalhada do pacote
  final String type;        // Tipo do pacote (mobile_data, fixed_internet, etc.)
  final double price;       // Preço do pacote
  final String features;    // Principais funcionalidades ou benefícios

  Package({
    required this.name,
    required this.description,
    required this.type,
    required this.price,
    required this.features,
  });

  /// Converte o objeto Package para JSON (Map<String, dynamic>)
  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'type': type,
        'price': price,
        'features': features,
      };

  /// Cria um objeto Package a partir de um JSON (vindo da IA)
  factory Package.fromJson(Map<String, dynamic> json) => Package(
        name: json['name'] as String,
        description: json['description'] as String,
        type: json['type'] as String,
        price: (json['price'] as num).toDouble(),
        features: json['features'] as String,
      );
      
  /// Cria um objeto Package a partir de um Map (vindo do banco de dados)
  factory Package.fromMap(Map<String, dynamic> map) => Package(
        name: map['name'] as String,
        description: map['description'] as String,
        type: map['type'] as String,
        price: (map['price'] as num).toDouble(),
        features: map['features'] as String,
      );
}