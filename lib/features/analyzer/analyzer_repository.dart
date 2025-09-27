//C:\Users\ziofl\StudioProjects\curriculator_free\lib\features\analyzer\analyzer_repository.dart
import 'package:curriculator_free/core/services/ai_service.dart';
import 'package:curriculator_free/core/services/isar_service.dart';
import 'package:curriculator_free/features/personal_data/personal_data_screen.dart';
import 'package:curriculator_free/features/settings/settings_screen.dart';
import 'package:curriculator_free/features/skills/skills_screen.dart';
import 'package:curriculator_free/models/experience.dart';
import 'package:curriculator_free/models/personal_data.dart';
import 'package:curriculator_free/models/skill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:curriculator_free/features/experience/experience_screen.dart';

// Provider para o repositório
final analyzerRepositoryProvider = Provider((ref) {
  final apiKeyAsyncValue = ref.watch(apiKeyProvider);
  final isarService = ref.watch(isarServiceProvider);
  final apiKey = apiKeyAsyncValue.valueOrNull ?? '';
  final aiService = AIService(apiKey: apiKey);

  return AnalyzerRepository(isarService, aiService, ref);
});

class AnalyzerRepository {
  final IsarService _isarService;
  final AIService _aiService;
  final Ref _ref;

  AnalyzerRepository(this._isarService, this._aiService, this._ref);

  // Busca os dados, chama a IA e retorna as sugestões.
  Future<Map<String, dynamic>> getAnalysis() async {
    if (_aiService.apiKey.isEmpty) {
      throw Exception('Chave de API do Gemini não configurada! Adicione-a em Configurações.');
    }

    final isar = await _isarService.db;

    final personalData = await isar.personalDatas.get(1);
    final experiences = await isar.experiences.where().findAll();

    if (personalData == null) {
      throw Exception("Dados pessoais não encontrados. Preencha-os primeiro.");
    }

    final contentToAnalyze = {
      'summary': personalData.summary,
      'experiences': experiences.map((e) => e.toJson()).toList(),
    };

    return _aiService.analyzeContent(contentToAnalyzeJson: contentToAnalyze);
  }

  // Aplica a sugestão de resumo no registro principal de PersonalData.
  Future<void> applySummarySuggestion(String newSummary) async {
    final isar = await _isarService.db;
    final personalData = await isar.personalDatas.get(1);
    if (personalData != null) {
      personalData.summary = newSummary;
      await isar.writeTxn(() => isar.personalDatas.put(personalData));
      // Invalida o provider para que a tela de Dados Pessoais recarregue
      _ref.invalidate(personalDataProvider);
    }
  }

  // Aplica a sugestão de descrição em uma experiência específica.
  Future<void> applyExperienceSuggestion(int experienceId, String newDescription) async {
    final isar = await _isarService.db;
    await isar.writeTxn(() async {
      final experience = await isar.experiences.get(experienceId);
      if (experience != null) {
        experience.description = newDescription;
        await isar.experiences.put(experience);
      }
    });
    // Invalida o provider para que a tela de Experiências recarregue
    _ref.invalidate(experiencesStreamProvider);
  }

  // Adiciona as habilidades sugeridas ao banco de dados.
  Future<void> addSuggestedSkills(List<dynamic> suggestedSkills) async {
    final isar = await _isarService.db;

    final newSkills = suggestedSkills.map((s) {
      final skillJson = s as Map<String, dynamic>;
      return Skill.fromJson(skillJson);
    }).toList();

    await isar.writeTxn(() => isar.skills.putAll(newSkills));
    // Invalida o provider para que a tela de Habilidades recarregue
    _ref.invalidate(skillsStreamProvider);
  }
}