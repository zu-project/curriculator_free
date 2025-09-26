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
// --- CORREÇÃO: Adiciona a importação principal do Isar ---
import 'package:isar/isar.dart';

// --- Data Layer (Repositório e Providers) ---
class VersionEditorDataBundle {
  final CurriculumVersion? versionToEdit;
  final List<Experience> allExperiences;
  final List<Education> allEducations;
  final List<Skill> allSkills;
  final List<Language> allLanguages;
  VersionEditorDataBundle({ this.versionToEdit, required this.allExperiences, required this.allEducations, required this.allSkills, required this.allLanguages});
}

final versionEditorRepositoryProvider = Provider((ref) {
  final isar = ref.watch(isarServiceProvider);
  return VersionEditorRepository(isar);
});

class VersionEditorRepository {
  final IsarService _isarService;
  VersionEditorRepository(this._isarService);

  Future<VersionEditorDataBundle> fetchData(int? versionId) async {
    final isar = await _isarService.db;
    CurriculumVersion? version;

    if (versionId != null) {
      version = await isar.curriculumVersions.get(versionId);
      if (version != null) {
        await Future.wait([
          version.experiences.load(),
          version.educations.load(),
          version.skills.load(),
          version.languages.load(),
        ]);
      }
    }

    // --- CORREÇÃO: Busca sequencial para garantir os tipos corretos ---
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

  Future<void> saveVersion({
    int? versionId,
    required String name,
    required Set<int> selectedExpIds,
    required Set<int> selectedEduIds,
    required Set<int> selectedSkillIds,
    required Set<int> selectedLangIds,
  }) async {
    final isar = await _isarService.db;

    final version = versionId != null
        ? await isar.curriculumVersions.get(versionId) ?? CurriculumVersion(name: name, createdAt: DateTime.now())
        : CurriculumVersion(name: name, createdAt: DateTime.now());

    version.name = name;

    final personalData = await isar.personalDatas.get(1);
    final selectedExperiences = await isar.experiences.getAll(selectedExpIds.toList());
    final selectedEducations = await isar.educations.getAll(selectedEduIds.toList());
    final selectedSkills = await isar.skills.getAll(selectedSkillIds.toList());
    final selectedLanguages = await isar.languages.getAll(selectedLangIds.toList());

    await isar.writeTxn(() async {
      version.personalData.value = personalData;
      version.experiences.clear();
      // --- CORREÇÃO: Filtra nulos que podem vir do .getAll() ---
      version.experiences.addAll(selectedExperiences.whereType<Experience>());
      version.educations.clear();
      version.educations.addAll(selectedEducations.whereType<Education>());
      version.skills.clear();
      version.skills.addAll(selectedSkills.whereType<Skill>());
      version.languages.clear();
      version.languages.addAll(selectedLanguages.whereType<Language>());

      await isar.curriculumVersions.put(version);

      await Future.wait([
        version.personalData.save(),
        version.experiences.save(),
        version.educations.save(),
        version.skills.save(),
        version.languages.save(),
      ]);
    });
  }
}

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

  void _onSave() async {
    if (_isSaving) return;
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isSaving = true);
      try {
        await ref.read(versionEditorRepositoryProvider).saveVersion(
            versionId: widget.versionId, name: _nameController.text.trim(),
            selectedExpIds: _selectedExperienceIds, selectedEduIds: _selectedEducationIds,
            selectedSkillIds: _selectedSkillIds, selectedLangIds: _selectedLanguageIds);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Versão salva com sucesso!'), backgroundColor: Colors.green));
          context.pop();
        }
      } catch (e) {
        if (mounted) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao salvar: $e'), backgroundColor: Colors.red));}
      } finally {
        if (mounted) { setState(() => _isSaving = false); }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncData = ref.watch(versionEditorDataProvider(widget.versionId));
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.versionId == null ? 'Criar Nova Versão' : 'Editar Versão'),
        actions: [ Padding( padding: const EdgeInsets.only(right: 16.0), child: FilledButton.icon(
            icon: _isSaving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.save),
            label: const Text('Salvar'), onPressed: _onSave),)
        ],
      ),
      body: asyncData.when(
        data: (bundle) {
          if (!_isInitialDataLoaded && widget.versionId != null && bundle.versionToEdit != null) {
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
            child: ListView( padding: const EdgeInsets.all(16.0), children: [
              TextFormField( controller: _nameController, decoration: const InputDecoration( labelText: 'Nome da Versão', hintText: 'Ex: Currículo para Vaga de Flutter', border: OutlineInputBorder()),
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'O nome é obrigatório' : null),
              const SizedBox(height: 24),
              Text('Selecione os itens que farão parte deste currículo:', style: Theme.of(context).textTheme.titleMedium),

              // --- CORREÇÃO: Passando o 'idAccessor' ---
              _buildSection<Experience>(
                  title: 'Experiências Profissionais', items: bundle.allExperiences,
                  selectedIds: _selectedExperienceIds, idAccessor: (item) => item.id,
                  displayBuilder: (exp) => ListTile(title: Text(exp.jobTitle ?? ''), subtitle: Text(exp.company ?? ''))),
              _buildSection<Education>(
                  title: 'Formação Acadêmica', items: bundle.allEducations,
                  selectedIds: _selectedEducationIds, idAccessor: (item) => item.id,
                  displayBuilder: (edu) => ListTile(title: Text(edu.degree ?? ''), subtitle: Text(edu.institution ?? ''))),
              _buildSection<Skill>(
                  title: 'Habilidades', items: bundle.allSkills,
                  selectedIds: _selectedSkillIds, idAccessor: (item) => item.id,
                  displayBuilder: (skill) => ListTile(title: Text(skill.name ?? ''))),
              _buildSection<Language>(
                  title: 'Idiomas', items: bundle.allLanguages,
                  selectedIds: _selectedLanguageIds, idAccessor: (item) => item.id,
                  displayBuilder: (lang) => ListTile(title: Text(lang.languageName ?? ''))),
            ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erro ao carregar dados: $err')),
      ),
    );
  }

  // --- CORREÇÃO: O 'T' genérico é mantido, mas não estende mais IsarGeneratedObject,
  // pois não usamos isso. Em vez disso, recebemos uma função que sabe como obter o ID.
  Widget _buildSection<T>({
    required String title,
    required List<T> items,
    required Set<int> selectedIds,
    required int Function(T item) idAccessor, // Função para obter o ID do item
    required Widget Function(T item) displayBuilder,
  }) {
    if (items.isEmpty) {
      return Padding( padding: const EdgeInsets.symmetric(vertical: 16.0), child: Text('Nenhum item de "$title" cadastrado.'));
    }

    return ExpansionTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      initiallyExpanded: true,
      children: items.map((item) {
        // --- CORREÇÃO: Usa o 'idAccessor' para obter o ID de forma segura ---
        final itemId = idAccessor(item);
        return CheckboxListTile(
          controlAffinity: ListTileControlAffinity.leading,
          title: displayBuilder(item),
          value: selectedIds.contains(itemId),
          onChanged: (isSelected) {
            setState(() {
              if (isSelected ?? false) { selectedIds.add(itemId); }
              else { selectedIds.remove(itemId); }
            });
          },
        );
      }).toList(),
    );
  }
}