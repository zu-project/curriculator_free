import 'package:isar/isar.dart';

part 'education.g.dart'; // <-- O erro aqui é temporário

@collection
class Education {
  Id id = Isar.autoIncrement;

  String? institution; // Ex: "Universidade Federal de..."
  String? degree; // Ex: "Bacharelado em Ciência da Computação"
  String? fieldOfStudy; // Campo de estudo, se o grau não for específico
  DateTime? startDate;
  DateTime? endDate;

  /// Para notas, honras, projetos de conclusão de curso, etc.
  String? description;
}