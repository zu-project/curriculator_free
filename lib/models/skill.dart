//C:\Users\ziofl\StudioProjects\curriculator_free\lib\models\skill.dart
import 'package:isar/isar.dart';

part 'skill.g.dart';

/// Enum para definir o tipo de uma habilidade (Técnica ou Comportamental).
/// Isso será crucial para agrupar as habilidades no currículo gerado.
enum SkillType {
  hardSkill,
  softSkill,
}

/// Enum para o nível de proficiência em uma habilidade.
enum SkillLevel {
  beginner,
  intermediate,
  advanced,
  expert,
}

/// Representa uma única habilidade (skill) que o usuário possui.
///
/// Este modelo foi otimizado com:
/// 1. Índices (`@Index`) nos campos de texto para buscas e ordenação muito mais rápidas.
/// 2. Campo 'category' para permitir agrupamento futuro (ex: "Linguagens", "Ferramentas").
/// 3. Campo 'name' não-nulo para garantir a integridade dos dados.
/// 4. Métodos `toJson` e `fromJson` para facilitar a integração com a IA.
@collection
class Skill {
  Skill();
  /// ID único e auto-incrementado, gerenciado pelo Isar.
  Id id = Isar.autoIncrement;
  bool isFeatured = false;

  /// O nome da habilidade (ex: "Flutter", "Gestão de Projetos").
  /// É não-nulo para garantir que toda habilidade tenha um nome.
  /// O índice `caseSensitive: false` melhora a busca e evita duplicatas como "flutter" e "Flutter".
  @Index(type: IndexType.value, caseSensitive: false)
  String name = '';

  /// O tipo da habilidade, para separar Hard Skills de Soft Skills.
  /// O valor padrão é 'hardSkill'. `@enumerated` armazena o tipo de forma otimizada.
  @enumerated
  SkillType type = SkillType.hardSkill;

  /// O nível de proficiência do usuário na habilidade.
  @enumerated
  SkillLevel level = SkillLevel.intermediate;

  /// Uma categoria opcional para agrupar habilidades no futuro.
  /// Exemplos: "Linguagens de Programação", "Ferramentas DevOps", "Design".
  /// O índice facilita a filtragem e o agrupamento.
  @Index(type: IndexType.value, caseSensitive: false)
  String? category;

  /// Converte a instância do objeto Skill para um Mapa (formato JSON).
  /// Essencial para enviar os dados para a API de Inteligência Artificial.
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type.name, // .name converte o enum para uma String (ex: "hardSkill")
    'level': level.name,
    'category': category,
  };

  /// Cria uma instância de Skill a partir de um Mapa (formato JSON).
  /// Essencial para processar a resposta da IA (ex: sugestão de novas habilidades).
  factory Skill.fromJson(Map<String, dynamic> json) {
    return Skill()
      ..name = json['name'] ?? ''
      ..type = SkillType.values.firstWhere(
            (e) => e.name == json['type'],
        orElse: () => SkillType.hardSkill, // Valor padrão em caso de erro
      )
      ..level = SkillLevel.values.firstWhere(
            (e) => e.name == json['level'],
        orElse: () => SkillLevel.intermediate,
      )
      ..category = json['category'];
  }
}