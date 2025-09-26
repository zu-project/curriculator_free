import 'package:curriculator_free/core/services/isar_service.dart';
import 'package:curriculator_free/models/education.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import 'package:month_year_picker/month_year_picker.dart';

// --- Providers (Gerenciamento de Estado com Riverpod) ---

// 1. Provider para o Repositório, que lida com a lógica de acesso ao banco de dados.
final educationRepositoryProvider = Provider<EducationRepository>((ref) {
  final isarService = ref.watch(isarServiceProvider);
  return EducationRepository(isarService);
});

// 2. StreamProvider para observar a lista de formações em tempo real.
// Qualquer widget que assistir a este provider será reconstruído
// automaticamente quando os dados no banco de dados mudarem.
final educationStreamProvider =
StreamProvider.autoDispose<List<Education>>((ref) {
  final educationRepository = ref.watch(educationRepositoryProvider);
  return educationRepository.watchEducations();
});


// --- Repositório (Lógica de Dados) ---

// Classe responsável por toda a comunicação com a coleção 'Education' no Isar.
class EducationRepository {
  final IsarService _isarService;

  EducationRepository(this._isarService);

  // Observa a coleção, ordenando da data de início mais recente para a mais antiga.
  Stream<List<Education>> watchEducations() async* {
    final isar = await _isarService.db;
    yield* isar.educations
        .where()
        .sortByStartDateDesc()
        .watch(fireImmediately: true);
  }

  // Salva (cria ou atualiza) uma formação acadêmica no banco de dados.
  Future<void> saveEducation(Education education) async {
    final isar = await _isarService.db;
    await isar.writeTxn(() async {
      await isar.educations.put(education);
    });
  }

  // Deleta uma formação do banco de dados pelo seu ID.
  Future<void> deleteEducation(int educationId) async {
    final isar = await _isarService.db;
    await isar.writeTxn(() async {
      await isar.educations.delete(educationId);
    });
  }
}


// --- Tela Principal (UI) ---

class EducationScreen extends ConsumerWidget {
  const EducationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Assiste ao provider do stream para obter o estado atual dos dados.
    final educationAsyncValue = ref.watch(educationStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Formação Acadêmica'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: educationAsyncValue.when(
            data: (educations) {
              if (educations.isEmpty) {
                return const Center(
                  child: Text(
                    'Nenhuma formação acadêmica cadastrada.\nClique em "+" para adicionar a primeira.',
                    textAlign: TextAlign.center,
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
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
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Adicionar Formação'),
        onPressed: () => _showEducationDialog(context, ref),
      ),
    );
  }

  // Função para exibir o diálogo de formulário de adição/edição.
  void _showEducationDialog(BuildContext context, WidgetRef ref, {Education? education}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => EducationFormDialog(
        ref: ref,
        education: education,
      ),
    );
  }
}


// --- Widgets Auxiliares ---

// Widget para exibir um único card de formação na lista.
class _EducationCard extends ConsumerWidget {
  const _EducationCard({required this.education});
  final Education education;

  String _formatPeriod(Education edu) {
    final format = DateFormat('MMMM yyyy', 'pt_BR');
    final startDateString = edu.startDate != null ? format.format(edu.startDate!) : 'N/A';
    final endDateString = edu.inProgress ? 'Presente' : (edu.endDate != null ? format.format(edu.endDate!) : 'N/A');

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
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  '${education.degree ?? "Curso"} em ${education.fieldOfStudy ?? "Área não informada"}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  education.institution ?? 'Instituição não informada',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ])),
              Row(mainAxisSize: MainAxisSize.min, children: [
                IconButton(icon: const Icon(Icons.edit_outlined), tooltip: 'Editar Formação', onPressed: () => EducationScreen()._showEducationDialog(context, ref, education: education)),
                IconButton(icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error), tooltip: 'Excluir Formação', onPressed: () => _showDeleteConfirmationDialog(context, ref, education)),
              ])
            ]),
            const SizedBox(height: 8),
            Text(_formatPeriod(education), style: Theme.of(context).textTheme.bodySmall),
            if (education.description?.isNotEmpty ?? false) ...[
              const SizedBox(height: 12),
              Text(education.description!, style: Theme.of(context).textTheme.bodyMedium),
            ],
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

