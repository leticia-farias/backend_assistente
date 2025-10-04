// backend_assistente/lib/services/gemini_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/package.dart';

String _sanitizeAndExtractJson(String raw) {
  print('[GeminiService] Iniciando sanitização do JSON...');
  if (raw.isEmpty) return "";
  final jsonStartIndex = raw.indexOf(RegExp(r'\[|\{'));
  if (jsonStartIndex == -1) return "";
  final jsonEndIndex = raw.lastIndexOf(RegExp(r'\]|\}'));
  if (jsonEndIndex == -1) return "";
  final extracted = raw.substring(jsonStartIndex, jsonEndIndex + 1).trim();
  print('[GeminiService] JSON extraído: "$extracted"');
  return extracted;
}

class GeminiService {
  late final GenerativeModel? geminiModel;

  GeminiService() {
    final geminiApiKey = Platform.environment['GEMINI_API_KEY'];
    if (geminiApiKey == null || geminiApiKey.isEmpty) {
      print('--- ERRO CRÍTICO: GEMINI_API_KEY não configurada no ambiente. ---');
      geminiModel = null;
    } else {
      geminiModel = GenerativeModel(model: 'gemini-pro', apiKey: geminiApiKey);
      print('[GeminiService] Gemini inicializado com sucesso!');
    }
  }

  Future<List<Package>> suggestPackages(String query, List<Package> availablePackages) async {
    if (geminiModel == null) {
      print('[GeminiService] A sugestão foi cancelada porque o modelo Gemini não foi inicializado.');
      return [];
    }
    if (availablePackages.isEmpty) {
      print('[GeminiService] A sugestão foi cancelada porque a lista de pacotes disponíveis está vazia.');
      return [];
    }

    final availableJson = jsonEncode(availablePackages.map((p) => p.toJson()).toList());
    
    print('[GeminiService] Enviando prompt para a IA...');
    print('-------------------- PROMPT --------------------');
    print('Consulta do usuário: "$query"');
    print('Pacotes disponíveis: $availableJson');
    print('---------------------------------------------');

    final systemInstruction = '''
Você é um assistente de operadora. Sua única função é analisar o pedido do usuário e a lista de pacotes disponíveis. Baseado nisso, retorne APENAS um array JSON com os pacotes mais relevantes. O formato do array deve ser: [{"name":"string","description":"string","type":"string","price":number,"features":"string"}]
''';

    try {
      final content = [
        Content.text(systemInstruction),
        Content.text('Pedido do Usuário: "$query"\n\nPacotes Disponíveis: $availableJson'),
      ];

      final response = await geminiModel!.generateContent(content);
      final rawText = response.text;

      print('[GeminiService] Resposta bruta recebida da IA: "$rawText"');

      if (rawText == null || rawText.isEmpty) {
        print('[GeminiService] ERRO: A resposta da IA foi nula ou vazia.');
        return [];
      }

      final jsonText = _sanitizeAndExtractJson(rawText);
      if (jsonText.isEmpty) {
        print('[GeminiService] ERRO: Não foi possível extrair um JSON válido da resposta.');
        return [];
      }

      final List<dynamic> jsonList = jsonDecode(jsonText);
      final suggestions = jsonList.map((item) => Package.fromJson(item)).toList();
      print('[GeminiService] Sugestões parseadas com sucesso: ${suggestions.length} itens.');
      return suggestions;

    } catch (e) {
      print('--- ERRO CRÍTICO no GeminiService ---');
      print('Falha ao chamar a API do Gemini ou ao processar a resposta: $e');
      if (e is FormatException) {
        print('Isso geralmente acontece quando a resposta da IA não é um JSON válido.');
      }
      print('--------------------------------------');
      return [];
    }
  }
}