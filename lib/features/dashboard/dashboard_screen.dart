import 'package:curriculator_free/core/services/isar_service.dart';
import 'package:curriculator_free/models/curriculum_version.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';


// --- Providers ---
// Provider para o repositório que lida com as versões do currículo
final versionRepositoryProvider = Provider((ref) {
  final isarService = ref.watch(isarServiceProvider);
  return VersionRepository(isarService);
});

// StreamProvider para observar a lista de versões em tempo real
final versionsStreamProvider = StreamProvider.autoDispose((ref) {
  final repository = ref.watch(versionRepositoryProvider);
  return repository.watchVersions();
});

// --- Repository ---
class VersionRepository {
  final IsarService _isarService;
  VersionRepository(this._isarService);

  Stream<List<CurriculumVersion>> watchVersions() async* {
    final isar = await _isarService.db;
    yield* isar.curriculumVersions.where().sortByCreatedAtDesc().watch(fireImmediately: true);
  }

  Future<void> deleteVersion(int versionId) async {
    final isar = await _isarService.db;
    await isar.writeTxn(() async {
      await isar.curriculumVersions.delete(versionId);
    });
  }
}


// --- UI Screen ---
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final versionsAsync = ref.watch(versionsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Currículos'),
      ),
      body: versionsAsync.when(
        data: (versions) {
          if (versions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Você ainda não criou nenhuma versão de currículo.',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Criar Meu Primeiro Currículo'),
                    onPressed: () {
                      // Navega para a tela de criação sem passar um ID
                      context.go('/version-editor');
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: versions.length,
            itemBuilder: (context, index) {
              final version = versions[index];
              return _VersionCard(version: version);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Erro: $error')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Criar Nova Versão'),
        onPressed: () {
          // Navega para a tela de criação
          context.go('/version-editor');
        },
      ),
    );
  }
}

// Card para exibir cada versão na lista
class _VersionCard extends ConsumerWidget {
  const _VersionCard({required this.version});
  final CurriculumVersion version;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(version.createdAt);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              version.name,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              'Criado em: $formattedDate',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.auto_awesome),
                  tooltip: 'Otimizar para Vaga (IA)',
                  onPressed: () {
                    // TODO: Implementar a chamada do diálogo de otimização
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Funcionalidade em breve!')));
                  },
                ),
                // Botão de Tradução
                IconButton(
                  icon: const Icon(Icons.translate),
                  tooltip: 'Traduzir (IA)',
                  onPressed: () {
                    // TODO: Implementar a chamada do diálogo de tradução
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Funcionalidade em breve!')));
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: Theme.of(context).colorScheme.error,
                  tooltip: 'Excluir',
                  onPressed: () {
                    // Lógica de exclusão
                    showDialog(context: context, builder: (ctx) => AlertDialog(
                      title: const Text("Confirmar Exclusão"),
                      content: Text("Deseja realmente excluir a versão '${version.name}'? Esta ação não pode ser desfeita."),
                      actions: [
                        TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text("Cancelar")),
                        FilledButton(onPressed: (){
                          ref.read(versionRepositoryProvider).deleteVersion(version.id);
                          Navigator.of(ctx).pop();
                        }, child: const Text("Excluir")),
                      ],
                    ));
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Editar Conteúdo',
                  onPressed: () {
                    // Navega para a tela de edição passando o ID da versão
                    context.go('/version-editor/${version.id}');
                  },
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  icon: const Icon(Icons.print_outlined),
                  label: const Text('Exportar'),
                  onPressed: () {
                    // AÇÃO PRINCIPAL: Navega para a tela de exportação!
                    context.go('/export/${version.id}');
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}