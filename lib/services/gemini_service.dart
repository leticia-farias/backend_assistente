// backend_assistente/lib/services/gemini_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/package.dart';

/// Remove marcações de código e extrai APENAS o conteúdo JSON da resposta da IA.
String _sanitizeAndExtractJson(String raw) {
  if (raw.isEmpty) return "";

  // Encontra o início do JSON, que pode ser '[' ou '{'
  final jsonStartIndex = raw.indexOf(RegExp(r'\[|\{'));
  if (jsonStartIndex == -1) {
    print('AVISO: Nenhum início de JSON ([ ou {) encontrado na resposta da IA.');
    return "";
  }

  // Encontra o final do JSON, que pode ser ']' ou '}'
  final jsonEndIndex = raw.lastIndexOf(RegExp(r'\]|\}'));
  if (jsonEndIndex == -1) {
    print('AVISO: Nenhum final de JSON (] ou }) encontrado na resposta da IA.');
    return "";
  }
  
  // Extrai a substring que contém o JSON
  return raw.substring(jsonStartIndex, jsonEndIndex + 1).trim();
}


/// Serviço responsável por interagir com a API Gemini
/// Gera sugestões de pacotes com base na consulta do usuário
class GeminiService {
  late final GenerativeModel? geminiModel;

  GeminiService() {
    final geminiApiKey = Platform.environment['GEMINI_API_KEY'];

    if (geminiApiKey == null || geminiApiKey.isEmpty) {
      print('ERRO: GEMINI_API_KEY não configurada.');
      geminiModel = null;
    } else {
      geminiModel = GenerativeModel(model: 'gemini-pro', apiKey: geminiApiKey);
      print('Gemini inicializado com sucesso!');
    }
  }

  /// Sugere pacotes com base na consulta do usuário
  Future<List<Package>> suggestPackages(String query, List<Package> availablePackages) async {
    if (geminiModel == null) return [];

    final availableJson = jsonEncode(availablePackages.map((p) => p.toJson()).toList());

    final systemInstruction = '''
Você é um assistente de operadora.
Sua única função é analisar o pedido do usuário e a lista de pacotes disponíveis.
Baseado nisso, retorne APENAS um array JSON com os pacotes mais relevantes.

O formato do array deve ser:
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
      final content = [
        Content.text(systemInstruction),
        Content.text('Pedido do Usuário: "$query"\n\nPacotes Disponíveis: $availableJson'),
      ];

      final response = await geminiModel!.generateContent(content);
      final rawText = response.text;

      if (rawText == null || rawText.isEmpty) {
        print('Erro: A resposta da IA foi vazia.');
        return [];
      }

      // --- LÓGICA DE LIMPEZA APRIMORADA ---
      final jsonText = _sanitizeAndExtractJson(rawText);
      if(jsonText.isEmpty) {
        print('Erro: Não foi possível extrair um JSON válido da resposta: "$rawText"');
        return [];
      }

      // Tenta decodificar o JSON limpo
      try {
        final List<dynamic> jsonList = jsonDecode(jsonText);
        return jsonList.map((item) => Package.fromJson(item)).toList();
      } on FormatException catch (e) {
        print('Erro de parsing de JSON mesmo após a sanitização: $e');
        print('JSON que falhou: "$jsonText"');
        return [];
      }

    } catch (e) {
      print('Erro fatal ao chamar a API do Gemini: $e');
      return [];
    }
  }
}