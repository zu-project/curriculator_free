import 'package:curriculator_free/models/education.dart';
import 'package:curriculator_free/models/experience.dart';
import 'package:curriculator_free/models/language.dart';
import 'package:curriculator_free/models/personal_data.dart';
import 'package:curriculator_free/models/skill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:curriculator_free/models/curriculum_version.dart';

class IsarService {
  late Future<Isar> db;

  IsarService() {
    db = _openDB();
  }

  Future<Isar> _openDB() async {
    final dir = await getApplicationDocumentsDirectory();
    if (Isar.instanceNames.isEmpty) {
      return await Isar.open(
        [
          PersonalDataSchema,
          ExperienceSchema,
          EducationSchema,
          SkillSchema,
          LanguageSchema,
          CurriculumVersionSchema,
        ],
        inspector: true, // Habilita o inspetor para debug
        directory: dir.path,
      );
    }
    return Future.value(Isar.getInstance());
  }
}

// Provider global para acessar o serviço do Isar em qualquer lugar do app
final isarServiceProvider = Provider<IsarService>((ref) {
  return IsarService();
});