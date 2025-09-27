//C:\Users\ziofl\StudioProjects\curriculator_free\lib\features\versions\version_editor_repository.dart
import 'package:curriculator_free/core/services/isar_service.dart';
import 'package:curriculator_free/models/curriculum_version.dart';
import 'package:curriculator_free/models/education.dart';
import 'package:curriculator_free/models/experience.dart';
import 'package:curriculator_free/models/language.dart';
import 'package:curriculator_free/models/personal_data.dart';
import 'package:curriculator_free/models/skill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Importação que faltava para o Provider
import 'package:isar/isar.dart';

/// Agrupa todos os dados necessários para a tela de edição de uma versão.
class VersionEditorDataBundle {
  final CurriculumVersion? versionToEdit;
  final PersonalData? personalData;
  final List<Experience> allExperiences;
  final List<Education> allEducations;
  final List<Skill> allSkills;
  final List<Language> allLanguages;

  VersionEditorDataBundle({
    this.versionToEdit,
    this.personalData,
    required this.allExperiences,
    required this.allEducations,
    required this.allSkills,
    required this.allLanguages,
  });
}

/// Provider para o VersionEditorRepository.
final versionEditorRepositoryProvider = Provider((ref) {
  return VersionEditorRepository(ref.watch(isarServiceProvider));
});


/// Repositório responsável pela lógica de dados da tela de edição de versão.
class VersionEditorRepository {
  final IsarService _isarService;
  VersionEditorRepository(this._isarService);

  /// Busca todos os dados necessários para popular a tela de edição.
  Future<VersionEditorDataBundle> fetchData(int? versionId) async {
    final isar = await _isarService.db;
    CurriculumVersion? version;

    if (versionId != null) {
      // --- CORREÇÃO DE TYPO ---
      version = await isar.curriculumVersions.get(versionId);
      if (version != null) {
        await Future.wait([
          version.experiences.load(),
          version.educations.load(),
          version.skills.load(),
          version.languages.load(),
        ]);
      }
    }

    final allPersonalData = await isar.personalDatas.get(1);
    // --- CORREÇÃO DE TYPO ---
    final allExperiences = await isar.experiences.where().sortByStartDateDesc().findAll();
    final allEducations = await isar.educations.where().sortByStartDateDesc().findAll();
    final allSkills = await isar.skills.where().sortByName().findAll();
    final allLanguages = await isar.languages.where().sortByLanguageName().findAll();

    return VersionEditorDataBundle(
      versionToEdit: version,
      personalData: allPersonalData,
      allExperiences: allExperiences,
      allEducations: allEducations,
      allSkills: allSkills,
      allLanguages: allLanguages,
    );
  }

  /// Salva ou atualiza uma versão do currículo.
  Future<int> saveVersion({
    int? versionId,
    required String name,
    required Set<int> selectedExpIds,
    required Set<int> selectedEduIds,
    required Set<int> selectedSkillIds,
    required Set<int> selectedLangIds,
    required bool includeSummary,
    required bool includeAvailability,
    required bool includeVehicle,
    required bool includeLicense,
    required bool includeSocialLinks,
    required bool includePhoto,
  }) async {
    final isar = await _isarService.db;

    // --- CORREÇÃO DE TYPO ---
    final versionToSave = (versionId != null ? await isar.curriculumVersions.get(versionId) : null) ?? CurriculumVersion();

    versionToSave.name = name.trim();
    if (versionId == null) {
      versionToSave.createdAt = DateTime.now();
    }

    versionToSave.includeSummary = includeSummary;
    versionToSave.includeAvailability = includeAvailability;
    versionToSave.includeVehicle = includeVehicle;
    versionToSave.includeLicense = includeLicense;
    versionToSave.includeSocialLinks = includeSocialLinks;
    versionToSave.includePhoto = includePhoto;

    final personalData = await isar.personalDatas.get(1);
    final selectedExperiences = await isar.experiences.getAll(selectedExpIds.toList());
    final selectedEducations = await isar.educations.getAll(selectedEduIds.toList());
    final selectedSkills = await isar.skills.getAll(selectedSkillIds.toList());
    final selectedLanguages = await isar.languages.getAll(selectedLangIds.toList());

    late int savedId;

    await isar.writeTxn(() async {
      versionToSave.personalData.value = personalData;
      versionToSave.experiences.clear();
      versionToSave.experiences.addAll(selectedExperiences.whereType<Experience>());
      versionToSave.educations.clear();
      versionToSave.educations.addAll(selectedEducations.whereType<Education>());
      versionToSave.skills.clear();
      versionToSave.skills.addAll(selectedSkills.whereType<Skill>());
      versionToSave.languages.clear();
      versionToSave.languages.addAll(selectedLanguages.whereType<Language>());

      // --- CORREÇÃO DE TYPO ---
      savedId = await isar.curriculumVersions.put(versionToSave);

      await Future.wait([
        versionToSave.personalData.save(),
        versionToSave.experiences.save(),
        versionToSave.educations.save(),
        versionToSave.skills.save(),
        versionToSave.languages.save(),
      ]);
    });

    return savedId;
  }
}