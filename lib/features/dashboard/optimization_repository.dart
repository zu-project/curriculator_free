import 'dart:convert';
import 'package:curriculator_free/core/services/ai_service.dart';
import 'package:curriculator_free/core/services/isar_service.dart';
import 'package:curriculator_free/features/settings/settings_screen.dart';
import 'package:curriculator_free/models/curriculum_version.dart';
import 'package:curriculator_free/models/education.dart';
import 'package:curriculator_free/models/experience.dart';
import 'package:curriculator_free/models/language.dart';
import 'package:curriculator_free/models/personal_data.dart';
import 'package:curriculator_free/models/skill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

// Provider para o novo repositório
final optimizationRepositoryProvider = Provider((ref) {
  final apiKeyAsyncValue = ref.watch(apiKeyProvider);
  final isarService = ref.watch(isarServiceProvider);
  final apiKey = apiKeyAsyncValue.valueOrNull ?? '';

  final aiService = AIService(apiKey: apiKey);

  return OptimizationRepository(isarService, aiService);
});

class OptimizationRepository {
  final IsarService _isarService;
  final AIService _aiService;

  OptimizationRepository(this._isarService, this._aiService);

  Future<void> createOptimizedVersion({
    required String jobDescription,
  }) async {
    if (_aiService.apiKey.isEmpty) {
      throw Exception('Chave de API do Gemini não configurada! Adicione-a em Configurações.');
    }

    final isar = await _isarService.db;

    final allPersonalData = await isar.personalDatas.get(1);
    if (allPersonalData == null) throw Exception("Dados pessoais não encontrados. Por favor, preencha-os primeiro.");

    final allExperiences = await isar.experiences.where().findAll();
    final allEducations = await isar.educations.where().findAll();
    final allSkills = await isar.skills.where().findAll();
    final allLanguages = await isar.languages.where().findAll();

    final fullCurriculumJson = {
      'summary': allPersonalData.summary,
      'experiences': allExperiences.map((e) => e.toJson()).toList(),
      'educations': allEducations.map((e) => e.toJson()).toList(),
      'skills': allSkills.map((s) => s.toJson()).toList(),
      'languages': allLanguages.map((l) => l.toJson()).toList(),
    };

    final suggestion = await _aiService.analyzeAndSuggestVersion(
      jobDescription: jobDescription,
      fullCurriculumJson: fullCurriculumJson,
    );

    await isar.writeTxn(() async {
      // Cria uma cópia completa dos dados pessoais, mas com o resumo sugerido.
      final optimizedPersonalData = PersonalData()
        ..photoPath = allPersonalData.photoPath
        ..name = allPersonalData.name
        ..email = allPersonalData.email
        ..phone = allPersonalData.phone
        ..address = allPersonalData.address
        ..linkedinUrl = allPersonalData.linkedinUrl
        ..portfolioUrl = allPersonalData.portfolioUrl
        ..birthDate = allPersonalData.birthDate
        ..hasTravelAvailability = allPersonalData.hasTravelAvailability
        ..hasRelocationAvailability = allPersonalData.hasRelocationAvailability
        ..hasCar = allPersonalData.hasCar
        ..hasMotorcycle = allPersonalData.hasMotorcycle
        ..licenseCategories = allPersonalData.licenseCategories
        ..summary = suggestion['suggested_summary'] as String? ?? allPersonalData.summary;

      await isar.personalDatas.put(optimizedPersonalData);

      final expIds = (suggestion['relevant_experience_ids'] as List?)?.cast<int>().toSet() ?? {};
      final eduIds = (suggestion['relevant_education_ids'] as List?)?.cast<int>().toSet() ?? {};
      final skillIds = (suggestion['relevant_skill_ids'] as List?)?.cast<int>().toSet() ?? {};
      final langIds = (suggestion['relevant_language_ids'] as List?)?.cast<int>().toSet() ?? {};

      final selectedExperiences = await isar.experiences.getAll(expIds.toList());
      final selectedEducations = await isar.educations.getAll(eduIds.toList());
      final selectedSkills = await isar.skills.getAll(skillIds.toList());
      final selectedLanguages = await isar.languages.getAll(langIds.toList());

      // --- CORREÇÃO APLICADA AQUI ---
      // Usamos o construtor padrão (vazio) e depois definimos os campos.
      final newVersion = CurriculumVersion()
        ..name = suggestion['new_version_name'] as String? ?? 'Versão Otimizada por IA'
        ..createdAt = DateTime.now();

      // Linka os dados selecionados à nova versão
      newVersion.personalData.value = optimizedPersonalData;
      newVersion.experiences.addAll(selectedExperiences.whereType<Experience>());
      newVersion.educations.addAll(selectedEducations.whereType<Education>());
      newVersion.skills.addAll(selectedSkills.whereType<Skill>());
      newVersion.languages.addAll(selectedLanguages.whereType<Language>());

      // Salva a nova versão e seus links no banco de dados.
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
}