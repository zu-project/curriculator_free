import 'package:curriculator_free/core/services/isar_service.dart';
import 'package:curriculator_free/models/language.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

// --- Providers (Gerenciamento de Estado com Riverpod) ---

// 1. Provider para o Repositório de Idiomas.
// A lógica de acesso ao banco de dados fica encapsulada aqui.
final languagesRepositoryProvider = Provider<LanguagesRepository>((ref) {
  final isarService = ref.watch(isarServiceProvider);
  return LanguagesRepository(isarService);
});

// 2. Provider que busca o fluxo (Stream) da lista de idiomas.
// A UI que assistir a este provider será reconstruída automaticamente
// sempre que um idioma for adicionado, editado ou removido do banco.
final languagesStreamProvider = StreamProvider.autoDispose<List<Language>>((ref) {
  final languagesRepository = ref.watch(languagesRepositoryProvider);
  return languagesRepository.watchLanguages();
});

// --- Repositório (Lógica de Dados) ---

// Classe dedicada para interagir com a coleção de 'Language' no Isar.
class LanguagesRepository {
  final IsarService _isarService;

  LanguagesRepository(this._isarService);

  // Observa a coleção de idiomas e emite uma lista atualizada sempre que ocorrer uma mudança.
  Stream<List<Language>> watchLanguages() async* {
    final isar = await _isarService.db;
    yield* isar.languages
        .where()
        .sortByLanguageName()
        .watch(fireImmediately: true);
  }

  // Salva (cria ou atualiza) um idioma no banco de dados.
  Future<void> saveLanguage(Language language) async {
    final isar = await _isarService.db;
    await isar.writeTxn(() async {
      await isar.languages.put(language);
    });
  }

  // Remove um idioma do banco de dados usando seu ID.
  Future<void> deleteLanguage(int languageId) async {
    final isar = await _isarService.db;
    await isar.writeTxn(() async {
      await isar.languages.delete(languageId);
    });
  }
}

// --- Tela Principal (UI) ---

class LanguagesScreen extends ConsumerWidget {
  const LanguagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Assiste ao StreamProvider para obter o estado mais recente da lista de idiomas.
    final languagesAsyncValue = ref.watch(languagesStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Idiomas'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          // 'when' é a maneira do Riverpod de lidar com estados assíncronos
          // de forma segura e declarativa.
          child: languagesAsyncValue.when(
            data: (languages) {
              if (languages.isEmpty) {
                return const Center(
                  child: Text(
                    'Nenhum idioma cadastrado.\nClique em "+" para adicionar o primeiro.',
                    textAlign: TextAlign.center,
                  ),
                );
              }
              // Constrói a lista se houver dados.
              return ListView.builder(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                itemCount: languages.length,
                itemBuilder: (context, index) {
                  final language = languages[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title:
                      Text(language.languageName ?? 'Idioma sem nome'),
                      subtitle: Text('Proficiência: ${language.proficiency.name}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            tooltip: 'Editar Idioma',
                            onPressed: () {
                              _showLanguageDialog(context, ref, language: language);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete_outline,
                                color: Theme.of(context).colorScheme.error),
                            tooltip: 'Excluir Idioma',
                            onPressed: () {
                              _showDeleteConfirmationDialog(context, ref, language);
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
        label: const Text('Adicionar Idioma'),
        onPressed: () {
          // Para adicionar um novo, simplesmente não passamos um objeto 'language'.
          _showLanguageDialog(context, ref);
        },
      ),
    );
  }

  // --- Funções de UI (Diálogos) ---

  // Apresenta o diálogo para criar ou editar um idioma.
  void _showLanguageDialog(BuildContext context, WidgetRef ref, {Language? language}) {
    // A presença do objeto 'language' determina se estamos em modo de edição.
    final isEditing = language != null;
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: language?.languageName);
    LanguageProficiency selectedProficiency = language?.proficiency ?? LanguageProficiency.intermediate;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'Editar Idioma' : 'Novo Idioma'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome do Idioma',
                    hintText: 'Ex: Inglês, Espanhol, Alemão',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor, insira o nome do idioma.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // `StatefulBuilder` é usado para permitir que o Dropdown atualize
                // seu próprio estado sem reconstruir todo o diálogo.
                StatefulBuilder(
                  builder: (context, setState) {
                    return DropdownButtonFormField<LanguageProficiency>(
                      value: selectedProficiency,
                      decoration: const InputDecoration(
                        labelText: 'Nível de Proficiência',
                        border: OutlineInputBorder(),
                      ),
                      // Itera sobre todos os valores do Enum para criar os itens.
                      items: LanguageProficiency.values.map((level) {
                        return DropdownMenuItem(
                          value: level,
                          // Deixa a primeira letra maiúscula para melhor aparência
                          child: Text(level.name[0].toUpperCase() + level.name.substring(1)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => selectedProficiency = value);
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
                  // Se estamos editando, usamos o objeto existente; senão, criamos um novo.
                  final newOrUpdatedLanguage = (language ?? Language())
                    ..languageName = nameController.text.trim()
                    ..proficiency = selectedProficiency;

                  // Utiliza o repositório para salvar os dados no banco.
                  ref.read(languagesRepositoryProvider).saveLanguage(newOrUpdatedLanguage);

                  // A UI será atualizada automaticamente pelo StreamProvider.
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

  // Mostra um diálogo de confirmação antes de deletar um item.
  void _showDeleteConfirmationDialog(BuildContext context, WidgetRef ref, Language language) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text(
            'Você tem certeza que deseja excluir o idioma "${language.languageName}"?'),
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