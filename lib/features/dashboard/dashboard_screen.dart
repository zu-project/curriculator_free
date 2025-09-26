import 'package:curriculator_free/core/services/isar_service.dart';
import 'package:curriculator_free/models/education.dart';
import 'package:curriculator_free/models/experience.dart';
import 'package:curriculator_free/models/language.dart';
import 'package:curriculator_free/models/personal_data.dart';
import 'package:curriculator_free/models/skill.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:isar/isar.dart';

// --- Data Model para o Resumo ---

// Uma classe simples para agrupar todos os dados de resumo que a Dashboard precisa.
// Isso evita ter que buscar cada dado individualmente na UI.
class DashboardSummary {
  final String? userName;
  final int experienceCount;
  final int educationCount;
  final int skillCount;
  final int languageCount;

  // Construtor que exige todos os campos
  DashboardSummary({
    required this.userName,
    required this.experienceCount,
    required this.educationCount,
    required this.skillCount,
    required this.languageCount,
  });
}


// --- Providers (Gerenciamento de Estado) ---

// Repositório que busca os dados para a dashboard
final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final isarService = ref.watch(isarServiceProvider);
  return DashboardRepository(isarService);
});

// FutureProvider que busca o objeto de resumo de forma assíncrona.
// O ".autoDispose" garante que os dados serão buscados novamente se o usuário
// sair e voltar para a tela, mantendo o resumo sempre atualizado.
final dashboardSummaryProvider = FutureProvider.autoDispose<DashboardSummary>((ref) {
  final dashboardRepository = ref.watch(dashboardRepositoryProvider);
  return dashboardRepository.getSummary();
});

// --- Repositório (Lógica de Dados) ---

class DashboardRepository {
  final IsarService _isarService;

  DashboardRepository(this._isarService);

  // Método único que busca todas as contagens e o nome do usuário.
  Future<DashboardSummary> getSummary() async {
    final isar = await _isarService.db;

    // Usamos um Future.wait para rodar todas as consultas de contagem
    // em paralelo, o que é mais performático.
    final results = await Future.wait([
      isar.personalDatas.get(1), // Busca os dados pessoais (usando o ID fixo 1)
      isar.experiences.count(),
      isar.educations.count(),
      isar.skills.count(),
      isar.languages.count(),
    ]);

    // Monta e retorna o objeto de resumo.
    return DashboardSummary(
      userName: (results[0] as PersonalData?)?.name,
      experienceCount: results[1] as int,
      educationCount: results[2] as int,
      skillCount: results[3] as int,
      languageCount: results[4] as int,
    );
  }
}

// --- Tela Principal (UI) ---

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Assiste ao FutureProvider para obter o estado do resumo.
    final summaryAsyncValue = ref.watch(dashboardSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: summaryAsyncValue.when(
        data: (summary) => _DashboardContentView(summary: summary),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Ocorreu um erro ao carregar o resumo:\n$error', textAlign: TextAlign.center),
          ),
        ),
      ),
    );
  }
}

// --- Widgets de Conteúdo (UI) ---

// Widget que exibe o conteúdo principal da dashboard, uma vez que os dados foram carregados.
class _DashboardContentView extends StatelessWidget {
  const _DashboardContentView({required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Seção de Boas-Vindas
                Text(
                  'Bem-vindo(a), ${summary.userName ?? 'Usuário'}!',
                  style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Aqui está um resumo do progresso do seu currículo. Clique em um card para editar a seção correspondente.',
                  style: textTheme.bodyLarge?.copyWith(color: Colors.black54),
                ),
                const SizedBox(height: 32),

                // Grid de Cards com Resumo
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _StatCard(
                      icon: Icons.person_outline,
                      title: 'Dados Pessoais',
                      value: (summary.userName?.isNotEmpty ?? false) ? 'Preenchido' : 'Pendente',
                      color: Colors.blue.shade100,
                      onTap: () => context.go('/personal'),
                    ),
                    _StatCard(
                      icon: Icons.work_outline,
                      title: 'Experiências',
                      value: '${summary.experienceCount} registradas',
                      color: Colors.green.shade100,
                      onTap: () => context.go('/experience'),
                    ),
                    _StatCard(
                      icon: Icons.school_outlined,
                      title: 'Formação',
                      value: '${summary.educationCount} registradas',
                      color: Colors.orange.shade100,
                      onTap: () => context.go('/education'),
                    ),
                    _StatCard(
                      icon: Icons.lightbulb_outline,
                      title: 'Habilidades',
                      value: '${summary.skillCount} registradas',
                      color: Colors.purple.shade100,
                      onTap: () => context.go('/skills'),
                    ),
                    _StatCard(
                      icon: Icons.language_outlined,
                      title: 'Idiomas',
                      value: '${summary.languageCount} registrados',
                      color: Colors.red.shade100,
                      onTap: () => context.go('/languages'),
                    ),
                  ],
                ),
                const SizedBox(height: 48),

                // Botão de Ação Principal (Call to Action)
                Center(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.picture_as_pdf_outlined),
                    label: const Text('Exportar Currículo'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      textStyle: textTheme.titleMedium,
                    ),
                    onPressed: () {
                      // TODO: Implementar a navegação para a tela de exportação
                      // context.go('/export');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Funcionalidade de exportação será implementada em breve!')),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Widget customizado para cada card de estatística
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 250, // Largura fixa para melhor alinhamento no Wrap
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}