//C:\Users\ziofl\StudioProjects\curriculator_free\lib\models\language.dart
import 'package:isar/isar.dart';

part 'language.g.dart';

/// Enum para definir o nível de proficiência em um idioma.
/// Os valores seguem uma ordem lógica de proficiência.
enum LanguageProficiency {
  basic,
  intermediate,
  advanced,
  fluent,
  native,
}

/// Representa um idioma que o usuário conhece e seu nível de proficiência.
///
/// Otimizações e Melhorias:
/// 1. Campo `languageName` é não-nulo para garantir a integridade dos dados.
/// 2. Índice `@Index` no `languageName` para otimizar a ordenação e busca.
/// 3. Métodos `toJson` e `fromJson` para facilitar a integração com a IA.
@collection
class Language {
  Language();
  /// ID único e auto-incrementado, gerenciado pelo Isar.
  Id id = Isar.autoIncrement;
  bool isFeatured = false;

  /// O nome do idioma (ex: "Inglês", "Espanhol").
  /// É não-nulo para garantir que todo idioma tenha um nome.
  /// O índice melhora a performance e o `caseSensitive: false` evita duplicatas.
  @Index(type: IndexType.value, caseSensitive: false)
  String languageName = '';

  /// O nível de proficiência do usuário no idioma.
  /// O valor padrão é 'intermediate'. `@enumerated` armazena o tipo de forma otimizada.
  @enumerated
  LanguageProficiency proficiency = LanguageProficiency.intermediate;

  /// Converte a instância do objeto Language para um Mapa (formato JSON).
  /// Essencial para enviar os dados para a API de Inteligência Artificial.
  Map<String, dynamic> toJson() => {
    'id': id,
    'languageName': languageName,
    'proficiency': proficiency.name, // .name converte o enum para uma String (ex: "intermediate")
  };

  /// Cria uma instância de Language a partir de um Mapa (formato JSON).
  /// Essencial para processar a resposta da IA.
  factory Language.fromJson(Map<String, dynamic> json) {
    return Language()
      ..languageName = json['languageName'] ?? ''
      ..proficiency = LanguageProficiency.values.firstWhere(
            (e) => e.name == json['proficiency'],
        orElse: () => LanguageProficiency.intermediate, // Valor padrão em caso de erro
      );
  }
}