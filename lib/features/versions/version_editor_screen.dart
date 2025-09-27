// C:\Users\ziofl\StudioProjects\curriculator_free\lib\features\versions\version_editor_screen.dart
import 'package:curriculator_free/features/versions/version_editor_repository.dart';
import 'package:curriculator_free/models/education.dart';
import 'package:curriculator_free/models/experience.dart';
import 'package:curriculator_free/models/language.dart';
import 'package:curriculator_free/models/skill.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// --- Provider que executa a busca dos dados para a tela. ---
// Usa o repositório importado.
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

  // --- ESTADOS PARA AS NOVAS OPÇÕES ---
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
      // CORREÇÃO: Passando todos os novos campos booleanos para o método saveVersion
      await ref.read(versionEditorRepositoryProvider).saveVersion(
        versionId: widget.versionId,
        name: _nameController.text.trim(),
        selectedExpIds: _selectedExperienceIds,
        selectedEduIds: _selectedEducationIds,
        selectedSkillIds: _selectedSkillIds,
        selectedLangIds: _selectedLanguageIds,
        includeSummary: _includeSummary,
        includeAvailability: _includeAvailability,
        includeVehicle: _includeVehicle,
        includeLicense: _includeLicense,
        includeSocialLinks: _includeSocialLinks,
        includePhoto: _includePhoto,
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
          // CORREÇÃO: Carregando os valores das novas opções booleanas
          if (!_isInitialDataLoaded) {
            final version = bundle.versionToEdit;
            if (version != null) {
              _nameController.text = version.name;
              _selectedExperienceIds.addAll(version.experiences.map((e) => e.id));
              _selectedEducationIds.addAll(version.educations.map((e) => e.id));
              _selectedSkillIds.addAll(version.skills.map((e) => e.id));
              _selectedLanguageIds.addAll(version.languages.map((e) => e.id));

              // Carregando os novos campos
              _includeSummary = version.includeSummary;
              _includeAvailability = version.includeAvailability;
              _includeVehicle = version.includeVehicle;
              _includeLicense = version.includeLicense;
              _includeSocialLinks = version.includeSocialLinks;
              _includePhoto = version.includePhoto;
            }
            // Marcamos como carregado mesmo se a versão for nula (criação)
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
                Text('Opções de Inclusão', style: Theme.of(context).textTheme.titleMedium),
                SwitchListTile(title: const Text('Resumo Profissional'), value: _includeSummary, onChanged: (v) => setState(() => _includeSummary = v)),
                SwitchListTile(title: const Text('Disponibilidades'), value: _includeAvailability, onChanged: (v) => setState(() => _includeAvailability = v)),
                SwitchListTile(title: const Text('Veículo Próprio'), value: _includeVehicle, onChanged: (v) => setState(() => _includeVehicle = v)),
                SwitchListTile(title: const Text('Carteira de Habilitação'), value: _includeLicense, onChanged: (v) => setState(() => _includeLicense = v)),
                SwitchListTile(title: const Text('Links Sociais'), value: _includeSocialLinks, onChanged: (v) => setState(() => _includeSocialLinks = v)),
                SwitchListTile(title: const Text('Foto'), value: _includePhoto, onChanged: (v) => setState(() => _includePhoto = v)),

                const Divider(height: 32),

                Text('Selecione os itens para incluir neste currículo:', style: Theme.of(context).textTheme.titleMedium),

                _buildSection<Experience>(
                    title: 'Experiências Profissionais', items: bundle.allExperiences,
                    selectedIds: _selectedExperienceIds, idAccessor: (item) => item.id,
                    displayBuilder: (exp) => ListTile(title: Text(exp.jobTitle), subtitle: Text(exp.company))),
                _buildSection<Education>(
                  title: 'Formação Acadêmica', items: bundle.allEducations,
                  selectedIds: _selectedEducationIds, idAccessor: (item) => item.id,
                  displayBuilder: (edu) => ListTile(
                    title: Text('${edu.degree} em ${edu.fieldOfStudy}'),
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