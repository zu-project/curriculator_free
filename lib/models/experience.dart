//C:\Users\ziofl\StudioProjects\curriculator_free\lib\models\experience.dart
import 'package:isar/isar.dart';

part 'experience.g.dart';

/// Representa uma única experiência profissional no currículo do usuário.
///
/// Otimizações e Melhorias:
/// 1. Campos chave `jobTitle` e `company` são não-nulos para garantir integridade.
/// 2. Índice `@Index` em `startDate` para ordenação cronológica ultra-rápida.
/// 3. Índice `@Index` em `company` para futuras funcionalidades de busca e filtro.
/// 4. Novo campo `isFeatured` para destacar experiências importantes.
/// 5. Métodos `toJson` e `fromJson` completos para integração com a IA.
@collection
class Experience {
  Experience();
  /// ID único e auto-incrementado, gerenciado pelo Isar.
  Id id = Isar.autoIncrement;

  /// O cargo ou função exercida (ex: "Desenvolvedor Flutter Sênior").
  /// É não-nulo para garantir que toda experiência tenha um cargo.
  String jobTitle = '';

  /// O nome da empresa onde a experiência ocorreu.
  /// É não-nulo e indexado para performance em filtros.
  @Index(type: IndexType.value, caseSensitive: false)
  String company = '';

  /// A localização da empresa (ex: "São Paulo, SP" ou "Remoto").
  String? location;

  /// A data de início da experiência. Essencial para ordenação cronológica.
  /// O índice composto melhora drasticamente a performance da ordenação.
  @Index()
  DateTime? startDate;

  /// A data de término da experiência. É nula se for o emprego atual.
  DateTime? endDate;

  /// Flag para indicar se esta é a experiência de trabalho atual do usuário.
  /// Se `true`, a data de término (`endDate`) deve ser ignorada.
  bool isCurrent = false;

  /// Descrição detalhada das responsabilidades, conquistas e projetos.
  /// É aqui que a IA fará a maior parte de suas análises e sugestões.
  String? description;

  /// Flag opcional para marcar esta experiência como um destaque no currículo.
  /// Útil para chamar a atenção do recrutador para papéis importantes.
  bool isFeatured = false;

  /// Converte a instância para um Mapa (JSON) para envio à API de IA.
  Map<String, dynamic> toJson() => {
    'id': id,
    'jobTitle': jobTitle,
    'company': company,
    'location': location,
    'description': description,
    // Datas são mantidas para contexto, mas o texto é o foco da IA.
    'startDate': startDate?.toIso8601String(),
    'endDate': endDate?.toIso8601String(),
    'isCurrent': isCurrent,
  };

  /// Cria uma instância a partir de um Mapa (JSON) recebido da IA (ex: em traduções).
  factory Experience.fromJson(Map<String, dynamic> json) {
    return Experience()
      ..jobTitle = json['jobTitle'] ?? ''
      ..company = json['company'] ?? ''
      ..location = json['location']
      ..description = json['description']
      ..startDate = json['startDate'] != null ? DateTime.tryParse(json['startDate']) : null
      ..endDate = json['endDate'] != null ? DateTime.tryParse(json['endDate']) : null
      ..isCurrent = json['isCurrent'] ?? false;
    // 'isFeatured' não é manipulado pela IA, é uma escolha do usuário.
  }
}