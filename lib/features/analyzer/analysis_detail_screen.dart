// C:\Users\ziofl\StudioProjects\curriculator_free\lib\features\analyzer\analysis_detail_screen.dart
import 'dart:convert';
import 'package:curriculator_free/core/services/isar_service.dart';
import 'package:curriculator_free/features/analyzer/analyzer_repository.dart';
import 'package:curriculator_free/models/analysis_report.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- Providers de Estado para a Tela de Detalhes ---

// FutureProvider para buscar um relatório específico do banco.
final analysisReportProvider = FutureProvider.autoDispose.family<AnalysisReport?, int?>((ref, reportId) async {
  if (reportId == null) return null;
  final isar = await ref.watch(isarDbProvider.future);
  return isar.analysisReports.get(reportId);
});

// Provider para controlar a visibilidade das sugestões já tratadas.
final showHandledSuggestionsProvider = StateProvider.autoDispose<bool>((ref) => false);

// StateNotifierProvider para gerenciar o estado interativo das sugestões de um relatório.
final analysisResultProvider = StateNotifierProvider.autoDispose.family<AnalysisResultNotifier, Map<String, dynamic>?, int?>(
      (ref, reportId) => AnalysisResultNotifier(ref, reportId),
);

// O Notifier com a lógica de MUDANÇA DE STATUS (não de remoção).
class AnalysisResultNotifier extends StateNotifier<Map<String, dynamic>?> {
  final Ref _ref;
  final int? _reportId;

  AnalysisResultNotifier(this._ref, this._reportId) : super(null);

  void setInitialData(String jsonString) {
    state = Map<String, dynamic>.from(jsonDecode(jsonString));
  }

  Future<void> _updateReportInDb() async {
    if (state == null || _reportId == null) return;
    final report = await _ref.read(analysisReportProvider(_reportId).future);
    if(report != null) {
      report.suggestionsJson = jsonEncode(state);
      await _ref.read(analyzerRepositoryProvider).updateReport(report);
    }
  }

  void _updateItemStatus(List<dynamic> itemList, dynamic itemIdentifier, String newStatus, {String identifierKey = 'id'}) {
    final itemIndex = itemList.indexWhere((item) => item[identifierKey] == itemIdentifier);
    if(itemIndex != -1) {
      itemList[itemIndex]['status'] = newStatus;
    }
  }

  void updateSummaryStatus(String newStatus) {
    if (state == null || state!['summary_suggestion'] == null) return;
    final newState = Map<String, dynamic>.from(state!);
    (newState['summary_suggestion'] as Map<String, dynamic>)['status'] = newStatus;
    state = newState;
    _updateReportInDb();
  }

  void updateExperienceStatus(int id, String newStatus) {
    if (state == null) return;
    final newState = Map<String, dynamic>.from(state!);
    final currentExp = (newState['experience_suggestions'] as List?) ?? [];
    _updateItemStatus(currentExp, id, newStatus);
    state = newState;
    _updateReportInDb();
  }

  void updateSkillStatus(String name, String newStatus) {
    if (state == null) return;
    final newState = Map<String, dynamic>.from(state!);
    final currentSkills = (newState['skill_suggestions'] as List?) ?? [];
    _updateItemStatus(currentSkills, name, newStatus, identifierKey: 'name');
    state = newState;
    _updateReportInDb();
  }

  void updateAllPendingSkillsStatus(String newStatus) {
    if (state == null) return;
    final newState = Map<String, dynamic>.from(state!);
    final currentSkills = (newState['skill_suggestions'] as List?) ?? [];
    for (var skill in currentSkills) {
      if (skill['status'] == 'pending') {
        skill['status'] = newStatus;
      }
    }
    state = newState;
    _updateReportInDb();
  }
}

