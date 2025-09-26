import 'package:isar/isar.dart';

part 'personal_data.g.dart';

@collection
class PersonalData {
  Id id = Isar.autoIncrement;

  String? name;

  @Index(type: IndexType.value)
  String? email;

  String? phone;
  String? address;
  String? linkedinUrl;
  String? portfolioUrl;

  /// Este é o campo para o "resumo" ou "objetivo" do currículo
  String? summary;

  // --- NOVOS CAMPOS ADICIONADOS ---

  /// Data de nascimento para cálculo da idade
  DateTime? birthDate;

  /// Disponibilidade para viagens (Sim/Não)
  bool hasTravelAvailability = false;

  /// Disponibilidade para mudança (Sim/Não)
  bool hasRelocationAvailability = false;

  /// Possui carro próprio
  bool hasCar = false;

  /// Possui moto própria
  bool hasMotorcycle = false;

  /// Lista das categorias de habilitação (Ex: ["A", "B"])
  List<String> licenseCategories = [];
}