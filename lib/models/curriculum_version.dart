import 'package:curriculator_free/models/education.dart';
import 'package:curriculator_free/models/experience.dart';
import 'package:curriculator_free/models/language.dart';
import 'package:curriculator_free/models/personal_data.dart';
import 'package:curriculator_free/models/skill.dart';
import 'package:isar/isar.dart';

part 'curriculum_version.g.dart';

/// Representa uma versão específica e customizada de um currículo.
///
/// Este modelo é a peça central do aplicativo. Ele não duplica os dados,
/// mas sim "linka" para os registros de PersonalData, Experience, etc.,
/// que o usuário selecionou para compor esta versão.
///
/// Otimizações e Melhorias:
/// 1. Armazena as preferências de exportação (template, cor, fonte) para uma melhor UX.
/// 2. Inclui um `languageCode` para suportar currículos traduzidos.
/// 3. Índice em `createdAt` para ordenação rápida na dashboard.
@collection
class CurriculumVersion {
  CurriculumVersion()
      : name = '',
        createdAt = DateTime.now(),
        languageCode = 'pt-BR';
  /// ID único e auto-incrementado, gerenciado pelo Isar.
  Id id = Isar.autoIncrement;

  /// O nome que o usuário deu a esta versão (ex: "CV para Vaga Flutter Pleno").
  /// É não-nulo para garantir a identificação.
  String name;

  /// A data e hora em que a versão foi criada.
  /// Indexado para ordenar as versões da mais recente para a mais antiga na dashboard.
  @Index()
  DateTime createdAt;

  /// O código do idioma desta versão do currículo (ex: "pt-BR", "en-US").
  /// O padrão é o português do Brasil. Essencial para a funcionalidade de tradução.
  String languageCode;

  // --- Preferências de Exportação Armazenadas ---
  // Salvar estas preferências melhora a experiência do usuário, pois o app
  // "lembra" da última configuração usada para esta versão específica.

  /// O nome do último template de PDF usado para esta versão.
  String? lastUsedTemplate;

  /// A última cor de destaque usada, armazenada como uma string hexadecimal (ex: "#FF4A148C").
  String? accentColorHex;

  /// O último tamanho de fonte base usado.
  double? fontSize;
  // Armazenam as opções de inclusão para esta versão específica.

  bool includeSummary = true;
  bool includeAvailability = true;
  bool includeVehicle = true;
  bool includeLicense = true;
  bool includeSocialLinks = true;
  bool includePhoto = true;

  // --- Links para os Dados ---
  // Estes campos não armazenam os objetos, apenas referências (ponteiros) para eles.
  // Isso é extremamente eficiente em termos de espaço e performance.

  /// Link para o registro de PersonalData associado a esta versão.
  final personalData = IsarLink<PersonalData>();

  /// Links para as experiências profissionais selecionadas para esta versão.
  final experiences = IsarLinks<Experience>();

  /// Links para as formações acadêmicas selecionadas.
  final educations = IsarLinks<Education>();

  /// Links para as habilidades selecionadas.
  final skills = IsarLinks<Skill>();

  /// Links para os idiomas selecionados.
  final languages = IsarLinks<Language>();

  /// Construtor principal.
  CurriculumVersion.create({
    required this.name,
    required this.createdAt,
    this.languageCode = 'pt-BR',
    this.lastUsedTemplate,
    this.accentColorHex,
    this.fontSize,
  });
}