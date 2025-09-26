import 'package:curriculator_free/core/services/isar_service.dart';
import 'package:curriculator_free/models/language.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

// --- Camada de Dados e Lógica ---

final languagesRepositoryProvider = Provider<LanguagesRepository>((ref) {
  final isarService = ref.watch(isarServiceProvider);
  return LanguagesRepository(isarService);
});

final languagesStreamProvider = StreamProvider.autoDispose<List<Language>>((ref) {
  final languagesRepository = ref.watch(languagesRepositoryProvider);
  return languagesRepository.watchAllLanguages();
});

class LanguagesRepository {
  final IsarService _isarService;
  LanguagesRepository(this._isarService);

  Stream<List<Language>> watchAllLanguages() async* {
    final isar = await _isarService.db;
    yield* isar.languages
        .where()
        .sortByLanguageName()
        .watch(fireImmediately: true);
  }

  Future<void> saveLanguage(Language language) async {
    final isar = await _isarService.db;
    await isar.writeTxn(() => isar.languages.put(language));
  }

  Future<void> deleteLanguage(int languageId) async {
    final isar = await _isarService.db;
    await isar.writeTxn(() => isar.languages.delete(languageId));
  }
}

// --- Tela Principal (UI) ---

class LanguagesScreen extends ConsumerWidget {
  const LanguagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languagesAsyncValue = ref.watch(languagesStreamProvider);

    return Scaffold(
      // O FloatingActionButton é gerenciado aqui, na tela específica,
      // pois a ShellScreen não tem contexto sobre qual FAB mostrar.
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Adicionar Idioma'),
        onPressed: () => _showLanguageDialog(context, ref),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: languagesAsyncValue.when(
              data: (languages) {
                if (languages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Nenhum idioma cadastrado ainda.',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('Adicionar Primeiro Idioma'),
                          onPressed: () => _showLanguageDialog(context, ref),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  itemCount: languages.length,
                  itemBuilder: (context, index) {
                    final language = languages[index];
                    return _buildLanguageCard(context, ref, language);
                  },
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

  // Constrói o Card para um único idioma na lista
  Widget _buildLanguageCard(BuildContext context, WidgetRef ref, Language language) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: language.isFeatured
            ? const Icon(Icons.star, color: Colors.amber)
            : const Icon(Icons.language, size: 24),
        title: Text(language.languageName),
        subtitle: Text('Proficiência: ${_getProficiencyLabel(language.proficiency)}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Editar Idioma',
              onPressed: () => _showLanguageDialog(context, ref, language: language),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
              tooltip: 'Excluir Idioma',
              onPressed: () => _showDeleteConfirmationDialog(context, ref, language),
            ),
          ],
        ),
      ),
    );
  }

  // Função para obter um nome amigável para o nível de proficiência
  String _getProficiencyLabel(LanguageProficiency proficiency) {
    switch (proficiency) {
      case LanguageProficiency.basic: return 'Básico';
      case LanguageProficiency.intermediate: return 'Intermediário';
      case LanguageProficiency.advanced: return 'Avançado';
      case LanguageProficiency.fluent: return 'Fluente';
      case LanguageProficiency.native: return 'Nativo';
    }
  }

  // Funções para mostrar os diálogos
  void _showLanguageDialog(BuildContext context, WidgetRef ref, {Language? language}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _LanguageFormDialog(languageToEdit: language),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, WidgetRef ref, Language language) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Você tem certeza que deseja excluir o idioma "${language.languageName}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
          FilledButton.tonal(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.errorContainer),
            onPressed: () {
              ref.read(languagesRepositoryProvider).deleteLanguage(language.id);
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
class _LanguageFormDialog extends ConsumerStatefulWidget {
  final Language? languageToEdit;
  const _LanguageFormDialog({this.languageToEdit});

  @override
  ConsumerState<_LanguageFormDialog> createState() => _LanguageFormDialogState();
}

class _LanguageFormDialogState extends ConsumerState<_LanguageFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late LanguageProficiency _selectedProficiency;
  late bool _isFeatured;

  @override
  void initState() {
    super.initState();
    final language = widget.languageToEdit;
    _nameController = TextEditingController(text: language?.languageName);
    _selectedProficiency = language?.proficiency ?? LanguageProficiency.intermediate;
    _isFeatured = language?.isFeatured ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      final newOrUpdatedLanguage = (widget.languageToEdit ?? Language())
        ..languageName = _nameController.text.trim()
        ..proficiency = _selectedProficiency
        ..isFeatured = _isFeatured;

      ref.read(languagesRepositoryProvider).saveLanguage(newOrUpdatedLanguage);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.languageToEdit != null;
    return AlertDialog(
      title: Text(isEditing ? 'Editar Idioma' : 'Novo Idioma'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Idioma',
                  hintText: 'Ex: Inglês, Espanhol',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => (value == null || value.trim().isEmpty) ? 'Por favor, insira o nome.' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<LanguageProficiency>(
                value: _selectedProficiency,
                decoration: const InputDecoration(labelText: 'Nível de Proficiência', border: OutlineInputBorder()),
                items: LanguageProficiency.values.map((level) => DropdownMenuItem(
                  value: level,
                  child: Text(LanguagesScreen()._getProficiencyLabel(level)), // Reutiliza a função de label
                )).toList(),
                onChanged: (value) => setState(() => _selectedProficiency = value ?? LanguageProficiency.intermediate),
              ),
              const SizedBox(height: 8),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Marcar como destaque'),
                subtitle: const Text('Dá ênfase a este idioma no currículo.'),
                value: _isFeatured,
                onChanged: (value) => setState(() => _isFeatured = value ?? false),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
        ElevatedButton(onPressed: _onSave, child: const Text('Salvar')),
      ],
    );
  }
}