// --- Tela Principal (UI) ---
class AnalysisDetailScreen extends ConsumerWidget {
  final int? reportId;
  const AnalysisDetailScreen({super.key, this.reportId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncReport = ref.watch(analysisReportProvider(reportId));
    final suggestions = ref.watch(analysisResultProvider(reportId));
    final showHandled = ref.watch(showHandledSuggestionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(asyncReport.valueOrNull != null ? 'Detalhes da Análise' : 'Carregando...'),
        actions: [
          if (suggestions != null) // Só mostra o botão se houver sugestões
            TextButton.icon(
              icon: Icon(showHandled ? Icons.visibility_off_outlined : Icons.visibility_outlined),
              label: Text(showHandled ? 'Ocultar Tratadas' : 'Exibir Tratadas'),
              onPressed: () {
                ref.read(showHandledSuggestionsProvider.notifier).state = !showHandled;
              },
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: asyncReport.when(
            data: (report) {
              if (report == null) return const Center(child: Text("Relatório não encontrado."));

              if (suggestions == null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ref.read(analysisResultProvider(reportId).notifier).setInitialData(report.suggestionsJson);
                });
                return const Center(child: CircularProgressIndicator());
              }

              bool hasPendingSuggestions = (suggestions['summary_suggestion'] != null && suggestions['summary_suggestion']['status'] == 'pending') ||
                  (suggestions['experience_suggestions'] as List? ?? []).any((s) => s['status'] == 'pending') ||
                  (suggestions['skill_suggestions'] as List? ?? []).any((s) => s['status'] == 'pending');

              if (!hasPendingSuggestions && !showHandled) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
                        const SizedBox(height: 16),
                        Text("Nenhuma sugestão pendente!", style: Theme.of(context).textTheme.headlineSmall),
                        const SizedBox(height: 8),
                        const Text("Você já tratou todas as sugestões deste relatório.", textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                );
              }

              return _buildSuggestionsList(context, ref, suggestions);
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text("Erro ao carregar relatório: $err", style: TextStyle(color: Theme.of(context).colorScheme.error))),
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionsList(BuildContext context, WidgetRef ref, Map<String, dynamic> suggestions) {
    final showHandled = ref.watch(showHandledSuggestionsProvider);

    final summarySuggestion = suggestions['summary_suggestion'] as Map<String, dynamic>?;
    final expSuggestions = (suggestions['experience_suggestions'] as List?)?.map((e) => e as Map<String, dynamic>).toList() ?? [];
    final skillSuggestions = (suggestions['skill_suggestions'] as List?)?.map((e) => e as Map<String, dynamic>).toList() ?? [];

    final visibleExp = expSuggestions.where((s) => s['status'] == 'pending' || showHandled).toList();
    final visibleSkills = skillSuggestions.where((s) => s['status'] == 'pending' || showHandled).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
      children: [
        if (summarySuggestion != null && (summarySuggestion['status'] == 'pending' || showHandled))
          _SuggestionCard(
            title: "Sugestão para o Resumo",
            status: summarySuggestion['status'],
            child: _buildSuggestionItem(
              context: context,
              suggestionText: summarySuggestion['text'],
              status: summarySuggestion['status'],
              onApply: () async {
                await ref.read(analyzerRepositoryProvider).applySummarySuggestion(summarySuggestion['text']);
                ref.read(analysisResultProvider(reportId).notifier).updateSummaryStatus('applied');
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Resumo atualizado!'), backgroundColor: Colors.green));
              },
              onDiscard: () => ref.read(analysisResultProvider(reportId).notifier).updateSummaryStatus('discarded'),
              onRevert: () => ref.read(analysisResultProvider(reportId).notifier).updateSummaryStatus('pending'),
            ),
          ),
        if (visibleExp.isNotEmpty)
          _SuggestionCard(
            title: "Sugestões para Experiências (${visibleExp.length})",
            children: visibleExp.map<Widget>((expSugg) {
              return _buildSuggestionItem(
                context: context,
                suggestionText: expSugg['description_suggestion'],
                status: expSugg['status'],
                prefix: Text("Melhoria para experiência (ID: ${expSugg['id']})", style: const TextStyle(fontWeight: FontWeight.bold)),
                onApply: () async {
                  await ref.read(analyzerRepositoryProvider).applyExperienceSuggestion(expSugg['id'], expSugg['description_suggestion']);
                  ref.read(analysisResultProvider(reportId).notifier).updateExperienceStatus(expSugg['id'], 'applied');
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Experiência atualizada!'), backgroundColor: Colors.green));
                },
                onDiscard: () => ref.read(analysisResultProvider(reportId).notifier).updateExperienceStatus(expSugg['id'], 'discarded'),
                onRevert: () => ref.read(analysisResultProvider(reportId).notifier).updateExperienceStatus(expSugg['id'], 'pending'),
              );
            }).toList(),
          ),
        if (visibleSkills.isNotEmpty)
          _SuggestionCard(
            title: "Sugestões de Habilidades (${visibleSkills.length})",
            child: Column(
              children: [
                Wrap(
                  spacing: 8, runSpacing: 4,
                  children: visibleSkills.map<Widget>((skillSugg) {
                    final isHard = skillSugg['type'] == 'hardSkill';
                    return InputChip(
                      label: Text(skillSugg['name']),
                      backgroundColor: _getStatusColor(skillSugg['status'], isHard ? Colors.blue.shade100 : Colors.green.shade100),
                      onDeleted: skillSugg['status'] == 'pending' ? () {
                        ref.read(analysisResultProvider(reportId).notifier).updateSkillStatus(skillSugg['name'], 'discarded');
                      } : null,
                      onPressed: skillSugg['status'] != 'pending' ? () {
                        ref.read(analysisResultProvider(reportId).notifier).updateSkillStatus(skillSugg['name'], 'pending');
                      } : null,
                      deleteIcon: skillSugg['status'] == 'pending' ? const Icon(Icons.close, size: 18) : null,
                      avatar: skillSugg['status'] != 'pending' ? const Icon(Icons.undo, size: 18) : null,
                    );
                  }).toList(),
                ),
                if (skillSuggestions.any((s) => s['status'] == 'pending')) ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(onPressed: () => ref.read(analysisResultProvider(reportId).notifier).updateAllPendingSkillsStatus('discarded'), child: const Text("Descartar Pendentes")),
                      const SizedBox(width: 8),
                      ElevatedButton(
                          onPressed: () async {
                            final pendingSkills = skillSuggestions.where((s) => s['status'] == 'pending').toList();
                            await ref.read(analyzerRepositoryProvider).addSuggestedSkills(pendingSkills);
                            ref.read(analysisResultProvider(reportId).notifier).updateAllPendingSkillsStatus('applied');
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Habilidades pendentes adicionadas!'), backgroundColor: Colors.green));
                          },
                          child: const Text("Adicionar Pendentes")
                      ),
                    ],
                  )
                ]
              ],
            ),
          )
      ],
    );
  }
}

