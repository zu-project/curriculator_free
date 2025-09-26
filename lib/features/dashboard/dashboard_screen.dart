import 'package:curriculator_free/core/services/isar_service.dart';
import 'package:curriculator_free/features/dashboard/optimization_repository.dart';
import 'package:curriculator_free/features/dashboard/translation_repository.dart';
import 'package:curriculator_free/models/curriculum_version.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';


// --- Camada de Dados e Lógica (para a Dashboard) ---

/// Provider para o repositório que lida com as operações básicas das versões de currículo (CRUD).
final versionRepositoryProvider = Provider<VersionRepository>((ref) {
  final isarService = ref.watch(isarServiceProvider);
  return VersionRepository(isarService);
});

/// StreamProvider que observa a lista de versões em tempo real para manter a UI sempre atualizada.
final versionsStreamProvider = StreamProvider.autoDispose<List<CurriculumVersion>>((ref) {
  final repository = ref.watch(versionRepositoryProvider);
  return repository.watchVersions();
});

/// Repositório para as operações básicas da Dashboard: buscar e deletar versões.
class VersionRepository {
  final IsarService _isarService;
  VersionRepository(this._isarService);

  /// Assiste a mudanças na coleção de CurriculumVersion, ordenando da mais recente para a mais antiga.
  Stream<List<CurriculumVersion>> watchVersions() async* {
    final isar = await _isarService.db;
    yield* isar.curriculumVersions.where().sortByCreatedAtDesc().watch(fireImmediately: true);
  }

  /// Deleta uma versão específica do currículo pelo seu ID.
  Future<void> deleteVersion(int versionId) async {
    final isar = await _isarService.db;
    await isar.writeTxn(() async {
      await isar.curriculumVersions.delete(versionId);
    });
  }
}

// --- Tela Principal (UI) ---

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
class _VersionCard extends ConsumerStatefulWidget {
  final CurriculumVersion version;
  const _VersionCard({required this.version});

  @override
  ConsumerState<_VersionCard> createState() => _VersionCardState();
}

class _VersionCardState extends ConsumerState<_VersionCard> {
  // Estado único para controlar o feedback de carregamento de qualquer operação de IA.
  bool _isProcessingAI = false;
  String _processingMessage = '';

  /// Exibe um diálogo para o usuário selecionar o idioma de destino e inicia a tradução.
  Future<void> _onTranslate() async {
    String selectedLanguage = 'English'; // Valor padrão
    final supportedLanguages = ['English', 'Spanish', 'French', 'German', 'Italian'];

    // showDialog retorna o valor passado para Navigator.pop() quando é fechado.
    final bool? startTranslation = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Traduzir Currículo'),
          content: StatefulBuilder( // Necessário para o Dropdown atualizar dentro do diálogo.
            builder: (context, setDialogState) {
              return DropdownButton<String>(
                value: selectedLanguage,
                isExpanded: true,
                items: supportedLanguages
                    .map((lang) => DropdownMenuItem(value: lang, child: Text(lang)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setDialogState(() => selectedLanguage = value);
                  }
                },
              );
            },
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
            FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Traduzir')),
          ],
        );
      },
    );

    // Se o usuário confirmou a tradução, executa a lógica.
    if (startTranslation ?? false) {
      setState(() {
        _isProcessingAI = true;
        _processingMessage = 'Traduzindo com IA...';
      });
      try {
        await ref.read(translationRepositoryProvider).createTranslatedVersion(
          originalVersionId: widget.version.id,
          targetLanguage: selectedLanguage,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Nova versão traduzida criada com sucesso!'),
              backgroundColor: Colors.green));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Erro na tradução: ${e.toString()}'),
              backgroundColor: Colors.red));
        }
      } finally {
        if (mounted) {
          setState(() => _isProcessingAI = false);
        }
      }
    }
  }

  /// Exibe um diálogo para o usuário colar a descrição da vaga e inicia a otimização.
  Future<void> _onOptimize() async {
    final jobDescriptionController = TextEditingController();

    final bool? startOptimization = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Otimizar Currículo para Vaga'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                    'Cole abaixo a descrição completa da vaga para que a IA possa analisar e criar uma versão otimizada do seu currículo.'),
                const SizedBox(height: 16),
                TextField(
                  controller: jobDescriptionController,
                  maxLines: 10,
                  decoration: const InputDecoration(
                    hintText: 'Descrição da vaga...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar')),
            FilledButton(
              onPressed: () {
                if (jobDescriptionController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Por favor, cole a descrição da vaga.'),
                      backgroundColor: Colors.orange));
                } else {
                  Navigator.of(context).pop(true);
                }
              },
              child: const Text('Otimizar'),
            ),
          ],
        );
      },
    );

    // Se o usuário confirmou a otimização, executa a lógica.
    if (startOptimization ?? false) {
      setState(() {
        _isProcessingAI = true;
        _processingMessage = 'Otimizando com IA...';
      });
      try {

        // Usando o nome correto do provider: `optimizationRepositoryProvider`
        await ref.read(optimizationRepositoryProvider).createOptimizedVersion(
          jobDescription: jobDescriptionController.text,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Nova versão otimizada criada com sucesso!'),
              backgroundColor: Colors.green));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Erro na otimização: ${e.toString()}'),
              backgroundColor: Colors.red));
        }
      } finally {
        if (mounted) {
          setState(() => _isProcessingAI = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(widget.version.createdAt);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.version.name, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text('Criado em: $formattedDate', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 12),

            // Indicador de carregamento universal para qualquer operação de IA.
            if (_isProcessingAI)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(width: 16),
                    Text(_processingMessage),
                  ],
                ),
              ),

            // A fileira de botões de ação.
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.auto_awesome),
                  tooltip: 'Otimizar para Vaga (IA)',
                  // Desabilita o botão se uma operação de IA já estiver em andamento.
                  onPressed: _isProcessingAI ? null : _onOptimize,
                ),
                IconButton(
                  icon: const Icon(Icons.translate),
                  tooltip: 'Traduzir (IA)',
                  onPressed: _isProcessingAI ? null : _onTranslate,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: Theme.of(context).colorScheme.error,
                  tooltip: 'Excluir',
                  onPressed: _isProcessingAI ? null : () => showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text("Confirmar Exclusão"),
                      content: Text("Deseja realmente excluir a versão '${widget.version.name}'?"),
                      actions: [
                        TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text("Cancelar")),
                        FilledButton(onPressed: () {
                          ref.read(versionRepositoryProvider).deleteVersion(widget.version.id);
                          Navigator.of(ctx).pop();
                        }, child: const Text("Excluir")),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Editar Conteúdo',
                  onPressed: _isProcessingAI ? null : () => context.go('/version-editor/${widget.version.id}'),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  icon: const Icon(Icons.print_outlined),
                  label: const Text('Exportar'),
                  onPressed: _isProcessingAI ? null : () => context.go('/export/${widget.version.id}'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}