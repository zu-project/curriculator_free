import 'package:curriculator_free/features/analyzer/analyzer_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- Providers de Estado para a Tela ---

// FutureProvider que busca as sugestões iniciais da IA.
final initialAnalysisProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) {
  return ref.watch(analyzerRepositoryProvider).getAnalysis();
});

// StateProvider para armazenar e permitir a modificação do resultado da análise na UI.
final analysisResultProvider = StateProvider.autoDispose<Map<String, dynamic>?>((ref) => null);


// --- Tela Principal (UI) ---

class AnalyzerScreen extends ConsumerWidget {
  const AnalyzerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Observa o FutureProvider para lidar com o estado inicial de carregamento/erro.
    final asyncAnalysis = ref.watch(initialAnalysisProvider);
    // Observa o StateProvider para construir a UI com os dados que podem ser modificados.
    final suggestions = ref.watch(analysisResultProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Análise de Conteúdo (IA)'),
      ),
      body: asyncAnalysis.when(
        data: (initialData) {
          // Quando os dados chegam pela primeira vez, os coloca no StateProvider.
          // Isso só acontece uma vez.
          if (suggestions == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref.read(analysisResultProvider.notifier).state = initialData;
            });
          }

          // Se não houver sugestões, mostra uma mensagem.
          if (suggestions == null || (suggestions['summary_suggestion'] as String).isEmpty && (suggestions['experience_suggestions'] as List).isEmpty && (suggestions['skill_suggestions'] as List).isEmpty) {
            return const Center(child: Text("Nenhuma sugestão disponível no momento."));
          }

          // Constrói a UI com base nos dados do StateProvider.
          return _buildSuggestionsList(context, ref, suggestions);
        },
        loading: () => const Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Analisando seu currículo...")
          ]),
        ),
        error: (err, stack) => Center(child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text("Erro na análise: ${err.toString()}", textAlign: TextAlign.center),
        )),
      ),
    );
  }

  Widget _buildSuggestionsList(BuildContext context, WidgetRef ref, Map<String, dynamic> suggestions) {
    final summarySuggestion = suggestions['summary_suggestion'] as String?;
    final expSuggestions = suggestions['experience_suggestions'] as List;
    final skillSuggestions = suggestions['skill_suggestions'] as List;

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Sugestão do Resumo
        if (summarySuggestion?.isNotEmpty ?? false)
          _SuggestionCard(
            title: "Sugestão para o Resumo",
            child: Column(
              children: [
                Text(summarySuggestion!, style: const TextStyle(fontStyle: FontStyle.italic)),
                const SizedBox(height: 12),
                ElevatedButton(
                    onPressed: () async {
                      await ref.read(analyzerRepositoryProvider).applySummarySuggestion(summarySuggestion);
                      // Remove a sugestão da UI
                      ref.read(analysisResultProvider.notifier).update((state) => state?..remove('summary_suggestion'));
                    },
                    child: const Text("Aplicar esta sugestão")
                )
              ],
            ),
          ),

        // Sugestões para Experiências
        if (expSuggestions.isNotEmpty)
          _SuggestionCard(
            title: "Sugestões para Experiências (${expSuggestions.length})",
            children: expSuggestions.map<Widget>((expSugg) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Melhoria para experiência (ID: ${expSugg['id']})", style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(expSugg['description_suggestion'], style: const TextStyle(fontStyle: FontStyle.italic)),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                          onPressed: () async {
                            await ref.read(analyzerRepositoryProvider).applyExperienceSuggestion(expSugg['id'], expSugg['description_suggestion']);
                            // Remove a sugestão da UI
                            ref.read(analysisResultProvider.notifier).update((state) {
                              final currentExp = state?['experience_suggestions'] as List;
                              currentExp.removeWhere((item) => item['id'] == expSugg['id']);
                              return state;
                            });
                          },
                          child: const Text("Aplicar")
                      ),
                    ),
                    if(expSugg != expSuggestions.last) const Divider(height: 24),
                  ],
                ),
              );
            }).toList(),
          ),

        // Sugestões de Habilidades
        if (skillSuggestions.isNotEmpty)
          _SuggestionCard(
            title: "Sugestões de Habilidades (${skillSuggestions.length})",
            child: Column(
              children: [
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: skillSuggestions.map<Widget>((skillSugg) {
                    final isHard = skillSugg['type'] == 'hardSkill';
                    return Chip(
                      label: Text(skillSugg['name']),
                      backgroundColor: isHard ? Colors.blue.shade100 : Colors.green.shade100,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                      onPressed: () async {
                        await ref.read(analyzerRepositoryProvider).addSuggestedSkills(skillSuggestions);
                        // Remove a sugestão da UI
                        ref.read(analysisResultProvider.notifier).update((state) => state?..remove('skill_suggestions'));
                      },
                      child: const Text("Adicionar Todas as Habilidades")
                  ),
                )
              ],
            ),
          )
      ],
    );
  }
}

// Widget auxiliar para criar os cards de sugestão
class _SuggestionCard extends StatelessWidget {
  final String title;
  final Widget? child;
  final List<Widget>? children;

  const _SuggestionCard({required this.title, this.child, this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
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
    );
  }
}