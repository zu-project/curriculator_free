// C:\Users\ziofl\StudioProjects\curriculator_free\lib\models\education.dart

import 'package:isar/isar.dart';

part 'education.g.dart'; // O ponto mais importante que você já corrigiu é manter este nome em minúsculas!

@collection
class Education {
  Id id = Isar.autoIncrement;

  String? institution;
  String? degree;
  String? fieldOfStudy;

  // --- Otimização Adicionada Aqui ---
  @Index() // Adiciona um índice a este campo para buscas e ordenação mais rápidas.
  DateTime? startDate;

  DateTime? endDate;
  bool inProgress = false;

  /// Para notas, honras, projetos de conclusão de curso, etc.
  String? description;
}