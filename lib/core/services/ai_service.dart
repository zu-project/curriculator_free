import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
// Importe seus modelos e repositórios
import 'package:curriculator_free/models/curriculum_version.dart';
// ... e outros

// --- Serviço de IA ---
class AIService {
  final String apiKey;
  late final GenerativeModel _model;

  AIService({required this.apiKey}) {
    // Configure o modelo do Gemini que será usado
    _model = GenerativeModel(
      model: 'gemini-1.5-flash-latest', // Modelo rápido e eficiente
      apiKey: apiKey,
    );
  }

  // --- FUNÇÃO 1: OTIMIZAÇÃO PARA VAGA ---
  Future<Map<String, dynamic>> analyzeAndSuggestVersion({
    required String jobDescription,
    required Map<String, dynamic> fullCurriculumJson,
  }) async {
    // O PROMPT É A PARTE MAIS IMPORTANTE!
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

    final content = [Content.text(prompt)];
    final response = await _model.generateContent(content);

    // Extrai o JSON da resposta da IA
    final responseJson = response.text!.replaceAll('```json', '').replaceAll('```', '').trim();
    return jsonDecode(responseJson);
  }

  // --- FUNÇÃO 2: TRADUÇÃO ---
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

    final content = [Content.text(prompt)];
    final response = await _model.generateContent(content);

    final responseJson = response.text!.replaceAll('```json', '').replaceAll('```', '').trim();
    return jsonDecode(responseJson);
  }
}