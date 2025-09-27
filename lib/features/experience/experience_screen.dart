//C:\Users\ziofl\StudioProjects\curriculator_free\lib\features\experience\experience_screen.dart
import 'package:curriculator_free/core/services/isar_service.dart';
import 'package:curriculator_free/models/experience.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import 'package:month_year_picker/month_year_picker.dart';

// --- Camada de Dados e Lógica ---

final experiencesRepositoryProvider = Provider<ExperiencesRepository>((ref) {
  final isarService = ref.watch(isarServiceProvider);
  return ExperiencesRepository(isarService);
});

final experiencesStreamProvider =
StreamProvider.autoDispose<List<Experience>>((ref) {
  final experiencesRepository = ref.watch(experiencesRepositoryProvider);
  return experiencesRepository.watchAllExperiences();
});

class ExperiencesRepository {
  final IsarService _isarService;
  ExperiencesRepository(this._isarService);

  // Ordena por data de início, da mais recente para a mais antiga.
  Stream<List<Experience>> watchAllExperiences() async* {
    final isar = await _isarService.db;
    yield* isar.experiences
        .where()
        .sortByStartDateDesc()
        .watch(fireImmediately: true);
  }

  Future<void> saveExperience(Experience experience) async {
    final isar = await _isarService.db;
    await isar.writeTxn(() => isar.experiences.put(experience));
  }

  Future<void> deleteExperience(int experienceId) async {
    final isar = await _isarService.db;
    await isar.writeTxn(() => isar.experiences.delete(experienceId));
  }
}

// --- Tela Principal (UI) ---

class ExperienceScreen extends ConsumerWidget {
  const ExperienceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final experiencesAsyncValue = ref.watch(experiencesStreamProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Adicionar Experiência'),
        onPressed: () => _showExperienceDialog(context, ref),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: experiencesAsyncValue.when(
              data: (experiences) {
                if (experiences.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Nenhuma experiência profissional cadastrada.',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('Adicionar Primeira Experiência'),
                          onPressed: () => _showExperienceDialog(context, ref),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  itemCount: experiences.length,
                  itemBuilder: (context, index) {
                    return _ExperienceCard(experience: experiences[index]);
                  },
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => Text('Ocorreu um erro: $error'),
            ),
          ),
        ),
      ),
    );
  }

  void _showExperienceDialog(BuildContext context, WidgetRef ref, {Experience? experience}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _ExperienceFormDialog(experienceToEdit: experience),
    );
  }
}

// Card para exibir uma única experiência
class _ExperienceCard extends ConsumerWidget {
  const _ExperienceCard({required this.experience});
  final Experience experience;

