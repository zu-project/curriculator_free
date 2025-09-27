//C:\Users\ziofl\StudioProjects\curriculator_free\lib\features\versions\version_editor_screen.dart
import 'package:curriculator_free/core/services/isar_service.dart';
import 'package:curriculator_free/models/curriculum_version.dart';
import 'package:curriculator_free/models/education.dart';
import 'package:curriculator_free/models/experience.dart';
import 'package:curriculator_free/models/language.dart';
import 'package:curriculator_free/models/personal_data.dart';
import 'package:curriculator_free/models/skill.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:isar/isar.dart';

// --- Camada de Dados (Repositório e Providers) ---

/// Agrupa todos os dados necessários para a tela de edição.
class VersionEditorDataBundle {
  final CurriculumVersion? versionToEdit;
  final PersonalData? personalData; // Precisamos dos dados pessoais para saber o que mostrar
  final List<Experience> allExperiences;
  final List<Education> allEducations;
  final List<Skill> allSkills;
  final List<Language> allLanguages;
  VersionEditorDataBundle({this.versionToEdit, this.personalData, required this.allExperiences, required this.allEducations, required this.allSkills, required this.allLanguages});
}

/// Provider para o repositório que contém a lógica de busca e salvamento.
final versionEditorRepositoryProvider = Provider((ref) {
  final isar = ref.watch(isarServiceProvider);
  return VersionEditorRepository(isar);
});

class VersionEditorRepository {
  final IsarService _isarService;
  VersionEditorRepository(this._isarService);

  /// Busca todos os dados necessários para popular a tela de edição.
  Future<VersionEditorDataBundle> fetchData(int? versionId) async {
    final isar = await _isarService.db;
    CurriculumVersion? version;

    if (versionId != null) {
      version = await isar.curriculumVersions.get(versionId);
      if (version != null) {
        // Carrega os dados linkados para saber o que já está selecionado.
        await Future.wait([
          version.experiences.load(),
          version.educations.load(),
          version.skills.load(),
          version.languages.load(),
        ]);
      }
    }

    // Busca todas as listas de dados mestres para exibir como opções.
    final allExperiences = await isar.experiences.where().sortByStartDateDesc().findAll();
    final allEducations = await isar.educations.where().sortByStartDateDesc().findAll();
    final allSkills = await isar.skills.where().sortByName().findAll();
    final allLanguages = await isar.languages.where().sortByLanguageName().findAll();

    return VersionEditorDataBundle(
      versionToEdit: version,
      allExperiences: allExperiences,
      allEducations: allEducations,
      allSkills: allSkills,
      allLanguages: allLanguages,
    );
  }

  /// Salva ou atualiza uma versão do currículo e seus links.
  Future<int> saveVersion({
    int? versionId,
    required String name,
    required Set<int> selectedExpIds,
    required Set<int> selectedEduIds,
    required Set<int> selectedSkillIds,
    required Set<int> selectedLangIds,
  }) async {
    final isar = await _isarService.db;

    // Se estiver editando, busca a versão. Se não encontrar, ou se estiver criando,
    // instancia uma nova.
    final version = versionId != null
        ? await isar.curriculumVersions.get(versionId)
        : null;

    final versionToSave = version ?? CurriculumVersion(); // Usa o construtor padrão
    versionToSave.name = name.trim();
    if(version == null) {
      versionToSave.createdAt = DateTime.now();
    }

    // Busca os objetos reais correspondentes aos IDs selecionados.
    final personalData = await isar.personalDatas.get(1);
    final selectedExperiences = await isar.experiences.getAll(selectedExpIds.toList());
    final selectedEducations = await isar.educations.getAll(selectedEduIds.toList());
    final selectedSkills = await isar.skills.getAll(selectedSkillIds.toList());
    final selectedLanguages = await isar.languages.getAll(selectedLangIds.toList());

    late int savedId;

    await isar.writeTxn(() async {
      // Associa os dados, limpando os links antigos e adicionando os novos.
      versionToSave.personalData.value = personalData;
      versionToSave.experiences.clear();
      versionToSave.experiences.addAll(selectedExperiences.whereType<Experience>());
      versionToSave.educations.clear();
      versionToSave.educations.addAll(selectedEducations.whereType<Education>());
      versionToSave.skills.clear();
      versionToSave.skills.addAll(selectedSkills.whereType<Skill>());
      versionToSave.languages.clear();
      versionToSave.languages.addAll(selectedLanguages.whereType<Language>());

      // Salva a versão principal e obtém seu ID.
      savedId = await isar.curriculumVersions.put(versionToSave);

      // Salva as mudanças nos IsarLinks.
      await Future.wait([
        versionToSave.personalData.save(),
        versionToSave.experiences.save(),
        versionToSave.educations.save(),
        versionToSave.skills.save(),
        versionToSave.languages.save(),
      ]);
    });

    return savedId;
  }
}

