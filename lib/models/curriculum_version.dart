// lib/models/curriculum_version.dart

import 'package:curriculator_free/models/education.dart';
import 'package:curriculator_free/models/experience.dart';
import 'package:curriculator_free/models/language.dart';
import 'package:curriculator_free/models/personal_data.dart';
import 'package:curriculator_free/models/skill.dart';
import 'package:isar/isar.dart';

part 'curriculum_version.g.dart';

@collection
class CurriculumVersion {
  Id id = Isar.autoIncrement;

  /// O nome que o usuário dará a esta versão.
  /// Ex: "Currículo para Vaga Flutter Pleno", "CV Vaga Gerente (Inglês)"
  String name;

  DateTime createdAt;

  // --- A Mágica Acontece Aqui: IsarLinks ---
  // Estes campos não armazenam os objetos inteiros, apenas "links" (referências)
  // para os registros que o usuário selecionou para esta versão específica.

  // Um currículo só tem um conjunto de dados pessoais.
  final personalData = IsarLink<PersonalData>();

  // Um currículo pode ter várias experiências, formações, etc.
  final experiences = IsarLinks<Experience>();
  final educations = IsarLinks<Education>();
  final skills = IsarLinks<Skill>();
  final languages = IsarLinks<Language>();

  // Construtor
  CurriculumVersion({required this.name, required this.createdAt});
}