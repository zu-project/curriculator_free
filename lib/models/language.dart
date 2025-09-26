import 'package:isar/isar.dart';

part 'language.g.dart'; // <-- O erro aqui é temporário

// Enum para proficiência
enum LanguageProficiency { basic, intermediate, advanced, fluent, native }

@collection
class Language {
  Id id = Isar.autoIncrement;

  String? languageName;

  @enumerated
  LanguageProficiency proficiency = LanguageProficiency.intermediate;
}