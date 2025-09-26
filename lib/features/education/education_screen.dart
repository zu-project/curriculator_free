import 'package:curriculator_free/core/services/isar_service.dart';
import 'package:curriculator_free/models/education.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import 'package:month_year_picker/month_year_picker.dart';

// --- Camada de Dados e Lógica ---

final educationRepositoryProvider = Provider<EducationRepository>((ref) {
  final isarService = ref.watch(isarServiceProvider);
  return EducationRepository(isarService);
});

final educationStreamProvider =
StreamProvider.autoDispose<List<Education>>((ref) {
  final educationRepository = ref.watch(educationRepositoryProvider);
  return educationRepository.watchAllEducations();
});

class EducationRepository {
  final IsarService _isarService;
  EducationRepository(this._isarService);

  Stream<List<Education>> watchAllEducations() async* {
    final isar = await _isarService.db;
    yield* isar.educations
        .where()
        .sortByStartDateDesc()
        .watch(fireImmediately: true);
  }

  Future<void> saveEducation(Education education) async {
    final isar = await _isarService.db;
    await isar.writeTxn(() => isar.educations.put(education));
  }

  Future<void> deleteEducation(int educationId) async {
    final isar = await _isarService.db;
    await isar.writeTxn(() => isar.educations.delete(educationId));
  }
}

// --- Tela Principal (UI) ---

