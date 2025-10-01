import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

// ---------------- MODELO DE DADOS ----------------
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

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'type': type,
        'price': price,
        'features': features,
      };

  factory Package.fromJson(Map<String, dynamic> json) {
    return Package(
      name: json['name'] as String,
      description: json['description'] as String,
      type: json['type'] as String,
      price: (json['price'] as num).toDouble(),
      features: json['features'] as String,
    );
  }
}

// ---------------- PACOTES MOCKADOS ----------------
final List<Package> availablePackages = [
  Package(
    name: 'Essencial Mobile',
    description: '30GB de dados móveis 5G e chamadas ilimitadas.',
    type: 'mobile_data',
    price: 79.90,
    features: '30GB 5G + Ilimitado',
  ),
  Package(
    name: 'Pro Web 500',
    description: 'Internet banda larga de 500MB de fibra ótica.',
    type: 'fixed_internet',
    price: 99.90,
    features: '500MB Fibra',
  ),
  Package(
    name: 'Ultra Família Plus',
    description: '50GB móveis + 1GB fibra. Ideal para casa e rua.',
    type: 'mobile_data',
    price: 149.90,
    features: '50GB 5G + 1GB Fibra',
  ),
  Package(
    name: 'Econômico Fixo',
    description: 'Internet fixa básica de 100MB para tarefas simples.',
    type: 'fixed_internet',
    price: 69.90,
    features: '100MB Fibra',
  ),
];

// ---------------- GEMINI ----------------
final String? geminiApiKey = Platform.environment['GEMINI_API_KEY'];
late final GenerativeModel? geminiModel;

void initializeGemini() {
  if (geminiApiKey == null || geminiApiKey!.isEmpty) {
    print('ERRO: GEMINI_API_KEY não configurada.');
    geminiModel = null;
  } else {
    geminiModel = GenerativeModel(
      model: 'gemini-2.5-flash', 
      apiKey: geminiApiKey!,
    );
    print('Gemini inicializado com modelo gemini-2.5-flash');
  }
}

// ---------------- FUNÇÃO AUXILIAR ----------------
String sanitizeJson(String raw) {
  var sanitized = raw.trim();
  if (sanitized.startsWith('```json')) sanitized = sanitized.substring(7).trim();
  if (sanitized.endsWith('```')) sanitized = sanitized.substring(0, sanitized.length - 3).trim();
  return sanitized;
}

// ---------------- FUNÇÃO DE SUGESTÃO ----------------
Future<List<Package>> suggestPackages(String userQuery) async {
  if (geminiModel == null) return [];

  final availablePackagesJson = jsonEncode(availablePackages.map((p) => p.toJson()).toList());

  final systemInstruction = '''
Você é um assistente de operadora.
Responda APENAS com JSON válido no formato:

[
  {
    "name": "string",
    "description": "string",
    "type": "string",
    "price": number,
    "features": "string"
  }
]
Não inclua texto adicional, explicações ou comentários.
''';

  final prompt = '''
Pedido do Usuário: "$userQuery"
Pacotes Disponíveis: $availablePackagesJson
'''.trim();

  try {
    final response = await geminiModel!.generateContent([
      Content.text(systemInstruction),
      Content.text(prompt),
    ]);

    final rawText = response.text ?? '';
    print('Resposta bruta do modelo: $rawText');

    final jsonText = sanitizeJson(rawText);
    final List<dynamic> jsonList = jsonDecode(jsonText);

    return jsonList.map((item) => Package.fromJson(item as Map<String, dynamic>)).toList();
  } catch (e) {
    print('Erro ao chamar Gemini ou fazer parsing: $e');
    return [];
  }
}

// ---------------- ROTAS ----------------
Router _router() {
  final router = Router();

  router.get('/ping', (Request req) {
    return Response.ok(
      jsonEncode({'status': 'ok', 'message': 'pong'}),
      headers: {'content-type': 'application/json'},
    );
  });

  router.post('/packages/suggest', (Request req) async {
    try {
      final content = await req.readAsString();
      final data = jsonDecode(content);

      final needs = data['needs'] as String? ?? '';
      final budget = (data['budget'] as num? ?? 0.0).toDouble();

      final query = 'O que preciso: $needs. Orçamento máximo: R\$${budget.toStringAsFixed(2)}.';

      final suggested = await suggestPackages(query);

      if (suggested.isEmpty) {
        return Response.ok(
          jsonEncode({'success': false, 'message': 'Nenhuma sugestão encontrada.'}),
          headers: {'content-type': 'application/json'},
        );
      }

      return Response.ok(
        jsonEncode({'success': true, 'suggestions': suggested.map((p) => p.toJson()).toList()}),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'success': false, 'error': e.toString()}),
        headers: {'content-type': 'application/json'},
      );
    }
  });

  router.get('/packages/all', (Request req) {
    return Response.ok(
      jsonEncode({'success': true, 'packages': availablePackages.map((p) => p.toJson()).toList()}),
      headers: {'content-type': 'application/json'},
    );
  });

  return router;
}

// ---------------- MAIN ----------------
Future<void> main() async {
  initializeGemini();

  final corsHeadersMiddleware = corsHeaders(
    headers: {
      'Access-Control-Allow-Origin': '*', // permite Flutter Web
      'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
      'Access-Control-Allow-Headers': 'Origin, Content-Type',
    },
  );

  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsHeadersMiddleware)
      .addHandler(_router());

  final server = await io.serve(handler, InternetAddress.anyIPv4, 8080);
  print('Servidor rodando em http://${server.address.address}:${server.port}');
  print('Endpoints disponíveis: /ping, /packages/suggest, /packages/all');
}