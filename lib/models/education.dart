//C:\Users\ziofl\StudioProjects\curriculator_free\lib\models\education.dart
import 'package:isar/isar.dart';

part 'education.g.dart';

/// Representa uma única formação acadêmica, curso ou certificação no currículo.
///
/// Otimizações e Melhorias:
/// 1. Campos chave (`institution`, `degree`, `fieldOfStudy`) são não-nulos.
/// 2. Índice `@Index` em `startDate` para ordenação cronológica rápida.
/// 3. Índice `@Index` em `institution` para otimizar futuras buscas.
/// 4. Novo campo `isFeatured` para destacar formações importantes.
/// 5. Métodos `toJson` e `fromJson` completos para integração com a IA.
@collection
class Education {
  Education();
  /// ID único e auto-incrementado, gerenciado pelo Isar.
  Id id = Isar.autoIncrement;

  /// Nome da instituição de ensino (ex: "Universidade de São Paulo").
  /// É não-nulo e indexado para performance em filtros.
  @Index(type: IndexType.value, caseSensitive: false)
  String institution = '';

  /// O tipo de formação (ex: "Bacharelado", "Mestrado", "Curso Técnico").
  /// É não-nulo para garantir a clareza da informação.
  String degree = '';

  /// O campo de estudo ou nome do curso (ex: "Ciência da Computação").
  /// É não-nulo.
  String fieldOfStudy = '';

  /// A data de início do curso. Essencial para ordenação cronológica.
  /// O índice melhora drasticamente a performance da ordenação.
  @Index()
  DateTime? startDate;

  /// A data de término ou conclusão do curso. É nula se o curso estiver em andamento.
  DateTime? endDate;

  /// Flag para indicar se o curso ainda está em andamento.
  /// Se `true`, a data de término (`endDate`) deve ser ignorada.
  bool inProgress = false;

  /// Descrição opcional para adicionar detalhes como notas, honras,
  /// projetos de conclusão de curso, ou escopo da certificação.
  String? description;

  /// Flag opcional para marcar esta formação como um destaque no currículo.
  /// Útil para chamar a atenção para o seu diploma mais relevante.
  bool isFeatured = false;

  /// Converte a instância para um Mapa (JSON) para envio à API de IA.
  Map<String, dynamic> toJson() => {
    'id': id,
    'institution': institution,
    'degree': degree,
    'fieldOfStudy': fieldOfStudy,
    'description': description,
    // Datas são mantidas para contexto.
    'startDate': startDate?.toIso8601String(),
    'endDate': endDate?.toIso8601String(),
    'inProgress': inProgress,
  };

  /// Cria uma instância a partir de um Mapa (JSON) recebido da IA (ex: em traduções).
  factory Education.fromJson(Map<String, dynamic> json) {
    return Education()
      ..institution = json['institution'] ?? ''
      ..degree = json['degree'] ?? ''
      ..fieldOfStudy = json['fieldOfStudy'] ?? ''
      ..description = json['description']
      ..startDate = json['startDate'] != null ? DateTime.tryParse(json['startDate']) : null
      ..endDate = json['endDate'] != null ? DateTime.tryParse(json['endDate']) : null
      ..inProgress = json['inProgress'] ?? false;
    // 'isFeatured' não é manipulado pela IA, é uma escolha do usuário.
  }
}