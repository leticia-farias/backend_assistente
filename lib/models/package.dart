// backend_assistente/lib/models/package.dart

/// Modelo que representa um pacote de serviços (internet, mobile, etc.)
class Package {
  final String name;
  final String description;
  final String type;
  final double price;
  final String features;

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
  factory Package.fromMap(Map<String, dynamic> map) {
    // --- INÍCIO DA CORREÇÃO ---
    // Lógica robusta para converter o preço
    final priceValue = map['price'];
    double parsedPrice;
    if (priceValue is String) {
      parsedPrice = double.tryParse(priceValue) ?? 0.0;
    } else if (priceValue is num) {
      parsedPrice = priceValue.toDouble();
    } else {
      parsedPrice = 0.0;
    }
    // --- FIM DA CORREÇÃO ---

    return Package(
      name: map['name'] as String,
      description: map['description'] as String,
      type: map['type'] as String,
      price: parsedPrice, // Usa a variável corrigida
      features: map['features'] as String,
    );
  }
}