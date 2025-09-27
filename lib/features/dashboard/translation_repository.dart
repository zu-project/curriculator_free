// C:\Users\ziofl\StudioProjects\curriculator_free\lib\features\dashboard\translation_repository.dart
import 'package:curriculator_free/core/services/ai_service.dart';
import 'package:curriculator_free/core/services/isar_service.dart';
import 'package:curriculator_free/models/curriculum_version.dart';
import 'package:curriculator_free/models/education.dart';
import 'package:curriculator_free/models/experience.dart';
import 'package:curriculator_free/models/language.dart';
import 'package:curriculator_free/models/personal_data.dart';
import 'package:curriculator_free/models/skill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- Camada de Lógica e Acesso a Dados ---

/// Provider SIMPLIFICADO para o TranslationRepository.
/// Agora ele só depende do IsarService.
final translationRepositoryProvider = Provider<TranslationRepository>((ref) {
  final isarService = ref.watch(isarServiceProvider);
  return TranslationRepository(isarService);
});

/// Repositório responsável por orquestrar o processo de tradução.
class TranslationRepository {
  final IsarService _isarService;

  // CORREÇÃO: Construtor não depende mais do AIService.
  TranslationRepository(this._isarService);

  /// Cria uma nova versão traduzida de um currículo existente.
  /// CORREÇÃO: Agora recebe a instância do AIService como parâmetro.
  Future<void> createTranslatedVersion({
    required int originalVersionId,
    required String targetLanguage,
    required AIService aiService, // <-- PARÂMETRO NOVO E OBRIGATÓRIO
  }) async {
    // A validação da chave agora é feita no local da chamada (na tela).
    if (aiService.apiKey.isEmpty) {
      throw Exception('Chave de API do Gemini não configurada! Por favor, adicione-a na tela de Configurações.');
    }

    final isar = await _isarService.db;

    final originalVersion = await isar.curriculumVersions.get(originalVersionId);
    if (originalVersion == null) {
      throw Exception("A versão original do currículo não foi encontrada.");
    }

    await Future.wait([
      originalVersion.personalData.load(),
      originalVersion.experiences.load(),
      originalVersion.educations.load(),
      originalVersion.skills.load(),
      originalVersion.languages.load(),
    ]);

    final curriculumJson = {
      'personalData': originalVersion.personalData.value?.toJson(),
      'experiences': originalVersion.experiences.map((item) => item.toJson()).toList(),
      'educations': originalVersion.educations.map((item) => item.toJson()).toList(),
      'skills': originalVersion.skills.map((item) => item.toJson()).toList(),
      'languages': originalVersion.languages.map((item) => item.toJson()).toList(),
    };

    // Usa a instância do AIService que foi passada.
    final translatedJson = await aiService.translateCurriculum(
      targetLanguage: targetLanguage,
      curriculumJson: curriculumJson,
    );

    await isar.writeTxn(() async {
      // O resto da lógica permanece o mesmo...
      final translatedPersonalData = PersonalData.fromJson(translatedJson['personalData']);
      final translatedExperiences = (translatedJson['experiences'] as List).map((json) => Experience.fromJson(json)).toList();
      final translatedEducations = (translatedJson['educations'] as List).map((json) => Education.fromJson(json)).toList();
      final translatedSkills = (translatedJson['skills'] as List).map((json) => Skill.fromJson(json)).toList();
      final translatedLanguages = (translatedJson['languages'] as List).map((json) => Language.fromJson(json)).toList();

      await isar.personalDatas.put(translatedPersonalData);
      await isar.experiences.putAll(translatedExperiences);
      await isar.educations.putAll(translatedEducations);
      await isar.skills.putAll(translatedSkills);
      await isar.languages.putAll(translatedLanguages);

      final newVersion = CurriculumVersion.create(
        name: 'Cópia em $targetLanguage de "${originalVersion.name}"',
        createdAt: DateTime.now(),
        languageCode: _mapLanguageToCode(targetLanguage),
      );

      newVersion.personalData.value = translatedPersonalData;
      newVersion.experiences.addAll(translatedExperiences);
      newVersion.educations.addAll(translatedEducations);
      newVersion.skills.addAll(translatedSkills);
      newVersion.languages.addAll(translatedLanguages);

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

  String _mapLanguageToCode(String languageName) {
    switch (languageName.toLowerCase()) {
      case 'english': return 'en-US';
      case 'spanish': return 'es-ES';
      case 'french': return 'fr-FR';
      case 'german': return 'de-DE';
      case 'italian': return 'it-IT';
      default: return 'en-US';
    }
  }
}