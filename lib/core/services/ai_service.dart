import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

/// Um serviço dedicado para interagir com a API do Google Gemini.
///
/// Esta classe encapsula toda a lógica de construção de prompts,
/// chamadas à API e processamento das respostas, fornecendo métodos
/// claros e específicos para cada funcionalidade de IA do aplicativo.
class AIService {
  /// A chave de API fornecida pelo usuário para autenticação.
  final String apiKey;

  /// A instância do modelo generativo do Gemini.
  late final GenerativeModel _model;

  /// Construtor que inicializa o serviço com a chave de API.
  /// Se a chave estiver vazia, a inicialização ocorre, mas as chamadas à API falharão.
  AIService({required this.apiKey}) {
    // Configura o modelo de IA a ser utilizado, neste caso, o Gemini 1.5 Flash,
    // que é rápido e eficiente para tarefas de texto.
    _model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: apiKey,
      // Configurações de segurança para evitar bloqueios desnecessários.
      // Para um app de currículos, é seguro desativar os filtros de conteúdo,
      // pois textos de vagas podem conter palavras que acionariam falsos positivos.
      safetySettings: [
        SafetySetting(HarmCategory.harassment, HarmBlockThreshold.none),
        SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.none),
        SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.none),
        SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.none),
      ],
    );
  }

  /// Testa a validade da API Key fazendo a chamada mais leve possível à API.
  /// Lança uma exceção se a chave for inválida ou houver um problema de rede.
  Future<void> testConnection() async {
    // A função `countTokens` é ideal para testes, pois é a chamada mais simples
    // e de menor custo de tokens para a API. Se funcionar, a chave é válida.
    await _model.countTokens([Content.text('ping')]);
  }

  /// Analisa uma descrição de vaga e um currículo completo, e sugere uma nova versão otimizada.
  ///
  /// Retorna um `Map<String, dynamic>` contendo o nome sugerido para a nova versão,
  /// um novo resumo profissional e as listas de IDs dos itens mais relevantes.
  Future<Map<String, dynamic>> analyzeAndSuggestVersion({
    required String jobDescription,
    required Map<String, dynamic> fullCurriculumJson,
  }) async {
    final prompt = '''
    Você é um assistente de RH especialista em otimização de currículos. Sua tarefa é analisar a descrição de uma vaga e os dados completos de um currículo, e então sugerir uma nova versão otimizada.

    **DESCRIÇÃO DA VAGA:**
    ---
    $jobDescription
    ---

    **DADOS COMPLETOS DO CURRÍCULO (JSON):**
    ---
    ${jsonEncode(fullCurriculumJson)}
    ---

    **SUA TAREFA:**
    1.  Identifique as palavras-chave, requisitos e responsabilidades mais importantes na DESCRIÇÃO DA VAGA.
    2.  Analise os DADOS DO CURRÍCULO e selecione APENAS os itens (experiências, formações, habilidades, etc.) que são mais relevantes para a vaga.
    3.  Crie um novo resumo profissional (suggested_summary) curto e impactante, destacando como as experiências e habilidades do candidato se alinham com a vaga. O resumo deve ter no máximo 4 linhas.
    4.  Responda APENAS em formato JSON válido, sem nenhum texto ou explicação adicional antes ou depois. Use a seguinte estrutura:

    {
      "new_version_name": "Versão Otimizada para [Nome do Cargo da Vaga]",
      "suggested_summary": "Seu novo resumo profissional otimizado aqui.",
      "relevant_experience_ids": [1, 3, 4],
      "relevant_education_ids": [1, 2],
      "relevant_skill_ids": [10, 12, 15],
      "relevant_language_ids": [1]
    }
    ''';

    final response = await _model.generateContent([Content.text(prompt)]);
    return _parseJsonResponse(response);
  }

  /// Traduz o conteúdo textual de um currículo para um idioma de destino.
  Future<Map<String, dynamic>> translateCurriculum({
    required String targetLanguage,
    required Map<String, dynamic> curriculumJson,
  }) async {
    final prompt = '''
    Você é um tradutor especialista em documentos profissionais, como currículos. Sua tarefa é traduzir o conteúdo de texto do JSON a seguir do Português para o idioma "$targetLanguage".

    **REGRAS:**
    1.  Traduza APENAS os valores das chaves que contêm texto (como 'name', 'jobTitle', 'description', 'summary', etc.).
    2.  NÃO traduza chaves, IDs, datas, URLs ou valores booleanos.
    3.  Use terminologia profissional e comum no mercado de trabalho do idioma "$targetLanguage".
    4.  Sua resposta deve ser APENAS o JSON traduzido, mantendo a estrutura original IDÊNTICA. Não adicione nenhum texto extra.

    **JSON PARA TRADUZIR:**
    ---
    ${jsonEncode(curriculumJson)}
    ---
    ''';

    final response = await _model.generateContent([Content.text(prompt)]);
    return _parseJsonResponse(response);
  }

  /// Analisa o conteúdo de um currículo e fornece sugestões de melhoria.
  Future<Map<String, dynamic>> analyzeContent({
    required Map<String, dynamic> contentToAnalyzeJson,
  }) async {
    final prompt = '''
    Você é um coach de carreira e especialista em redação de currículos. Sua tarefa é analisar o conteúdo textual de um currículo e fornecer sugestões específicas para torná-lo mais profissional, orientado a resultados e impactante.

    **CONTEÚDO DO CURRÍCULO PARA ANÁLISE (JSON):**
    ---
    ${jsonEncode(contentToAnalyzeJson)}
    ---

    **SUAS TAREFAS:**
    1.  **Reescrever o Resumo:** Analise o resumo profissional ('summary'). Reescreva-o para ser mais conciso, focado em conquistas e alinhado com as melhores práticas de mercado. Use verbos de ação fortes. A sugestão deve ser armazenada na chave 'summary_suggestion'.
    2.  **Melhorar as Descrições de Experiência:** Para cada experiência na lista 'experiences', analise o campo 'description'. Reescreva cada descrição focando em resultados e métricas (Ex: em vez de "Responsável por vendas", use "Aumentei as vendas em 20% no primeiro trimestre"). Retorne uma lista em 'experience_suggestions', onde cada item contém o 'id' original da experiência e a nova 'description_suggestion'.
    3.  **Sugerir Novas Habilidades:** Com base nas descrições de experiência e no resumo, identifique habilidades (técnicas e comportamentais) que o candidato demonstrou, mas que talvez não tenha listado. Retorne uma lista de até 10 habilidades em 'skill_suggestions', onde cada item é um objeto com 'name' (o nome da habilidade) e 'type' ('hardSkill' ou 'softSkill').
    4.  **Formato de Resposta:** Sua resposta deve ser ESTRITAMENTE um objeto JSON, sem nenhum texto adicional. Use o seguinte formato:

    {
      "summary_suggestion": "Profissional de [Área] com X anos de experiência...",
      "experience_suggestions": [ { "id": 1, "description_suggestion": "Liderei o desenvolvimento..." } ],
      "skill_suggestions": [ { "name": "Flutter", "type": "hardSkill" }, { "name": "Liderança Técnica", "type": "softSkill" } ]
    }
    ''';

    final response = await _model.generateContent([Content.text(prompt)]);
    return _parseJsonResponse(response);
  }

  /// Método auxiliar privado para processar a resposta da IA e extrair o JSON.
  /// Lida com a limpeza da string e a decodificação, com tratamento de erros.
  Map<String, dynamic> _parseJsonResponse(GenerateContentResponse response) {
    try {
      // O texto da resposta pode vir envolvido em ```json ... ```, então removemos isso.
      final responseText = response.text
          ?.replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      if (responseText == null || responseText.isEmpty) {
        throw Exception('A IA retornou uma resposta vazia.');
      }

      return jsonDecode(responseText) as Map<String, dynamic>;
    } catch (e) {
      // Se a decodificação falhar, lança um erro mais claro.
      debugPrint("Falha ao decodificar JSON da IA. Resposta bruta: ${response.text}");
      throw Exception('A IA retornou um formato de dados inválido. Tente novamente.');
    }
  }
}