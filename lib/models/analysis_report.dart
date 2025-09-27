// lib/models/analysis_report.dart
import 'package:isar/isar.dart';

part 'analysis_report.g.dart';

@collection
class AnalysisReport {
  Id id = Isar.autoIncrement;

  @Index()
  late DateTime createdAt;

  /// Armazena o JSON completo retornado pela IA.
  /// Usar uma String é a forma mais flexível de guardar dados semi-estruturados.
  late String suggestionsJson;
}