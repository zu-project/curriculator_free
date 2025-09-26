import 'package:curriculator_free/core/services/isar_service.dart';
import 'package:curriculator_free/models/experience.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import 'package:month_year_picker/month_year_picker.dart';

// --- Providers (Gerenciamento de Estado com Riverpod) ---

// 1. Provider para o Repositório, que lida com a lógica de acesso ao banco de dados.
final experiencesRepositoryProvider = Provider<ExperiencesRepository>((ref) {
  final isarService = ref.watch(isarServiceProvider);
  return ExperiencesRepository(isarService);
});

// 2. StreamProvider para observar a lista de experiências em tempo real.
// A UI que assiste a este provider será reconstruída automaticamente
// sempre que uma experiência for adicionada, editada ou removida.
final experiencesStreamProvider =
StreamProvider.autoDispose<List<Experience>>((ref) {
  final experiencesRepository = ref.watch(experiencesRepositoryProvider);
  return experiencesRepository.watchExperiences();
});


// --- Repositório (Lógica de Dados) ---

// Classe responsável por toda a comunicação com o banco de dados Isar
// relacionada a experiências profissionais (Experience).
class ExperiencesRepository {
  final IsarService _isarService;

  ExperiencesRepository(this._isarService);

  // Observa a coleção de experiências, ordenando da data de início mais recente para a mais antiga.
  Stream<List<Experience>> watchExperiences() async* {
    final isar = await _isarService.db;
    yield* isar.experiences
        .where()
        .sortByStartDateDesc()
        .watch(fireImmediately: true);
  }

  // Salva (cria ou atualiza) uma experiência profissional no banco de dados.
  Future<void> saveExperience(Experience experience) async {
    final isar = await _isarService.db;
    await isar.writeTxn(() async {
      await isar.experiences.put(experience);
    });
  }

  // Deleta uma experiência do banco de dados pelo seu ID.
  Future<void> deleteExperience(int experienceId) async {
    final isar = await _isarService.db;
    await isar.writeTxn(() async {
      await isar.experiences.delete(experienceId);
    });
  }
}


// --- Tela Principal (UI) ---

class ExperienceScreen extends ConsumerWidget {
  const ExperienceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Assiste ao provider do stream para obter o estado atual dos dados.
    final experiencesAsyncValue = ref.watch(experiencesStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Experiência Profissional'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: experiencesAsyncValue.when(
            data: (experiences) {
              if (experiences.isEmpty) {
                return const Center(
                  child: Text(
                    'Nenhuma experiência profissional cadastrada.\nClique em "+" para adicionar a primeira.',
                    textAlign: TextAlign.center,
                  ),
                );
              }
              // Se há dados, constrói a lista de experiências.
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                itemCount: experiences.length,
                itemBuilder: (context, index) {
                  final experience = experiences[index];
                  return _ExperienceCard(experience: experience);
                },
              );
            },
            loading: () => const CircularProgressIndicator(),
            error: (error, stack) => Text('Ocorreu um erro: $error'),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Adicionar Experiência'),
        onPressed: () {
          // Chama o diálogo para criar uma nova experiência.
          _showExperienceDialog(context, ref);
        },
      ),
    );
  }

  // Função helper para exibir o diálogo de formulário.
  void _showExperienceDialog(BuildContext context, WidgetRef ref, {Experience? experience}) {
    showDialog(
      context: context,
      barrierDismissible: false, // Impede fechar o diálogo ao clicar fora
      builder: (context) => ExperienceFormDialog(
        ref: ref,
        experience: experience,
      ),
    );
  }
}


// --- Widgets Auxiliares (Boa prática para organizar a UI) ---

// Widget para exibir um único card de experiência na lista.
class _ExperienceCard extends ConsumerWidget {
  const _ExperienceCard({required this.experience});
  final Experience experience;

