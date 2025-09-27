// lib/features/analyzer/analyzer_repository.dart
import 'dart:convert';
import 'package:curriculator_free/core/services/ai_service.dart';
import 'package:curriculator_free/core/services/isar_service.dart';
import 'package:curriculator_free/features/experience/experience_screen.dart';
import 'package:curriculator_free/features/personal_data/personal_data_screen.dart';
import 'package:curriculator_free/features/settings/settings_screen.dart';
import 'package:curriculator_free/features/skills/skills_screen.dart';
import 'package:curriculator_free/models/analysis_report.dart';
import 'package:curriculator_free/models/experience.dart';
import 'package:curriculator_free/models/personal_data.dart';
import 'package:curriculator_free/models/skill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

final analyzerRepositoryProvider = Provider((ref) {
  final isarService = ref.watch(isarServiceProvider);
  return AnalyzerRepository(isarService, ref);
});

// NOVO PROVIDER: Stream que observa a lista de relatórios
final analysisHistoryProvider = StreamProvider.autoDispose<List<AnalysisReport>>((ref) {
  return ref.watch(analyzerRepositoryProvider).watchAllReports();
});

class AnalyzerRepository {
  final IsarService _isarService;
  final Ref _ref;

  AnalyzerRepository(this._isarService, this._ref);

  // Assiste a todos os relatórios, do mais novo para o mais antigo
  Stream<List<AnalysisReport>> watchAllReports() async* {
    final isar = await _isarService.db;
    yield* isar.analysisReports.where().sortByCreatedAtDesc().watch(fireImmediately: true);
  }

  // Executa uma NOVA análise e SALVA o resultado
  Future<AnalysisReport> runAndSaveNewAnalysis() async {
    final apiKey = await _ref.read(apiKeyProvider.future);
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('Chave de API do Gemini não configurada! Adicione-a em Configurações.');
    }
    final aiService = AIService(apiKey: apiKey);
    final isar = await _isarService.db;

    final personalData = await isar.personalDatas.get(1);
    final experiences = await isar.experiences.where().sortByStartDateDesc().findAll();
    if (personalData == null) {
      throw Exception("Dados pessoais não encontrados. Preencha-os primeiro.");
    }

    final contentToAnalyze = {
      'summary': personalData.summary,
      'experiences': experiences.map((e) => e.toJson()).toList(),
    };

    final suggestionsMap = await aiService.analyzeContent(contentToAnalyzeJson: contentToAnalyze);

    final newReport = AnalysisReport()
      ..createdAt = DateTime.now()
      ..suggestionsJson = jsonEncode(suggestionsMap);

    await isar.writeTxn(() => isar.analysisReports.put(newReport));
    return newReport;
  }

  // Deleta um relatório específico
  Future<void> deleteReport(int reportId) async {
    final isar = await _isarService.db;
    await isar.writeTxn(() => isar.analysisReports.delete(reportId));
  }

  // Salva as mudanças em um relatório (depois de aplicar/descartar uma sugestão)
  Future<void> updateReport(AnalysisReport report) async {
    final isar = await _isarService.db;
    await isar.writeTxn(() => isar.analysisReports.put(report));
  }

  // Aplica a sugestão de resumo no registro principal de PersonalData.
  Future<void> applySummarySuggestion(String newSummary) async {
    final isar = await _isarService.db;
    await isar.writeTxn(() async {
      final personalData = await isar.personalDatas.get(1);
      if (personalData != null) {
        personalData.summary = newSummary;
        await isar.personalDatas.put(personalData);
      }
    });
    // Invalida o provider para que a tela de Dados Pessoais recarregue
    _ref.invalidate(personalDataProvider);
  }

  // Aplica a sugestão de descrição em uma experiência específica.
  Future<void> applyExperienceSuggestion(int experienceId,
      String newDescription) async {
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

    // 1. Pega os nomes de todas as habilidades já existentes e coloca em um Set para busca rápida.
    final existingSkills = await isar.skills.where().findAll();
    final existingSkillNames = existingSkills.map((s) =>
        s.name.trim().toLowerCase()).toSet();

    final newSkills = suggestedSkills.map((s) {
      final skillJson = s as Map<String, dynamic>;
      return Skill.fromJson(skillJson);
    })
    // 2. Filtra a lista de sugestões, mantendo apenas aquelas que NÃO existem no banco.
        .where((suggestedSkill) =>
    !existingSkillNames.contains(suggestedSkill.name.trim().toLowerCase()))
        .toList();

    // 3. Se houver alguma habilidade nova para adicionar, salva no banco.
    if (newSkills.isNotEmpty) {
      await isar.writeTxn(() => isar.skills.putAll(newSkills));
    }

    // Invalida o provider para que a tela de Habilidades recarregue de qualquer forma
    _ref.invalidate(skillsStreamProvider);
  }
}