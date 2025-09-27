// C:\Users\ziofl\StudioProjects\curriculator_free\lib\features\analyzer\analyzer_screen.dart
import 'package:curriculator_free/features/analyzer/analyzer_repository.dart';
import 'package:curriculator_free/models/analysis_report.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

// Provider para controlar o estado de carregamento da criação de um novo relatório
final isCreatingReportProvider = StateProvider<bool>((ref) => false);

class AnalyzerScreen extends ConsumerWidget {
  const AnalyzerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(analysisHistoryProvider);
    final isCreating = ref.watch(isCreatingReportProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        icon: isCreating ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.science_outlined),
        label: const Text('Executar Nova Análise'),
        onPressed: isCreating ? null : () async {
          ref.read(isCreatingReportProvider.notifier).state = true;
          try {
            // Roda e salva a análise, depois navega para a tela de detalhes do novo relatório
            final newReport = await ref.read(analyzerRepositoryProvider).runAndSaveNewAnalysis();
            if (context.mounted) {
              context.go('/analyzer/${newReport.id}');
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: ${e.toString()}'), backgroundColor: Colors.red));
            }
          } finally {
            ref.read(isCreatingReportProvider.notifier).state = false;
          }
        },
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: historyAsync.when(
            data: (reports) {
              if (reports.isEmpty) {
                return const Center(child: Text("Nenhum relatório de análise encontrado."));
              }
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 80),
                itemCount: reports.length,
                itemBuilder: (context, index) {
                  return _ReportCard(report: reports[index]);
                },
              );
            },
            loading: () => const CircularProgressIndicator(),
            error: (err, stack) => Text("Erro ao carregar histórico: $err"),
          ),
        ),
      ),
    );
  }
}

class _ReportCard extends ConsumerWidget {
  final AnalysisReport report;
  const _ReportCard({required this.report});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(report.createdAt);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.history_edu_outlined),
        title: Text('Análise de ${report.createdAt.day.toString().padLeft(2, '0')}/${report.createdAt.month.toString().padLeft(2, '0')}'),
        subtitle: Text('Criado em: $formattedDate'),
        trailing: IconButton(
          icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
          onPressed: () => ref.read(analyzerRepositoryProvider).deleteReport(report.id),
        ),
        onTap: () {
          context.go('/analyzer/${report.id}');
        },
      ),
    );
  }
}