/// Provider que executa a busca dos dados para a tela.
final versionEditorDataProvider = FutureProvider.autoDispose.family<VersionEditorDataBundle, int?>((ref, versionId) {
  final repository = ref.watch(versionEditorRepositoryProvider);
  return repository.fetchData(versionId);
});


// --- UI Screen ---
class VersionEditorScreen extends ConsumerStatefulWidget {
  final int? versionId;
  const VersionEditorScreen({super.key, this.versionId});

  @override
  ConsumerState<VersionEditorScreen> createState() => _VersionEditorScreenState();
}

class _VersionEditorScreenState extends ConsumerState<VersionEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  final Set<int> _selectedExperienceIds = {};
  final Set<int> _selectedEducationIds = {};
  final Set<int> _selectedSkillIds = {};
  final Set<int> _selectedLanguageIds = {};

  // --- NOVOS ESTADOS PARA AS OPÇÕES ---
  bool _includeSummary = true;
  bool _includeAvailability = true;
  bool _includeVehicle = true;
  bool _includeLicense = true;
  bool _includeSocialLinks = true;
  bool _includePhoto = true;

  bool _isSaving = false;
  bool _isInitialDataLoaded = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (_isSaving) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);

    try {
      await ref.read(versionEditorRepositoryProvider).saveVersion(
        versionId: widget.versionId,
        name: _nameController.text.trim(),
        selectedExpIds: _selectedExperienceIds,
        selectedEduIds: _selectedEducationIds,
        selectedSkillIds: _selectedSkillIds,
        selectedLangIds: _selectedLanguageIds,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Versão salva com sucesso!'),
          backgroundColor: Colors.green,
        ));
        context.go('/');
      }

    } catch (e, stack) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Erro ao salvar a versão: $e'),
          backgroundColor: Colors.red,
        ));
      }
      debugPrintStack(stackTrace: stack, label: e.toString());
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncData = ref.watch(versionEditorDataProvider(widget.versionId));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.versionId == null ? 'Criar Nova Versão' : 'Editar Versão'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: FilledButton.icon(
              icon: _isSaving
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.save),
              label: const Text('Salvar'),
              onPressed: _isSaving ? null : _onSave,
            ),
          )
        ],
      ),
      body: asyncData.when(
        data: (bundle) {
          if (!_isInitialDataLoaded && bundle.versionToEdit != null) {
            final version = bundle.versionToEdit!;
            _nameController.text = version.name;
            _selectedExperienceIds.addAll(version.experiences.map((e) => e.id));
            _selectedEducationIds.addAll(version.educations.map((e) => e.id));
            _selectedSkillIds.addAll(version.skills.map((e) => e.id));
            _selectedLanguageIds.addAll(version.languages.map((e) => e.id));
            _isInitialDataLoaded = true;
          }

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome da Versão',
                    hintText: 'Ex: Currículo para Vaga de Flutter',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'O nome é obrigatório' : null,
                ),
                const SizedBox(height: 24),
                Text('Selecione os itens para incluir neste currículo:', style: Theme.of(context).textTheme.titleMedium),

                _buildSection<Experience>(
                    title: 'Experiências Profissionais', items: bundle.allExperiences,
                    selectedIds: _selectedExperienceIds, idAccessor: (item) => item.id,
                    displayBuilder: (exp) => ListTile(title: Text(exp.jobTitle), subtitle: Text(exp.company))),
                _buildSection<Education>(
                    title: 'Formação Acadêmica', items: bundle.allEducations,
                    selectedIds: _selectedEducationIds, idAccessor: (item) => item.id,
                  displayBuilder: (edu) => ListTile(
                    title: Text('${edu.degree} em ${edu.fieldOfStudy}'), // Mostra ambos os campos
                    subtitle: Text(edu.institution),
                  ),
                ),
                _buildSection<Skill>(
                    title: 'Habilidades', items: bundle.allSkills,
                    selectedIds: _selectedSkillIds, idAccessor: (item) => item.id,
                    displayBuilder: (skill) => ListTile(title: Text(skill.name))),
                _buildSection<Language>(
                    title: 'Idiomas', items: bundle.allLanguages,
                    selectedIds: _selectedLanguageIds, idAccessor: (item) => item.id,
                    displayBuilder: (lang) => ListTile(title: Text(lang.languageName))),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erro ao carregar dados: $err')),
      ),
    );
  }

  Widget _buildSection<T>({
    required String title,
    required List<T> items,
    required Set<int> selectedIds,
    required int Function(T item) idAccessor,
    required Widget Function(T item) displayBuilder,
  }) {
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Text('Nenhum item de "$title" cadastrado nas seções de dados.'),
      );
    }

    return ExpansionTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      initiallyExpanded: true,
      children: items.map((item) {
        final itemId = idAccessor(item);
        return CheckboxListTile(
          controlAffinity: ListTileControlAffinity.leading,
          title: displayBuilder(item),
          value: selectedIds.contains(itemId),
          onChanged: (isSelected) => setState(() => isSelected ?? false ? selectedIds.add(itemId) : selectedIds.remove(itemId)),
        );
      }).toList(),
    );
  }
}