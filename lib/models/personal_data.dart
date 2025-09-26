import 'package:isar/isar.dart';

part 'personal_data.g.dart'; // <-- O erro aqui é temporário

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
}