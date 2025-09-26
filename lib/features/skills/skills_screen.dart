import 'package:curriculator_free/core/services/isar_service.dart';
import 'package:curriculator_free/models/skill.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

// --- Providers (Gerenciamento de Estado com Riverpod) ---

// 1. Provider que fornece o repositório (a lógica de acesso ao banco de dados).
// Ele depende do serviço do Isar que já criamos.
final skillsRepositoryProvider = Provider<SkillsRepository>((ref) {
  final isarService = ref.watch(isarServiceProvider);
  return SkillsRepository(isarService);
});

// 2. Provider que busca a lista de habilidades de forma assíncrona.
// Ele assiste ao repositório e automaticamente re-busca os dados
// quando invalidado, mantendo a UI sempre atualizada.
final skillsStreamProvider = StreamProvider.autoDispose<List<Skill>>((ref) {
  final skillsRepository = ref.watch(skillsRepositoryProvider);
  return skillsRepository.watchSkills();
});

// --- Repositório (Lógica de Dados) ---

// Classe responsável por toda a comunicação com o banco de dados Isar
// relacionada a habilidades (Skills).
class SkillsRepository {
  final IsarService _isarService;

  SkillsRepository(this._isarService);

  // Assiste a mudanças na coleção de Skills e emite uma nova lista quando há alterações.
  Stream<List<Skill>> watchSkills() async* {
    final isar = await _isarService.db;
    yield* isar.skills.where().sortByName().watch(fireImmediately: true);
  }

  // Adiciona ou atualiza uma habilidade no banco de dados.
  Future<void> saveSkill(Skill skill) async {
    final isar = await _isarService.db;
    await isar.writeTxn(() async {
      await isar.skills.put(skill);
    });
  }

  // Deleta uma habilidade pelo seu ID.
  Future<void> deleteSkill(int skillId) async {
    final isar = await _isarService.db;
    await isar.writeTxn(() async {
      await isar.skills.delete(skillId);
    });
  }
}

// --- Tela Principal (UI) ---

class SkillsScreen extends ConsumerWidget {
  const SkillsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Assiste ao provider do stream para obter o estado atual (carregando, com dados ou com erro).
    final skillsAsyncValue = ref.watch(skillsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Habilidades'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          // `when` é a forma segura de lidar com estados assíncronos no Riverpod.
          child: skillsAsyncValue.when(
            data: (skills) {
              if (skills.isEmpty) {
                return const Center(
                  child: Text(
                    'Nenhuma habilidade cadastrada ainda.\nClique em "+" para adicionar a primeira.',
                    textAlign: TextAlign.center,
                  ),
                );
              }
              // Se há dados, constrói a lista.
              return ListView.builder(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                itemCount: skills.length,
                itemBuilder: (context, index) {
                  final skill = skills[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(skill.name ?? 'Habilidade sem nome'),
                      subtitle: Text('Nível: ${skill.level.name}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            tooltip: 'Editar Habilidade',
                            onPressed: () {
                              _showSkillDialog(context, ref, skill: skill);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete_outline,
                                color: Theme.of(context).colorScheme.error),
                            tooltip: 'Excluir Habilidade',
                            onPressed: () {
                              _showDeleteConfirmationDialog(context, ref, skill);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const CircularProgressIndicator(),
            error: (error, stackTrace) =>
                Text('Ocorreu um erro: $error'),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Adicionar Habilidade'),
        onPressed: () {
          // Chama o diálogo para criar uma nova habilidade (sem passar um 'skill' existente).
          _showSkillDialog(context, ref);
        },
      ),
    );
  }

  // --- Funções de UI (Diálogos) ---

  // Função para mostrar o diálogo de adicionar/editar habilidade.
  void _showSkillDialog(BuildContext context, WidgetRef ref, {Skill? skill}) {
    // Se `skill` não for nulo, estamos editando. Senão, criando um novo.
    final isEditing = skill != null;
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: skill?.name);
    SkillLevel selectedLevel = skill?.level ?? SkillLevel.intermediate;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'Editar Habilidade' : 'Nova Habilidade'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome da Habilidade',
                    hintText: 'Ex: Flutter, Gestão de Projetos, Inglês',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor, insira o nome da habilidade.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Usamos um `StatefulBuilder` para que o dropdown possa atualizar
                // seu próprio estado dentro do diálogo.
                StatefulBuilder(
                  builder: (context, setState) {
                    return DropdownButtonFormField<SkillLevel>(
                      value: selectedLevel,
                      decoration: const InputDecoration(
                        labelText: 'Nível de Proficiência',
                        border: OutlineInputBorder(),
                      ),
                      items: SkillLevel.values.map((level) {
                        return DropdownMenuItem(
                          value: level,
                          child: Text(level.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => selectedLevel = value);
                        }
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final newOrUpdatedSkill =
                  (skill ?? Skill()) // Se editando, usa o objeto existente.
                    ..name = nameController.text.trim()
                    ..level = selectedLevel;

                  // Pega o repositório e chama o método para salvar.
                  ref.read(skillsRepositoryProvider).saveSkill(newOrUpdatedSkill);

                  // O `skillsStreamProvider` vai se atualizar automaticamente.
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  // Diálogo de confirmação para exclusão.
  void _showDeleteConfirmationDialog(
      BuildContext context, WidgetRef ref, Skill skill) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text(
            'Você tem certeza que deseja excluir a habilidade "${skill.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton.tonal(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.errorContainer,
              foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
            ),
            onPressed: () {
              ref.read(skillsRepositoryProvider).deleteSkill(skill.id);
              Navigator.of(context).pop();
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}