  String _formatPeriod(Experience exp) {
    final format = DateFormat('MMMM yyyy', 'pt_BR');
    final startDateString = exp.startDate != null ? format.format(exp.startDate!) : 'N/A';
    final endDateString = exp.isCurrent ? 'Presente' : (exp.endDate != null ? format.format(exp.endDate!) : 'N/A');
    return '${startDateString[0].toUpperCase()}${startDateString.substring(1)} - ${endDateString[0].toUpperCase()}${endDateString.substring(1)}';
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (experience.isFeatured)
                  const Padding(
                    padding: EdgeInsets.only(right: 12.0, top: 4.0),
                    child: Icon(Icons.star, color: Colors.amber, size: 20),
                  ),
                Expanded(
                  child: Text(
                    experience.jobTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      tooltip: 'Editar Experiência',
                      onPressed: () => ExperienceScreen()._showExperienceDialog(context, ref, experience: experience),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
                      tooltip: 'Excluir Experiência',
                      onPressed: () => _showDeleteConfirmationDialog(context, ref, experience),
                    ),
                  ],
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(left: experience.isFeatured ? 32.0 : 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    '${experience.company} • ${experience.location ?? "Local não informado"}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.secondary),
                  ),
                  const SizedBox(height: 8),
                  Text(_formatPeriod(experience), style: Theme.of(context).textTheme.bodySmall),
                  if (experience.description?.isNotEmpty ?? false) ...[
                    const SizedBox(height: 12),
                    Text(experience.description!, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

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

// Widget para o formulário de diálogo, para manter o estado local
class _ExperienceFormDialog extends ConsumerStatefulWidget {
  final Experience? experienceToEdit;
  const _ExperienceFormDialog({this.experienceToEdit});

  @override
  ConsumerState<_ExperienceFormDialog> createState() => _ExperienceFormDialogState();
}

class _ExperienceFormDialogState extends ConsumerState<_ExperienceFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _jobTitleController;
  late final TextEditingController _companyController;
  late final TextEditingController _locationController;
  late final TextEditingController _descriptionController;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isCurrent = false;
  bool _isFeatured = false;

  @override
  void initState() {
    super.initState();
    final exp = widget.experienceToEdit;
    _jobTitleController = TextEditingController(text: exp?.jobTitle);
    _companyController = TextEditingController(text: exp?.company);
    _locationController = TextEditingController(text: exp?.location);
    _descriptionController = TextEditingController(text: exp?.description);
    _startDate = exp?.startDate;
    _endDate = exp?.endDate;
    _isCurrent = exp?.isCurrent ?? false;
    _isFeatured = exp?.isFeatured ?? false;
  }
  @override
  void dispose() {
    _jobTitleController.dispose(); _companyController.dispose();
    _locationController.dispose(); _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectMonthYear(BuildContext context, {required bool isStartDate}) async {
    final picked = await showMonthYearPicker(
      context: context, initialDate: (isStartDate ? _startDate : _endDate) ?? DateTime.now(),
      firstDate: DateTime(1950), lastDate: DateTime.now(), locale: const Locale('pt', 'BR'),
    );
    if (picked != null) {
      setState(() => isStartDate ? _startDate = picked : _endDate = picked);
    }
  }

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      final expToSave = (widget.experienceToEdit ?? Experience())
        ..jobTitle = _jobTitleController.text.trim()
        ..company = _companyController.text.trim()
        ..location = _locationController.text.trim()
        ..description = _descriptionController.text.trim()
        ..startDate = _startDate
        ..endDate = _isCurrent ? null : _endDate
        ..isCurrent = _isCurrent
        ..isFeatured = _isFeatured;

      ref.read(experiencesRepositoryProvider).saveExperience(expToSave);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMMM yyyy', 'pt_BR');
    final isEditing = widget.experienceToEdit != null;

    return AlertDialog(
      title: Text(isEditing ? 'Editar Experiência' : 'Nova Experiência'),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(controller: _jobTitleController, decoration: const InputDecoration(labelText: 'Cargo*'), validator: (v) => v!.trim().isEmpty ? 'Campo obrigatório' : null),
                const SizedBox(height: 12),
                TextFormField(controller: _companyController, decoration: const InputDecoration(labelText: 'Empresa*'), validator: (v) => v!.trim().isEmpty ? 'Campo obrigatório' : null),
                const SizedBox(height: 12),
                TextFormField(controller: _locationController, decoration: const InputDecoration(labelText: 'Localização', hintText: 'Ex: São Paulo, SP')),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: Text(_startDate == null ? 'Data de Início*' : 'Início: ${dateFormat.format(_startDate!)}')),
                    IconButton(icon: const Icon(Icons.calendar_today), onPressed: () => _selectMonthYear(context, isStartDate: true)),
                  ],
                ),
                if (_startDate == null) Padding(padding: const EdgeInsets.only(top: 4.0), child: Text('Selecione uma data de início', style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12))),
                CheckboxListTile(contentPadding: EdgeInsets.zero, title: const Text('Este é meu emprego atual'), value: _isCurrent, onChanged: (v) => setState(() => _isCurrent = v ?? false)),
                if (!_isCurrent) Row(children: [
                  Expanded(child: Text(_endDate == null ? 'Data de Término' : 'Término: ${dateFormat.format(_endDate!)}')),
                  IconButton(icon: const Icon(Icons.calendar_today), onPressed: () => _selectMonthYear(context, isStartDate: false)),
                ]),
                const SizedBox(height: 12),
                TextFormField(controller: _descriptionController, decoration: const InputDecoration(labelText: 'Descrição das Atividades', alignLabelWithHint: true, border: OutlineInputBorder()), maxLines: 5),
                const SizedBox(height: 8),
                CheckboxListTile(contentPadding: EdgeInsets.zero, title: const Text('Marcar como destaque'), subtitle: const Text('Dá ênfase a esta experiência no currículo.'), value: _isFeatured, onChanged: (v) => setState(() => _isFeatured = v ?? false)),
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