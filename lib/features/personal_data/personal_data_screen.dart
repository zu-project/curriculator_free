import 'package:curriculator_free/core/services/isar_service.dart';
import 'package:curriculator_free/models/personal_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';

// --- Providers, Notifier e Repository (Sem alterações aqui) ---
final personalDataRepositoryProvider = Provider<PersonalDataRepository>((ref) {
  final isarService = ref.watch(isarServiceProvider);
  return PersonalDataRepository(isarService);
});

final personalDataNotifierProvider =
StateNotifierProvider.autoDispose<PersonalDataNotifier, AsyncValue<PersonalData?>>(
      (ref) {
    final repository = ref.watch(personalDataRepositoryProvider);
    return PersonalDataNotifier(repository);
  },
);

class PersonalDataNotifier extends StateNotifier<AsyncValue<PersonalData?>> {
  final PersonalDataRepository _repository;
  PersonalDataNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadPersonalData();
  }
  Future<void> loadPersonalData() async {
    try {
      state = const AsyncValue.loading();
      final data = await _repository.getPersonalData();
      state = AsyncValue.data(data);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  Future<bool> savePersonalData(PersonalData data) async {
    try {
      state = AsyncValue.data(data);
      await _repository.savePersonalData(data);
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }
}

class PersonalDataRepository {
  final IsarService _isarService;
  static const int fixedId = 1;
  PersonalDataRepository(this._isarService);
  Future<PersonalData?> getPersonalData() async {
    final isar = await _isarService.db;
    return isar.personalDatas.get(fixedId);
  }
  Future<void> savePersonalData(PersonalData data) async {
    final isar = await _isarService.db;
    await isar.writeTxn(() async {
      data.id = fixedId;
      await isar.personalDatas.put(data);
    });
  }
}

// --- Tela Principal (UI com Alterações) ---

class PersonalDataScreen extends ConsumerStatefulWidget {
  const PersonalDataScreen({super.key});

  @override
  ConsumerState<PersonalDataScreen> createState() => _PersonalDataScreenState();
}

class _PersonalDataScreenState extends ConsumerState<PersonalDataScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers para os campos de texto existentes
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  //... (outros controllers)
  late final TextEditingController _phoneController, _addressController, _linkedinController, _portfolioController, _summaryController;

  // --- NOVAS VARIÁVEIS DE ESTADO ---
  DateTime? _birthDate;
  bool _travelAvailability = false;
  bool _relocationAvailability = false;
  bool _hasCar = false;
  bool _hasMotorcycle = false;
  final Set<String> _selectedLicenseCategories = {};
  final List<String> _allLicenseCategories = ['A', 'B', 'C', 'D', 'E', 'AB', 'AC', 'AD', 'AE'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
    _linkedinController = TextEditingController();
    _portfolioController = TextEditingController();
    _summaryController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _linkedinController.dispose();
    _portfolioController.dispose();
    _summaryController.dispose();
    super.dispose();
  }

  // Função atualizada para popular TODOS os campos do formulário
  void _populateFormFields(PersonalData? data) {
    if (data != null) {
      // Campos de texto existentes
      _nameController.text = data.name ?? '';
      _emailController.text = data.email ?? '';
      _phoneController.text = data.phone ?? '';
      _addressController.text = data.address ?? '';
      _linkedinController.text = data.linkedinUrl ?? '';
      _portfolioController.text = data.portfolioUrl ?? '';
      _summaryController.text = data.summary ?? '';

      // --- POPULANDO NOVOS CAMPOS ---
      setState(() {
        _birthDate = data.birthDate;
        _travelAvailability = data.hasTravelAvailability;
        _relocationAvailability = data.hasRelocationAvailability;
        _hasCar = data.hasCar;
        _hasMotorcycle = data.hasMotorcycle;
        _selectedLicenseCategories.clear();
        _selectedLicenseCategories.addAll(data.licenseCategories);
      });
    }
  }

  // Função atualizada para salvar TODOS os campos
  Future<void> _onSave() async {
    if (_formKey.currentState?.validate() ?? false) {
      final currentData = ref.read(personalDataNotifierProvider).valueOrNull;
      final dataToSave = (currentData ?? PersonalData())
      // Dados existentes
        ..name = _nameController.text.trim()
        ..email = _emailController.text.trim()
        ..phone = _phoneController.text.trim()
        ..address = _addressController.text.trim()
        ..linkedinUrl = _linkedinController.text.trim()
        ..portfolioUrl = _portfolioController.text.trim()
        ..summary = _summaryController.text.trim()
      // --- SALVANDO NOVOS DADOS ---
        ..birthDate = _birthDate
        ..hasTravelAvailability = _travelAvailability
        ..hasRelocationAvailability = _relocationAvailability
        ..hasCar = _hasCar
        ..hasMotorcycle = _hasMotorcycle
        ..licenseCategories = _selectedLicenseCategories.toList();

      final success = await ref
          .read(personalDataNotifierProvider.notifier)
          .savePersonalData(dataToSave);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Dados salvos com sucesso!' : 'Erro ao salvar.'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  // --- NOVA FUNÇÃO ---
  // Função para abrir o seletor de data de nascimento
  Future<void> _selectBirthDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(2000), // Começa no ano 2000 se não houver data
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _birthDate) {
      setState(() {
        _birthDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<PersonalData?>>(personalDataNotifierProvider,
            (_, state) => state.whenData((data) => _populateFormFields(data)));
    final state = ref.watch(personalDataNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Dados Pessoais'),
        actions: [Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: FilledButton.icon(
            icon: const Icon(Icons.save_alt_outlined),
            label: const Text('Salvar'),
            onPressed: state.isLoading ? null : _onSave,
          ),
        )],
      ),
      body: state.when(
        data: (data) => _buildForm(),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Erro ao carregar dados: $error')),
      ),
    );
  }

  Widget _buildForm() {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Form(key: _formKey,
      child: SingleChildScrollView(padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 700),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              _buildTextField(/*...*/ name: 'Nome Completo', controller: _nameController, hint: '', isRequired: true),
              _buildTextField(/*...*/ name: 'E-mail', controller: _emailController, hint: '', isRequired: true, isEmail: true),
              _buildTextField(/*...*/ name: 'Telefone', controller: _phoneController, hint: ''),
              _buildTextField(/*...*/ name: 'Endereço', controller: _addressController, hint: 'Ex: Cidade, Estado'),
              const Divider(height: 32),

              // --- NOVO WIDGET: SELETOR DE DATA ---
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Data de Nascimento'),
                subtitle: Text(_birthDate == null ? 'Não informada' : dateFormat.format(_birthDate!)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectBirthDate(context),
              ),
              const Divider(height: 32),

              // --- NOVOS WIDGETS: SWITCHES ---
              SwitchListTile(
                title: const Text('Disponibilidade para viagens'),
                value: _travelAvailability,
                onChanged: (value) => setState(() => _travelAvailability = value),
              ),
              SwitchListTile(
                title: const Text('Disponibilidade para mudança'),
                value: _relocationAvailability,
                onChanged: (value) => setState(() => _relocationAvailability = value),
              ),
              const Divider(height: 32),

              // --- NOVOS WIDGETS: CHECKBOXES ---
              CheckboxListTile(
                title: const Text('Possui veículo próprio (Carro)'),
                value: _hasCar,
                onChanged: (value) => setState(() => _hasCar = value ?? false),
              ),
              CheckboxListTile(
                title: const Text('Possui veículo próprio (Moto)'),
                value: _hasMotorcycle,
                onChanged: (value) => setState(() => _hasMotorcycle = value ?? false),
              ),
              const Divider(height: 32),

              // --- NOVO WIDGET: CHIPS DE HABILITAÇÃO ---
              Text('Carteira de Habilitação', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                children: _allLicenseCategories.map((category) => FilterChip(
                  label: Text(category),
                  selected: _selectedLicenseCategories.contains(category),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedLicenseCategories.add(category);
                      } else {
                        _selectedLicenseCategories.remove(category);
                      }
                    });
                  },
                )).toList(),
              ),

              const Divider(height: 32),
              _buildTextField(/*...*/ name: 'Perfil do LinkedIn', controller: _linkedinController, hint: ''),
              _buildTextField(/*...*/ name: 'Portfólio ou Site Pessoal', controller: _portfolioController, hint: ''),
              _buildTextField(/*...*/ name: 'Resumo Profissional', controller: _summaryController, hint: '', maxLines: 5),
            ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget auxiliar refatorado para simplicidade
  Widget _buildTextField({
    required TextEditingController controller,
    required String name,
    required String hint,
    int? maxLines = 1,
    bool isRequired = false,
    bool isEmail = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: name,
          hintText: hint,
          border: const OutlineInputBorder(),
          alignLabelWithHint: true,
        ),
        validator: (value) {
          if (isRequired && (value == null || value.trim().isEmpty)) {
            return 'O campo "$name" é obrigatório.';
          }
          if (isEmail && value != null && value.isNotEmpty) {
            final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
            if (!emailRegex.hasMatch(value)) {
              return 'Formato de e-mail inválido.';
            }
          }
          return null;
        },
      ),
    );
  }
}