// Diálogo com o formulário, convertido para StatefulWidget para gerenciar seu estado interno.
class EducationFormDialog extends StatefulWidget {
  const EducationFormDialog({super.key, required this.ref, this.education});
  final WidgetRef ref;
  final Education? education;

  @override
  State<EducationFormDialog> createState() => _EducationFormDialogState();
}

class _EducationFormDialogState extends State<EducationFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _institutionController;
  late TextEditingController _degreeController;
  late TextEditingController _fieldOfStudyController;
  late TextEditingController _descriptionController;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _inProgress = false;

  @override
  void initState() {
    super.initState();
    final edu = widget.education;
    _institutionController = TextEditingController(text: edu?.institution);
    _degreeController = TextEditingController(text: edu?.degree);
    _fieldOfStudyController = TextEditingController(text: edu?.fieldOfStudy);
    _descriptionController = TextEditingController(text: edu?.description);
    _startDate = edu?.startDate;
    _endDate = edu?.endDate;
    _inProgress = edu?.inProgress ?? false;
  }

  @override
  void dispose() {
    _institutionController.dispose();
    _degreeController.dispose();
    _fieldOfStudyController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectMonthYear(BuildContext context, {required bool isStartDate}) async {
    final pickedDate = await showMonthYearPicker(
      context: context,
      initialDate: (isStartDate ? _startDate : _endDate) ?? DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'BR'),
    );
    if (pickedDate != null) {
      setState(() => isStartDate ? _startDate = pickedDate : _endDate = pickedDate);
    }
  }

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      final educationToSave = (widget.education ?? Education())
        ..institution = _institutionController.text.trim()
        ..degree = _degreeController.text.trim()
        ..fieldOfStudy = _fieldOfStudyController.text.trim()
        ..description = _descriptionController.text.trim()
        ..startDate = _startDate
        ..endDate = _inProgress ? null : _endDate
        ..inProgress = _inProgress;

      widget.ref.read(educationRepositoryProvider).saveEducation(educationToSave);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMMM yyyy', 'pt_BR');

    return AlertDialog(
      title: Text(widget.education == null ? 'Nova Formação' : 'Editar Formação'),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(controller: _institutionController, decoration: const InputDecoration(labelText: 'Instituição'), validator: (value) => value!.trim().isEmpty ? 'Este campo é obrigatório' : null),
                const SizedBox(height: 12),
                TextFormField(controller: _degreeController, decoration: const InputDecoration(labelText: 'Tipo do Curso', hintText: 'Ex: Graduação, Mestrado, Técnico'), validator: (value) => value!.trim().isEmpty ? 'Este campo é obrigatório' : null),
                const SizedBox(height: 12),
                TextFormField(controller: _fieldOfStudyController, decoration: const InputDecoration(labelText: 'Nome do Curso', hintText: 'Ex: Ciência da Computação'), validator: (value) => value!.trim().isEmpty ? 'Este campo é obrigatório' : null),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: Text(_startDate == null ? 'Data de Início*' : 'Início: ${dateFormat.format(_startDate!)}')),
                    IconButton(icon: const Icon(Icons.calendar_today), onPressed: () => _selectMonthYear(context, isStartDate: true)),
                  ],
                ),
                if (_startDate == null) Padding(padding: const EdgeInsets.only(top: 4.0), child: Text('Selecione uma data de início', style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12))),
                CheckboxListTile(title: const Text('Estou cursando'), value: _inProgress, onChanged: (val) => setState(() => _inProgress = val ?? false), controlAffinity: ListTileControlAffinity.leading, contentPadding: EdgeInsets.zero),
                if (!_inProgress) Row(
                  children: [
                    Expanded(child: Text(_endDate == null ? 'Data de Conclusão' : 'Conclusão: ${dateFormat.format(_endDate!)}')),
                    IconButton(icon: const Icon(Icons.calendar_today), onPressed: () => _selectMonthYear(context, isStartDate: false)),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(controller: _descriptionController, decoration: const InputDecoration(labelText: 'Descrição/Observações', alignLabelWithHint: true, border: OutlineInputBorder()), maxLines: 3),
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