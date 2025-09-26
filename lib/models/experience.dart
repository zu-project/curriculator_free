import 'package:isar/isar.dart';

part 'experience.g.dart'; // <-- O erro aqui é temporário

@collection
class Experience {
  Id id = Isar.autoIncrement;

  String? jobTitle;
  String? company;
  String? location;
  DateTime? startDate;
  DateTime? endDate;

  /// Usado para marcar se este é o emprego atual (para não mostrar data de término)
  bool isCurrent = false;

  /// Descrição das atividades, responsabilidades, etc.
  String? description;
}