// --- WIDGETS AUXILIARES ATUALIZADOS ---

Color _getStatusColor(String status, Color defaultColor) {
  switch (status) {
    case 'applied': return Colors.green.shade200;
    case 'discarded': return Colors.red.shade200;
    default: return defaultColor;
  }
}

class _SuggestionCard extends StatelessWidget {
  final String title;
  final Widget? child;
  final List<Widget>? children;
  final String? status;

  const _SuggestionCard({required this.title, this.child, this.children, this.status});

  @override
  Widget build(BuildContext context) {
    final bool isPending = status == null || status == 'pending';
    return Opacity(
      opacity: isPending ? 1.0 : 0.6,
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const Divider(height: 24),
              if (child != null) child!,
              if (children != null) ...children!,
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildSuggestionItem({
  required BuildContext context,
  required String suggestionText,
  required String status,
  Widget? prefix,
  required VoidCallback onApply,
  required VoidCallback onDiscard,
  required VoidCallback onRevert,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (prefix != null) ...[prefix, const SizedBox(height: 8)],
        Text('"${suggestionText}"', style: const TextStyle(fontStyle: FontStyle.italic)),
        const SizedBox(height: 12),
        Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: status == 'pending'
                ? [
              TextButton(onPressed: onDiscard, child: const Text("Descartar")),
              const SizedBox(width: 8),
              ElevatedButton(onPressed: onApply, child: const Text("Aplicar")),
            ]
                : [
              Text(status == 'applied' ? 'Aplicado' : 'Descartado', style: TextStyle(fontWeight: FontWeight.bold, color: status == 'applied' ? Colors.green.shade800 : Colors.red.shade800)),
              const Spacer(),
              TextButton.icon(icon: const Icon(Icons.undo), label: const Text("Reverter"), onPressed: onRevert),
            ]
        ),
      ],
    ),
  );
}