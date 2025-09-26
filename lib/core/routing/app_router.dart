import 'package:curriculator_free/features/dashboard/dashboard_screen.dart';
import 'package:curriculator_free/features/education/education_screen.dart';
import 'package:curriculator_free/features/experience/experience_screen.dart';
import 'package:curriculator_free/features/languages/languages_screen.dart';
import 'package:curriculator_free/features/personal_data/personal_data_screen.dart';
import 'package:curriculator_free/features/shell/shell_screen.dart';
import 'package:curriculator_free/features/skills/skills_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
// --- SOLUÇÃO APLICADA AQUI ---
import 'package:curriculator_free/features/export/export_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) => ShellScreen(child: child),
        routes: [
          GoRoute(path: '/', builder: (context, state) => const DashboardScreen()),
          GoRoute(path: '/personal', builder: (context, state) => const PersonalDataScreen()),
          GoRoute(path: '/experience', builder: (context, state) => const ExperienceScreen()),
          GoRoute(path: '/education', builder: (context, state) => const EducationScreen()),
          GoRoute(path: '/skills', builder: (context, state) => const SkillsScreen()),
          GoRoute(path: '/languages', builder: (context, state) => const LanguagesScreen()),
        ],
      ),
      // Rota para a tela de exportação, fora da "casca" principal.
      GoRoute(
        path: '/export/:versionId',
        builder: (context, state) {
          try {
            final versionId = int.parse(state.pathParameters['versionId']!);
            return ExportScreen(versionId: versionId);
          } catch (e) {
            // Se o ID for inválido, redireciona para a home
            return const DashboardScreen();
          }
        },
      ),
    ],
  );
});