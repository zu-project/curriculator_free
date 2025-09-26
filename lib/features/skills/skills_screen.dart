import 'package:curriculator_free/core/services/isar_service.dart';
import 'package:curriculator_free/models/skill.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

// --- Providers e Repositório (Lógica de Dados) ---

final skillsRepositoryProvider = Provider<SkillsRepository>((ref) {
  final isarService = ref.watch(isarServiceProvider);
  return SkillsRepository(isarService);
});

final skillsStreamProvider = StreamProvider.autoDispose<List<Skill>>((ref) {
  final skillsRepository = ref.watch(skillsRepositoryProvider);
  return skillsRepository.watchAllSkills();
});

class SkillsRepository {
  final IsarService _isarService;
  SkillsRepository(this._isarService);

  // Assiste a mudanças, ordenando por tipo e depois por nome.
  Stream<List<Skill>> watchAllSkills() async* {
    final isar = await _isarService.db;
    yield* isar.skills.where().sortByType().thenByName().watch(fireImmediately: true);
  }

  Future<void> saveSkill(Skill skill) async {
    final isar = await _isarService.db;
    await isar.writeTxn(() => isar.skills.put(skill));
  }

  Future<void> deleteSkill(int skillId) async {
    final isar = await _isarService.db;
    await isar.writeTxn(() => isar.skills.delete(skillId));
  }
}

// --- Tela Principal (UI) ---

class SkillsScreen extends ConsumerWidget {
  const SkillsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final skillsAsyncValue = ref.watch(skillsStreamProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Adicionar Habilidade'),
        onPressed: () => _showSkillDialog(context, ref),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: skillsAsyncValue.when(
              data: (skills) {
                if (skills.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Nenhuma habilidade cadastrada ainda.', style: TextStyle(fontSize: 16)),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('Adicionar Primeira Habilidade'),
                          onPressed: () => _showSkillDialog(context, ref),
                        ),
                      ],
                    ),
                  );
                }

                final hardSkills = skills.where((s) => s.type == SkillType.hardSkill).toList();
                final softSkills = skills.where((s) => s.type == SkillType.softSkill).toList();

                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 80), // Padding inferior para o FAB
                  children: [
                    _buildSkillSection(context, ref, 'Hard Skills (Técnicas)', hardSkills),
                    const SizedBox(height: 24),
                    _buildSkillSection(context, ref, 'Soft Skills (Comportamentais)', softSkills),
                  ],
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (error, stackTrace) => Text('Ocorreu um erro: $error'),
            ),
          ),
        ),
      ),
    );
  }

  // Constrói uma seção expansível para cada tipo de habilidade
  Widget _buildSkillSection(BuildContext context, WidgetRef ref, String title, List<Skill> skills) {
    return Card(
      elevation: 2,
      child: ExpansionTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        initiallyExpanded: true,
        children: skills.isNotEmpty
            ? skills.map((skill) => _buildSkillListTile(context, ref, skill)).toList()
            : [const ListTile(title: Text('Nenhuma habilidade deste tipo cadastrada.'))],
      ),
    );
  }

  // Constrói o item da lista para uma única habilidade
  Widget _buildSkillListTile(BuildContext context, WidgetRef ref, Skill skill) {
    return ListTile(
      leading: skill.isFeatured ? const Icon(Icons.star, color: Colors.amber) : const Icon(Icons.circle, size: 8),
      title: Text(skill.name),
      subtitle: Text('Nível: ${skill.level.name}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Editar Habilidade',
            onPressed: () => _showSkillDialog(context, ref, skill: skill),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
            tooltip: 'Excluir Habilidade',
            onPressed: () => _showDeleteConfirmationDialog(context, ref, skill),
          ),
        ],
      ),
    );
  }

  // Funções para mostrar os diálogos
  void _showSkillDialog(BuildContext context, WidgetRef ref, {Skill? skill}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _SkillFormDialog(skillToEdit: skill),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, WidgetRef ref, Skill skill) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Você tem certeza que deseja excluir a habilidade "${skill.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
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

// Widget para o formulário de diálogo, para manter o estado local
class _SkillFormDialog extends ConsumerStatefulWidget {
  final Skill? skillToEdit;
  const _SkillFormDialog({this.skillToEdit});

  @override
  ConsumerState<_SkillFormDialog> createState() => _SkillFormDialogState();
}

class _SkillFormDialogState extends ConsumerState<_SkillFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late SkillType _selectedType;
  late SkillLevel _selectedLevel;
  late bool _isFeatured;

  @override
  void initState() {
    super.initState();
    final skill = widget.skillToEdit;
    _nameController = TextEditingController(text: skill?.name);
    _selectedType = skill?.type ?? SkillType.hardSkill;
    _selectedLevel = skill?.level ?? SkillLevel.intermediate;
    _isFeatured = skill?.isFeatured ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      final newOrUpdatedSkill = (widget.skillToEdit ?? Skill())
        ..name = _nameController.text.trim()
        ..type = _selectedType
        ..level = _selectedLevel
        ..isFeatured = _isFeatured;

      ref.read(skillsRepositoryProvider).saveSkill(newOrUpdatedSkill);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.skillToEdit != null;
    return AlertDialog(
      title: Text(isEditing ? 'Editar Habilidade' : 'Nova Habilidade'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome da Habilidade',
                  hintText: 'Ex: Flutter, Gestão de Projetos',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                (value == null || value
                    .trim()
                    .isEmpty) ? 'Por favor, insira o nome.' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<SkillType>(
                value: _selectedType,
                decoration: const InputDecoration(
                    labelText: 'Tipo de Habilidade',
                    border: OutlineInputBorder()),
                items: SkillType.values
                    .map((type) =>
                    DropdownMenuItem(
                      value: type,
                      child: Text(type == SkillType.hardSkill
                          ? 'Hard Skill (Técnica)'
                          : 'Soft Skill (Comportamental)'),
                    ))
                    .toList(), // A vírgula antes do .toList() é importante.
                onChanged: (value) =>
                    setState(() =>
                    _selectedType = value ?? SkillType.hardSkill),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<SkillLevel>(
                value: _selectedLevel,
                decoration: const InputDecoration(
                    labelText: 'Nível de Proficiência',
                    border: OutlineInputBorder()),
                // --- CORREÇÃO APLICADA AQUI ---
                // A vírgula (,) foi adicionada antes do .toList()
                items: SkillLevel.values
                    .map((level) =>
                    DropdownMenuItem(
                      value: level,
                      child: Text(level.name[0].toUpperCase() +
                          level.name.substring(1)),
                    ))
                    .toList(), // Esta chamada ao .toList() agora está correta.
                onChanged: (value) =>
                    setState(
                            () =>
                        _selectedLevel = value ?? SkillLevel.intermediate),
              ),
              const SizedBox(height: 8),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Marcar como destaque'),
                subtitle:
                const Text('Dá ênfase a esta habilidade no currículo.'),
                value: _isFeatured,
                onChanged: (value) =>
                    setState(() => _isFeatured = value ?? false),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar')),
        ElevatedButton(onPressed: _onSave, child: const Text('Salvar')),
      ],
    );
  }
}