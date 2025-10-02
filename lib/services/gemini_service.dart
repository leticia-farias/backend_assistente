import 'dart:convert';
import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/package.dart';
import '../utils/json_sanitizer.dart';

/// Serviço responsável por interagir com a API Gemini
/// Gera sugestões de pacotes com base na consulta do usuário
class GeminiService {
  late final GenerativeModel? geminiModel;

  GeminiService() {
    // Obtém a chave da API do ambiente
    final geminiApiKey = Platform.environment['GEMINI_API_KEY'];

    if (geminiApiKey == null || geminiApiKey.isEmpty) {
      print('ERRO: GEMINI_API_KEY não configurada.');
      geminiModel = null; // Se não tiver chave, não inicializa o modelo
    } else {
      geminiModel = GenerativeModel(model: 'gemini-pro', apiKey: geminiApiKey);
      print('Gemini inicializado com sucesso!');
    }
  }

  /// Sugere pacotes com base na consulta do usuário
  /// Retorna uma lista de Package ou vazia se houver erro
  Future<List<Package>> suggestPackages(String query, List<Package> availablePackages) async {
    if (geminiModel == null) return [];

    // Converte os pacotes disponíveis em JSON
    final availableJson = jsonEncode(availablePackages.map((p) => p.toJson()).toList());

    // Instruções do sistema para garantir que o modelo retorne JSON válido
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
''';

    try {
      // Envia a consulta e instruções ao modelo
      final response = await geminiModel!.generateContent([
        Content.text(systemInstruction),
        Content.text('Pedido do Usuário: "$query"\nPacotes Disponíveis: $availableJson'),
      ]);

      final rawText = response.text ?? '';
      // Sanitiza para remover marcações de código (```json)
      final jsonText = sanitizeJson(rawText);

      // Faz o parsing do JSON para objetos Package
      final List<dynamic> jsonList = jsonDecode(jsonText);
      return jsonList.map((item) => Package.fromJson(item)).toList();
    } catch (e) {
      print('Erro ao chamar Gemini ou fazer parsing: $e');
      return [];
    }
  }
}