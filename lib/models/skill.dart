//C:\Users\ziofl\StudioProjects\curriculator_free\lib\models\skill.dart
import 'package:isar/isar.dart';

part 'skill.g.dart';

/// Enum para definir o tipo de uma habilidade (Técnica ou Comportamental).
enum SkillType {
  hardSkill,
  softSkill,
}

/// Enum para o nível de proficiência em uma habilidade.
enum SkillLevel {
  beginner,
  intermediate,
  advanced,
  expert;

  /// Getter para exibir o nome do nível em Português na interface do usuário.
  String get displayName {
    switch (this) {
      case SkillLevel.beginner:
        return 'Iniciante';
      case SkillLevel.intermediate:
        return 'Intermediário';
      case SkillLevel.advanced:
        return 'Avançado';
      case SkillLevel.expert:
        return 'Especialista';
    }
  }
}

/// Representa uma única habilidade (skill) que o usuário possui.
@collection
class Skill {
  Skill();

  Id id = Isar.autoIncrement;
  bool isFeatured = false;

  @Index(type: IndexType.value, caseSensitive: false)
  String name = '';

  @enumerated
  SkillType type = SkillType.hardSkill;

  @enumerated
  SkillLevel level = SkillLevel.intermediate;

  @Index(type: IndexType.value, caseSensitive: false)
  String? category;

  /// Converte a instância para um Mapa (JSON) para a IA.
  /// Mantemos os valores em inglês aqui para consistência com a IA.
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type.name,
    'level': level.name,
    'category': category,
  };

  /// Cria uma instância a partir de um Mapa (JSON) vindo da IA.
  factory Skill.fromJson(Map<String, dynamic> json) {
    return Skill()
      ..name = json['name'] ?? ''
      ..type = SkillType.values.firstWhere(
            (e) => e.name == json['type'],
        orElse: () => SkillType.hardSkill,
      )
      ..level = SkillLevel.values.firstWhere(
            (e) => e.name == json['level'],
        orElse: () => SkillLevel.intermediate,
      )
      ..category = json['category'];
  }
}