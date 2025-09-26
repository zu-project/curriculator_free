import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'models/personal_data.dart';
import 'models/experience.dart';
// ... importe os outros modelos

late Isar isar; // Instância global do Isar

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dir = await getApplicationDocumentsDirectory();
  isar = await Isar.open(
    [
      PersonalDataSchema,
      ExperienceSchema,
      // ... adicione os outros Schemas aqui
    ],
    directory: dir.path,
  );
  runApp(const MyApp());
}