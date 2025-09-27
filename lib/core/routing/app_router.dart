//C:\Users\ziofl\StudioProjects\curriculator_free\lib\core\routing\app_router.dart
import 'package:curriculator_free/features/dashboard/dashboard_screen.dart';
import 'package:curriculator_free/features/education/education_screen.dart';
import 'package:curriculator_free/features/experience/experience_screen.dart';
import 'package:curriculator_free/features/export/export_screen.dart';
import 'package:curriculator_free/features/info/about_screen.dart';
import 'package:curriculator_free/features/info/legal_screen.dart';
import 'package:curriculator_free/features/info/support_screen.dart';
import 'package:curriculator_free/features/languages/languages_screen.dart';
import 'package:curriculator_free/features/personal_data/personal_data_screen.dart';
import 'package:curriculator_free/features/settings/settings_screen.dart';
import 'package:curriculator_free/features/shell/shell_screen.dart';
import 'package:curriculator_free/features/skills/skills_screen.dart';
import 'package:curriculator_free/features/versions/version_editor_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:curriculator_free/features/analyzer/analyzer_screen.dart';
import 'package:curriculator_free/features/analyzer/analysis_detail_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    routes: [
      // A "casca" principal que contém o menu lateral.
      ShellRoute(
        builder: (context, state, child) => ShellScreen(child: child),
        routes: [
          // Telas principais
          GoRoute(path: '/', builder: (context, state) => const DashboardScreen()),
          GoRoute(path: '/analyzer', builder: (context, state) => const AnalyzerScreen()),
          GoRoute(
            path: '/analyzer/:reportId',
            builder: (context, state) {
              final reportId = int.tryParse(state.pathParameters['reportId'] ?? '');
              return AnalysisDetailScreen(reportId: reportId);
            },
          ),
          GoRoute(path: '/personal', builder: (context, state) => const PersonalDataScreen()),
          GoRoute(path: '/experience', builder: (context, state) => const ExperienceScreen()),
          GoRoute(path: '/education', builder: (context, state) => const EducationScreen()),
          GoRoute(path: '/skills', builder: (context, state) => const SkillsScreen()),
          GoRoute(path: '/languages', builder: (context, state) => const LanguagesScreen()),

          // Telas de informação e configurações
          GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
          GoRoute(path: '/about', builder: (context, state) => const AboutScreen()),
          GoRoute(path: '/support', builder: (context, state) => const SupportScreen()),
          GoRoute(path: '/legal', builder: (context, state) => const LegalScreen()),

          // --- CORREÇÃO APLICADA AQUI ---
          // Movemos as rotas de edição de versão PARA DENTRO da ShellRoute.
          // Agora elas se comportarão como as outras telas de edição.
          GoRoute(
            path: '/version-editor',
            builder: (context, state) => const VersionEditorScreen(),
          ),
          GoRoute(
            path: '/version-editor/:versionId',
            builder: (context, state) {
              final versionId = int.tryParse(state.pathParameters['versionId'] ?? '');
              return VersionEditorScreen(versionId: versionId);
            },
          ),
        ],
      ),

      // A tela de Exportação é a única que MANTEMOS FORA, pois ela
      // realmente precisa ocupar a tela inteira para a pré-visualização.
      GoRoute(
        path: '/export/:versionId',
        builder: (context, state) {
          final versionId = int.tryParse(state.pathParameters['versionId'] ?? '');
          if (versionId == null) {
            // Se o ID for inválido, redireciona para a home para evitar crashes.
            return const DashboardScreen();
          }
          return ExportScreen(versionId: versionId);
        },
      ),
    ],
  );
});