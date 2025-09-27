//C:\Users\ziofl\StudioProjects\curriculator_free\lib\features\dashboard\translation_repository.dart
import 'package:curriculator_free/core/services/ai_service.dart';
import 'package:curriculator_free/core/services/isar_service.dart';
import 'package:curriculator_free/features/settings/settings_screen.dart'; // Importa o provider da API key
import 'package:curriculator_free/models/curriculum_version.dart';
import 'package:curriculator_free/models/education.dart';
import 'package:curriculator_free/models/experience.dart';
import 'package:curriculator_free/models/language.dart';
import 'package:curriculator_free/models/personal_data.dart';
import 'package:curriculator_free/models/skill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

// --- Camada de Lógica e Acesso a Dados ---

/// Provider para o TranslationRepository.
/// Ele depende da chave de API e do serviço do Isar para funcionar.
final translationRepositoryProvider = Provider<TranslationRepository>((ref) {
  // Observa o estado do FutureProvider que carrega a chave da API.
  final apiKeyAsyncValue = ref.watch(apiKeyProvider);
  final isarService = ref.watch(isarServiceProvider);

  // Obtém a chave de API. Se não estiver disponível ou carregando, usa uma string vazia.
  // A verificação de validade será feita dentro do método do repositório.
  final apiKey = apiKeyAsyncValue.valueOrNull ?? '';

  // Cria a instância do AIService com a chave obtida.
  final aiService = AIService(apiKey: apiKey);

  return TranslationRepository(isarService, aiService);
});

/// Repositório responsável por orquestrar todo o processo de tradução de uma versão de currículo.
class TranslationRepository {
  final IsarService _isarService;
  final AIService _aiService;

  TranslationRepository(this._isarService, this._aiService);

  /// Cria uma nova versão traduzida de um currículo existente.
  ///
  /// Este método executa os seguintes passos:
  /// 1. Carrega a versão original completa do banco de dados.
  /// 2. Converte os dados da versão para um formato JSON.
  /// 3. Envia o JSON para o AIService para tradução.
  /// 4. Recebe o JSON traduzido.
  /// 5. Cria novos registros no banco de dados para cada item traduzido.
  /// 6. Cria uma nova CurriculumVersion e a "linka" aos novos registros traduzidos.
  ///
  /// Lança uma exceção se a chave da API não estiver configurada.
  Future<void> createTranslatedVersion({
    required int originalVersionId,
    required String targetLanguage,
  }) async {
    // Passo 0: Validação da Chave de API
    if (_aiService.apiKey.isEmpty) {
      throw Exception('Chave de API do Gemini não configurada! Por favor, adicione-a na tela de Configurações.');
    }

    final isar = await _isarService.db;

    // Passo 1: Carrega a versão original completa do Isar.
    final originalVersion = await isar.curriculumVersions.get(originalVersionId);
    if (originalVersion == null) {
      throw Exception("A versão original do currículo não foi encontrada.");
    }

    // Carrega todos os dados "linkados" à versão original.
    await Future.wait([
      originalVersion.personalData.load(),
      originalVersion.experiences.load(),
      originalVersion.educations.load(),
      originalVersion.skills.load(),
      originalVersion.languages.load(),
    ]);

    // Passo 2: Monta o JSON com os dados originais para enviar à IA.
    final curriculumJson = {
      'personalData': originalVersion.personalData.value?.toJson(),
      'experiences': originalVersion.experiences.map((item) => item.toJson()).toList(),
      'educations': originalVersion.educations.map((item) => item.toJson()).toList(),
      'skills': originalVersion.skills.map((item) => item.toJson()).toList(),
      'languages': originalVersion.languages.map((item) => item.toJson()).toList(),
    };

    // Passo 3: Chama o AIService para realizar a tradução.
    final translatedJson = await _aiService.translateCurriculum(
      targetLanguage: targetLanguage,
      curriculumJson: curriculumJson,
    );

    // Passo 4 a 6: Salva os novos dados e a nova versão em uma única transação atômica.
    await isar.writeTxn(() async {
      // 4a. Cria novos objetos Dart a partir do JSON traduzido.
      final translatedPersonalData = PersonalData.fromJson(translatedJson['personalData']);
      final translatedExperiences = (translatedJson['experiences'] as List)
          .map((json) => Experience.fromJson(json)).toList();
      final translatedEducations = (translatedJson['educations'] as List)
          .map((json) => Education.fromJson(json)).toList();
      final translatedSkills = (translatedJson['skills'] as List)
          .map((json) => Skill.fromJson(json)).toList();
      final translatedLanguages = (translatedJson['languages'] as List)
          .map((json) => Language.fromJson(json)).toList();

      // 4b. Salva os novos objetos no Isar, o que gera novos IDs para cada um.
      await isar.personalDatas.put(translatedPersonalData);
      await isar.experiences.putAll(translatedExperiences);
      await isar.educations.putAll(translatedEducations);
      await isar.skills.putAll(translatedSkills);
      await isar.languages.putAll(translatedLanguages);

      // 4c. Cria a nova instância de CurriculumVersion.
      final newVersion = CurriculumVersion.create(
        name: 'Cópia em $targetLanguage de "${originalVersion.name}"',
        createdAt: DateTime.now(),
        languageCode: _mapLanguageToCode(targetLanguage), // Mapeia o nome para um código de idioma
      );

      // 4d. Associa ("linka") os novos objetos recém-salvos à nova versão.
      newVersion.personalData.value = translatedPersonalData;
      newVersion.experiences.addAll(translatedExperiences);
      newVersion.educations.addAll(translatedEducations);
      newVersion.skills.addAll(translatedSkills);
      newVersion.languages.addAll(translatedLanguages);

      // 4e. Salva a nova versão principal e, em seguida, salva as associações (links).
      await isar.curriculumVersions.put(newVersion);
      await Future.wait([
        newVersion.personalData.save(),
        newVersion.experiences.save(),
        newVersion.educations.save(),
        newVersion.skills.save(),
        newVersion.languages.save(),
      ]);
    });
  }

  /// Mapeia o nome do idioma para um código de idioma padrão (ex: "en-US").
  String _mapLanguageToCode(String languageName) {
    switch (languageName.toLowerCase()) {
      case 'english':
        return 'en-US';
      case 'spanish':
        return 'es-ES';
      case 'french':
        return 'fr-FR';
      case 'german':
        return 'de-DE';
      case 'italian':
        return 'it-IT';
      default:
        return 'en-US'; // Padrão
    }
  }
}