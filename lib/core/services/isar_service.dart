//C:\Users\ziofl\StudioProjects\curriculator_free\lib\core\services\isar_service.dart
import 'package:curriculator_free/models/curriculum_version.dart';
import 'package:curriculator_free/models/education.dart';
import 'package:curriculator_free/models/experience.dart';
import 'package:curriculator_free/models/language.dart';
import 'package:curriculator_free/models/personal_data.dart';
import 'package:curriculator_free/models/skill.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:curriculator_free/models/analysis_report.dart';

/// Um serviço singleton responsável por gerenciar a instância do banco de dados Isar.
///
/// Esta classe garante que o banco de dados seja aberto apenas uma vez durante
/// o ciclo de vida do aplicativo, fornecendo uma instância `Future<Isar>` que pode
/// ser usada de forma segura em todo o projeto.
class IsarService {
  /// Armazena a `Future` da instância do Isar. Isso implementa o padrão singleton,
  /// garantindo que `_openDB()` não seja chamado múltiplas vezes.
  late final Future<Isar> _dbFuture;

  IsarService() {
    _dbFuture = _openDB();
  }

  /// Getter para acessar a instância do Isar de forma assíncrona e segura.
  Future<Isar> get db => _dbFuture;

  /// Método privado que realiza a abertura do banco de dados.
  /// É chamado apenas uma vez pelo construtor.
  Future<Isar> _openDB() async {
    // Obtém o diretório de documentos do aplicativo, um local seguro
    // para armazenar dados persistentes.
    final directory = await getApplicationDocumentsDirectory();

    // Verifica se uma instância do Isar com o nome padrão já está aberta.
    // Isso previne erros de "instância já aberta" durante hot reloads.
    if (Isar.instanceNames.isEmpty) {
      // Abre a instância do Isar, registrando todos os schemas (modelos) do aplicativo.
      // É crucial que todos os modelos marcados com `@collection` estejam nesta lista.
      return await Isar.open(
        [
          PersonalDataSchema,
          ExperienceSchema,
          EducationSchema,
          SkillSchema,
          LanguageSchema,
          CurriculumVersionSchema,
          AnalysisReportSchema,
        ],
        directory: directory.path,
        // Habilita o Isar Inspector (http://localhost:8080)
        // APENAS quando o aplicativo estiver rodando em modo de depuração.
        inspector: kDebugMode,
      );
    }

    // Se uma instância já estiver aberta, retorna a instância existente.
    return Future.value(Isar.getInstance());
  }
}

// --- Providers (Riverpod) ---

/// Provider que cria e mantém a única instância do `IsarService` em todo o aplicativo.
final isarServiceProvider = Provider<IsarService>((ref) {
  return IsarService();
});

/// FutureProvider que expõe diretamente a instância `Future<Isar>` para o resto do aplicativo.
/// Os repositórios podem depender deste provider para obter a instância do Isar pronta para uso.
final isarDbProvider = FutureProvider<Isar>((ref) {
  return ref.watch(isarServiceProvider).db;
});