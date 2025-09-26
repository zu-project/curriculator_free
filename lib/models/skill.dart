import 'package:isar/isar.dart';

part 'skill.g.dart'; // <-- O erro aqui é temporário

// Usar um Enum é a melhor prática para campos com valores predefinidos
enum SkillLevel { beginner, intermediate, advanced, expert }

@collection
class Skill {
  Id id = Isar.autoIncrement;

  String? name;

  @enumerated
  SkillLevel level = SkillLevel.intermediate; // Um valor padrão
}