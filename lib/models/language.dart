//C:\Users\ziofl\StudioProjects\curriculator_free\lib\models\language.dart
import 'package:isar/isar.dart';

part 'language.g.dart';

/// Enum para definir o nível de proficiência em um idioma.
enum LanguageProficiency {
  basic,
  intermediate,
  advanced,
  fluent,
  native;

  /// Getter para exibir o nome do nível em Português na interface do usuário.
  String get displayName {
    switch (this) {
      case LanguageProficiency.basic:
        return 'Básico';
      case LanguageProficiency.intermediate:
        return 'Intermediário';
      case LanguageProficiency.advanced:
        return 'Avançado';
      case LanguageProficiency.fluent:
        return 'Fluente';
      case LanguageProficiency.native:
        return 'Nativo';
    }
  }
}

/// Representa um idioma que o usuário conhece e seu nível de proficiência.
@collection
class Language {
  Language();

  Id id = Isar.autoIncrement;
  bool isFeatured = false;

  @Index(type: IndexType.value, caseSensitive: false)
  String languageName = '';

  @enumerated
  LanguageProficiency proficiency = LanguageProficiency.intermediate;

  /// Converte a instância para um Mapa (JSON) para a IA.
  /// Mantemos os valores em inglês aqui para consistência com a IA.
  Map<String, dynamic> toJson() => {
    'id': id,
    'languageName': languageName,
    'proficiency': proficiency.name,
  };

  /// Cria uma instância a partir de um Mapa (JSON) vindo da IA.
  factory Language.fromJson(Map<String, dynamic> json) {
    return Language()
      ..languageName = json['languageName'] ?? ''
      ..proficiency = LanguageProficiency.values.firstWhere(
            (e) => e.name == json['proficiency'],
        orElse: () => LanguageProficiency.intermediate,
      );
  }
}