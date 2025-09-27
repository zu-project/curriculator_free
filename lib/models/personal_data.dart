//C:\Users\ziofl\StudioProjects\curriculator_free\lib\models\personal_data.dart
import 'package:isar/isar.dart';

part 'personal_data.g.dart';

/// Representa o conjunto de informações pessoais e de contato do usuário.
/// Haverá apenas um registro deste tipo por usuário, com um ID fixo para fácil acesso.
///
/// Otimizações e Melhorias:
/// 1. Campos chave `name` e `email` são não-nulos para garantir integridade.
/// 2. Getter `age` calcula a idade dinamicamente a partir da data de nascimento.
/// 3. Método `toJson` e `fromJson` completos para integração com IA.
@collection
class PersonalData {
  PersonalData();
  /// ID fixo. Usamos `1` como padrão para simplificar a busca e atualização,
  /// já que só haverá um registro de dados pessoais.
  Id id = 1;

  /// Caminho local para o arquivo da foto do usuário.
  /// É opcional e pode ser nulo.
  String? photoPath;

  /// Nome completo do usuário. Não pode ser nulo.
  String name = '';

  /// Endereço de e-mail principal. Não pode ser nulo e é indexado para performance.
  @Index(type: IndexType.value)
  String email = '';

  /// Número de telefone de contato.
  String? phone;

  /// Endereço resumido (ex: "São Paulo, SP, Brasil").
  String? address;

  /// URL para o perfil do LinkedIn.
  String? linkedinUrl;

  /// URL para um portfólio, GitHub ou site pessoal.
  String? portfolioUrl;

  /// Resumo profissional ou objetivo de carreira.
  String? summary;

  /// Data de nascimento do usuário.
  DateTime? birthDate;

  /// Getter computado que calcula a idade atual do usuário.
  /// Retorna `null` se a data de nascimento não estiver definida.
  /// O `@Ignore` diz ao Isar para não tentar salvar este campo no banco de dados.
  @Ignore()
  int? get age {
    if (birthDate == null) return null;
    final now = DateTime.now();
    int age = now.year - birthDate!.year;
    if (now.month < birthDate!.month ||
        (now.month == birthDate!.month && now.day < birthDate!.day)) {
      age--;
    }
    return age;
  }

  // --- Opções de Disponibilidade ---

  /// Disponibilidade para viagens (Sim/Não).
  bool hasTravelAvailability = false;

  /// Disponibilidade para mudança de cidade/estado (Sim/Não).
  bool hasRelocationAvailability = false;

  // --- Opções de Veículo e Habilitação ---

  /// Possui carro próprio.
  bool hasCar = false;

  /// Possui moto própria.
  bool hasMotorcycle = false;

  /// Lista das categorias de CNH (ex: ["A", "B"]).
  List<String> licenseCategories = [];

  /// Converte a instância para um Mapa (JSON) para envio à API de IA.
  Map<String, dynamic> toJson() => {
    // ID não é necessário no JSON para a IA
    'name': name,
    'email': email,
    'phone': phone,
    'address': address,
    'linkedinUrl': linkedinUrl,
    'portfolioUrl': portfolioUrl,
    'summary': summary,
    'birthDate': birthDate?.toIso8601String(),
    'hasTravelAvailability': hasTravelAvailability,
    'hasRelocationAvailability': hasRelocationAvailability,
    'hasCar': hasCar,
    'hasMotorcycle': hasMotorcycle,
    'licenseCategories': licenseCategories,
    // photoPath não é enviado para a IA pois ela não processa imagens
  };

  /// Cria uma instância a partir de um Mapa (JSON) recebido da IA (ex: em traduções).
  factory PersonalData.fromJson(Map<String, dynamic> json) {
    return PersonalData()
      ..name = json['name'] ?? ''
      ..email = json['email'] ?? ''
      ..phone = json['phone']
      ..address = json['address']
      ..linkedinUrl = json['linkedinUrl']
      ..portfolioUrl = json['portfolioUrl']
      ..summary = json['summary']
      ..birthDate = json['birthDate'] != null ? DateTime.tryParse(json['birthDate']) : null
      ..hasTravelAvailability = json['hasTravelAvailability'] ?? false
      ..hasRelocationAvailability = json['hasRelocationAvailability'] ?? false
      ..hasCar = json['hasCar'] ?? false
      ..hasMotorcycle = json['hasMotorcycle'] ?? false
      ..licenseCategories = List<String>.from(json['licenseCategories'] ?? []);
  }
}