class EducationScreen extends ConsumerWidget {
  const EducationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final educationAsyncValue = ref.watch(educationStreamProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Adicionar Formação'),
        onPressed: () => _showEducationDialog(context, ref),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: educationAsyncValue.when(
              data: (educations) {
                if (educations.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Nenhuma formação acadêmica cadastrada.',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('Adicionar Primeira Formação'),
                          onPressed: () => _showEducationDialog(context, ref),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 80), // Padding inferior para o FAB
                  itemCount: educations.length,
                  itemBuilder: (context, index) {
                    return _EducationCard(education: educations[index]);
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

  void _showEducationDialog(BuildContext context, WidgetRef ref, {Education? education}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _EducationFormDialog(educationToEdit: education),
    );
  }
}

// Card para exibir uma única formação
class _EducationCard extends ConsumerWidget {
  const _EducationCard({required this.education});
  final Education education;

  String _formatPeriod(Education edu) {
    final format = DateFormat('MMMM yyyy', 'pt_BR');
    final startDateString = edu.startDate != null ? format.format(edu.startDate!) : 'N/A';
    final endDateString = edu.inProgress ? 'Presente' : (edu.endDate != null ? format.format(edu.endDate!) : 'N/A');
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
                if (education.isFeatured)
                  const Padding(
                    padding: EdgeInsets.only(right: 12.0, top: 4.0),
                    child: Icon(Icons.star, color: Colors.amber, size: 20),
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${education.degree} em ${education.fieldOfStudy}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        education.institution,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.secondary),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      tooltip: 'Editar Formação',
                      onPressed: () => EducationScreen()._showEducationDialog(context, ref, education: education),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
                      tooltip: 'Excluir Formação',
                      onPressed: () => _showDeleteConfirmationDialog(context, ref, education),
                    ),
                  ],
                )
              ],
            ),
            Padding(
              padding: EdgeInsets.only(left: education.isFeatured ? 32.0 : 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(_formatPeriod(education), style: Theme.of(context).textTheme.bodySmall),
                  if (education.description?.isNotEmpty ?? false) ...[
                    const SizedBox(height: 12),
                    Text(education.description!, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, WidgetRef ref, Education education) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Deseja excluir a formação "${education.degree} em ${education.fieldOfStudy}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
          FilledButton.tonal(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.errorContainer),
            onPressed: () {
              ref.read(educationRepositoryProvider).deleteEducation(education.id);
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
class _EducationFormDialog extends ConsumerStatefulWidget {
  final Education? educationToEdit;
  const _EducationFormDialog({this.educationToEdit});

  @override
  ConsumerState<_EducationFormDialog> createState() => _EducationFormDialogState();
}

class _EducationFormDialogState extends ConsumerState<_EducationFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _institutionController;
  late final TextEditingController _degreeController;
  late final TextEditingController _fieldOfStudyController;
  late final TextEditingController _descriptionController;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _inProgress = false;
  bool _isFeatured = false;

  @override
  void initState() {
    super.initState();
    final edu = widget.educationToEdit;
    _institutionController = TextEditingController(text: edu?.institution);
    _degreeController = TextEditingController(text: edu?.degree);
    _fieldOfStudyController = TextEditingController(text: edu?.fieldOfStudy);
    _descriptionController = TextEditingController(text: edu?.description);
    _startDate = edu?.startDate;
    _endDate = edu?.endDate;
    _inProgress = edu?.inProgress ?? false;
    _isFeatured = edu?.isFeatured ?? false;
  }
  @override
  void dispose() {
    _institutionController.dispose(); _degreeController.dispose();
    _fieldOfStudyController.dispose(); _descriptionController.dispose();
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
      final eduToSave = (widget.educationToEdit ?? Education())
        ..institution = _institutionController.text.trim()
        ..degree = _degreeController.text.trim()
        ..fieldOfStudy = _fieldOfStudyController.text.trim()
        ..description = _descriptionController.text.trim()
        ..startDate = _startDate
        ..endDate = _inProgress ? null : _endDate
        ..inProgress = _inProgress
        ..isFeatured = _isFeatured;

      ref.read(educationRepositoryProvider).saveEducation(eduToSave);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMMM yyyy', 'pt_BR');
    final isEditing = widget.educationToEdit != null;

    return AlertDialog(
      title: Text(isEditing ? 'Editar Formação' : 'Nova Formação'),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(controller: _institutionController, decoration: const InputDecoration(labelText: 'Instituição*'), validator: (v) => v!.trim().isEmpty ? 'Campo obrigatório' : null),
                const SizedBox(height: 12),
                TextFormField(controller: _degreeController, decoration: const InputDecoration(labelText: 'Tipo do Curso*', hintText: 'Ex: Graduação, Mestrado, Técnico'), validator: (v) => v!.trim().isEmpty ? 'Campo obrigatório' : null),
                const SizedBox(height: 12),
                TextFormField(controller: _fieldOfStudyController, decoration: const InputDecoration(labelText: 'Nome do Curso*', hintText: 'Ex: Ciência da Computação'), validator: (v) => v!.trim().isEmpty ? 'Campo obrigatório' : null),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: Text(_startDate == null ? 'Data de Início*' : 'Início: ${dateFormat.format(_startDate!)}')),
                    IconButton(icon: const Icon(Icons.calendar_today), onPressed: () => _selectMonthYear(context, isStartDate: true)),
                  ],
                ),
                if (_startDate == null) Padding(padding: const EdgeInsets.only(top: 4.0), child: Text('Selecione uma data de início', style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12))),
                CheckboxListTile(contentPadding: EdgeInsets.zero, title: const Text('Estou cursando'), value: _inProgress, onChanged: (v) => setState(() => _inProgress = v ?? false)),
                if (!_inProgress) Row(
                  children: [
                    Expanded(child: Text(_endDate == null ? 'Data de Conclusão' : 'Conclusão: ${dateFormat.format(_endDate!)}')),
                    IconButton(icon: const Icon(Icons.calendar_today), onPressed: () => _selectMonthYear(context, isStartDate: false)),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(controller: _descriptionController, decoration: const InputDecoration(labelText: 'Descrição/Observações', alignLabelWithHint: true, border: OutlineInputBorder()), maxLines: 3),
                const SizedBox(height: 8),
                CheckboxListTile(contentPadding: EdgeInsets.zero, title: const Text('Marcar como destaque'), subtitle: const Text('Dá ênfase a esta formação no currículo.'), value: _isFeatured, onChanged: (v) => setState(() => _isFeatured = v ?? false)),
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