  // Função para formatar o período no formato "Mês Ano - Mês Ano".
  String _formatPeriod(Experience exp) {
    final format = DateFormat('MMMM yyyy', 'pt_BR');
    final startDateString = exp.startDate != null ? format.format(exp.startDate!) : 'N/A';
    final endDateString = exp.isCurrent ? 'Presente' : (exp.endDate != null ? format.format(exp.endDate!) : 'N/A');

    // Capitaliza a primeira letra para melhor aparência.
    final capitalizedStartDate = startDateString[0].toUpperCase() + startDateString.substring(1);
    final capitalizedEndDate = endDateString[0].toUpperCase() + endDateString.substring(1);

    return '$capitalizedStartDate - $capitalizedEndDate';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    experience.jobTitle ?? 'Cargo não informado',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      tooltip: 'Editar Experiência',
                      onPressed: () {
                        // Chama o mesmo método da tela principal para editar.
                        ExperienceScreen()._showExperienceDialog(context, ref, experience: experience);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
                      tooltip: 'Excluir Experiência',
                      onPressed: () {
                        _showDeleteConfirmationDialog(context, ref, experience);
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${experience.company ?? "Empresa não informada"} • ${experience.location ?? "Local não informado"}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _formatPeriod(experience),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Text(
              experience.description ?? 'Sem descrição.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  // Diálogo para confirmar a exclusão de um item.
  void _showDeleteConfirmationDialog(BuildContext context, WidgetRef ref, Experience experience) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Você tem certeza que deseja excluir a experiência como "${experience.jobTitle}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
          FilledButton.tonal(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.errorContainer),
            onPressed: () {
              ref.read(experiencesRepositoryProvider).deleteExperience(experience.id);
              Navigator.of(context).pop();
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}

// Diálogo com o formulário, convertido para StatefulWidget para gerenciar seu estado interno.
class ExperienceFormDialog extends StatefulWidget {
  final WidgetRef ref;
  final Experience? experience;

  const ExperienceFormDialog({super.key, required this.ref, this.experience});

  @override
  State<ExperienceFormDialog> createState() => _ExperienceFormDialogState();
}

class _ExperienceFormDialogState extends State<ExperienceFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _jobTitleController;
  late TextEditingController _companyController;
  late TextEditingController _locationController;
  late TextEditingController _descriptionController;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isCurrent = false;

  @override
  void initState() {
    super.initState();
    final experience = widget.experience;
    _jobTitleController = TextEditingController(text: experience?.jobTitle);
    _companyController = TextEditingController(text: experience?.company);
    _locationController = TextEditingController(text: experience?.location);
    _descriptionController = TextEditingController(text: experience?.description);
    _startDate = experience?.startDate;
    _endDate = experience?.endDate;
    _isCurrent = experience?.isCurrent ?? false;
  }

  @override
  void dispose() {
    _jobTitleController.dispose();
    _companyController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Função que chama o seletor de Mês/Ano.
  Future<void> _selectMonthYear(BuildContext context, {required bool isStartDate}) async {
    final pickedDate = await showMonthYearPicker(
      context: context,
      initialDate: (isStartDate ? _startDate : _endDate) ?? DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'BR'), // Garante que o seletor apareça em português
    );

    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          _startDate = pickedDate;
        } else {
          _endDate = pickedDate;
        }
      });
    }
  }

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      final experienceToSave = (widget.experience ?? Experience())
        ..jobTitle = _jobTitleController.text.trim()
        ..company = _companyController.text.trim()
        ..location = _locationController.text.trim()
        ..description = _descriptionController.text.trim()
        ..startDate = _startDate
        ..endDate = _isCurrent ? null : _endDate // Se for atual, a data de fim é nula.
        ..isCurrent = _isCurrent;

      widget.ref.read(experiencesRepositoryProvider).saveExperience(experienceToSave);

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMMM yyyy', 'pt_BR');

    return AlertDialog(
      title: Text(widget.experience == null ? 'Nova Experiência' : 'Editar Experiência'),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 500, // Largura fixa para melhor layout no desktop
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(controller: _jobTitleController, decoration: const InputDecoration(labelText: 'Cargo'), validator: (value) => value!.trim().isEmpty ? 'Este campo é obrigatório' : null),
                const SizedBox(height: 12),
                TextFormField(controller: _companyController, decoration: const InputDecoration(labelText: 'Empresa'), validator: (value) => value!.trim().isEmpty ? 'Este campo é obrigatório' : null),
                const SizedBox(height: 12),
                TextFormField(controller: _locationController, decoration: const InputDecoration(labelText: 'Localização', hintText: 'Ex: São Paulo, SP')),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: Text(_startDate == null ? 'Data de Início*' : 'Início: ${dateFormat.format(_startDate!)}')),
                    IconButton(icon: const Icon(Icons.calendar_today), onPressed: () => _selectMonthYear(context, isStartDate: true)),
                  ],
                ),
                // Validação visual simples para a data de início
                if (_startDate == null) Padding(padding: const EdgeInsets.only(top: 4.0), child: Text('Selecione uma data de início', style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12))),
                CheckboxListTile(
                  title: const Text('Este é meu emprego atual'),
                  value: _isCurrent,
                  onChanged: (value) => setState(() => _isCurrent = value ?? false),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
                if (!_isCurrent) Row(
                  children: [
                    Expanded(child: Text(_endDate == null ? 'Data de Término' : 'Término: ${dateFormat.format(_endDate!)}')),
                    IconButton(icon: const Icon(Icons.calendar_today), onPressed: () => _selectMonthYear(context, isStartDate: false)),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(controller: _descriptionController, decoration: const InputDecoration(labelText: 'Descrição das Atividades', alignLabelWithHint: true, border: OutlineInputBorder()), maxLines: 4),
              ],
            ),
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