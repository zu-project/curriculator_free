import 'dart:io';

import 'package:curriculator_free/core/services/isar_service.dart';
import 'package:curriculator_free/models/personal_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

// --- Camada de Dados e Lógica ---

// Repositório que centraliza o acesso aos dados pessoais
final personalDataRepositoryProvider = Provider((ref) {
  return PersonalDataRepository(ref.watch(isarServiceProvider));
});

class PersonalDataRepository {
  final IsarService _isarService;
  static const int _fixedId = 1;

  PersonalDataRepository(this._isarService);

  Future<PersonalData?> getPersonalData() async {
    final isar = await _isarService.db;
    return isar.personalDatas.get(_fixedId);
  }

  Future<void> savePersonalData(PersonalData data) async {
    final isar = await _isarService.db;
    await isar.writeTxn(() => isar.personalDatas.put(data..id = _fixedId));
  }
}

// FutureProvider para carregar os dados de forma assíncrona
final personalDataProvider = FutureProvider.autoDispose<PersonalData?>((ref) {
  return ref.watch(personalDataRepositoryProvider).getPersonalData();
});

// --- Tela Principal (UI) ---
class PersonalDataScreen extends ConsumerStatefulWidget {
  const PersonalDataScreen({super.key});

  @override
  ConsumerState<PersonalDataScreen> createState() => _PersonalDataScreenState();
}

class _PersonalDataScreenState extends ConsumerState<PersonalDataScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers para os campos de texto
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _portfolioController = TextEditingController();
  final _summaryController = TextEditingController();

  // Variáveis de estado para os outros campos
  String? _photoPath;
  DateTime? _birthDate;
  bool _travelAvailability = false;
  bool _relocationAvailability = false;
  bool _hasCar = false;
  bool _hasMotorcycle = false;
  final Set<String> _selectedLicenseCategories = {};

  final ImagePicker _picker = ImagePicker();
  final List<String> _allLicenseCategories = ['A', 'B', 'C', 'D', 'E', 'AB', 'AC', 'AD', 'AE'];

  // Flag para controlar se houve mudanças no formulário
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    // Preenche o formulário com os dados iniciais
    ref.read(personalDataProvider.future).then((data) {
      if (mounted && data != null) {
        _populateFormFields(data);
      }
    });
    // Adiciona listeners para detectar mudanças
    _addAllListeners();
  }

  @override
  void dispose() {
    _removeAllListeners();
    _nameController.dispose(); _emailController.dispose(); _phoneController.dispose();
    _addressController.dispose(); _linkedinController.dispose(); _portfolioController.dispose();
    _summaryController.dispose();
    super.dispose();
  }

  void _populateFormFields(PersonalData data) {
    _nameController.text = data.name;
    _emailController.text = data.email;
    _phoneController.text = data.phone ?? '';
    _addressController.text = data.address ?? '';
    _linkedinController.text = data.linkedinUrl ?? '';
    _portfolioController.text = data.portfolioUrl ?? '';
    _summaryController.text = data.summary ?? '';

    setState(() {
      _photoPath = data.photoPath;
      _birthDate = data.birthDate;
      _travelAvailability = data.hasTravelAvailability;
      _relocationAvailability = data.hasRelocationAvailability;
      _hasCar = data.hasCar;
      _hasMotorcycle = data.hasMotorcycle;
      _selectedLicenseCategories.clear();
      _selectedLicenseCategories.addAll(data.licenseCategories);
    });
  }

  void _onSave() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Cria o objeto com os dados atuais do formulário
      final dataToSave = PersonalData()
        ..name = _nameController.text.trim()
        ..email = _emailController.text.trim()
        ..phone = _phoneController.text.trim()
        ..address = _addressController.text.trim()
        ..linkedinUrl = _linkedinController.text.trim()
        ..portfolioUrl = _portfolioController.text.trim()
        ..summary = _summaryController.text.trim()
        ..photoPath = _photoPath
        ..birthDate = _birthDate
        ..hasTravelAvailability = _travelAvailability
        ..hasRelocationAvailability = _relocationAvailability
        ..hasCar = _hasCar
        ..hasMotorcycle = _hasMotorcycle
        ..licenseCategories = _selectedLicenseCategories.toList();

      try {
        await ref.read(personalDataRepositoryProvider).savePersonalData(dataToSave);
        ref.invalidate(personalDataProvider); // Invalida o cache para forçar a releitura
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Dados pessoais salvos com sucesso!'),
            backgroundColor: Colors.green,
          ));
          setState(() => _hasChanges = false); // Reseta o estado de "mudanças"
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Erro ao salvar os dados: $e'),
            backgroundColor: Colors.red,
          ));
        }
      }
    }
  }

  Future<void> _pickImage() async { /* ... (código inalterado) ... */ }
  Future<void> _selectBirthDate(BuildContext context) async { /* ... (código inalterado) ... */ }

  void _onChanged() => setState(() => _hasChanges = true);
  void _addAllListeners() {
    _nameController.addListener(_onChanged); _emailController.addListener(_onChanged);
    _phoneController.addListener(_onChanged); _addressController.addListener(_onChanged);
    _linkedinController.addListener(_onChanged); _portfolioController.addListener(_onChanged);
    _summaryController.addListener(_onChanged);
  }
  void _removeAllListeners() {
    _nameController.removeListener(_onChanged); _emailController.removeListener(_onChanged);
    _phoneController.removeListener(_onChanged); _addressController.removeListener(_onChanged);
    _linkedinController.removeListener(_onChanged); _portfolioController.removeListener(_onChanged);
    _summaryController.removeListener(_onChanged);
  }

  @override
  Widget build(BuildContext context) {
    final asyncData = ref.watch(personalDataProvider);
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      floatingActionButton: _hasChanges ? FloatingActionButton.extended(
        icon: const Icon(Icons.save),
        label: const Text('Salvar Alterações'),
        onPressed: _onSave,
      ) : null,
      body: asyncData.when(
        data: (data) => Padding(
          padding: const EdgeInsets.only(top: 24.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  children: [
                    // Seção da Foto
                    _buildPhotoSection(),
                    const Divider(height: 48),

                    // Seção de Informações Básicas
                    _buildSectionTitle('Informações de Contato'),
                    _buildTextField(controller: _nameController, labelText: 'Nome Completo', isRequired: true),
                    _buildTextField(controller: _emailController, labelText: 'E-mail', isRequired: true, keyboardType: TextInputType.emailAddress, isEmail: true),
                    _buildTextField(controller: _phoneController, labelText: 'Telefone', keyboardType: TextInputType.phone),
                    _buildTextField(controller: _addressController, labelText: 'Endereço (Cidade, Estado)'),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Data de Nascimento'),
                      subtitle: Text(_birthDate == null ? 'Não informada' : dateFormat.format(_birthDate!)),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final picked = await showDatePicker(context: context, initialDate: _birthDate ?? DateTime(2000), firstDate: DateTime(1940), lastDate: DateTime.now());
                        if (picked != null && picked != _birthDate) {
                          setState(() { _birthDate = picked; _onChanged(); });
                        }
                      },
                    ),
                    const Divider(height: 48),

                    // Seção de Links
                    _buildSectionTitle('Links Profissionais'),
                    _buildTextField(controller: _linkedinController, labelText: 'Perfil do LinkedIn', keyboardType: TextInputType.url),
                    _buildTextField(controller: _portfolioController, labelText: 'Portfólio ou GitHub', keyboardType: TextInputType.url),
                    const Divider(height: 48),

                    // Seção de Disponibilidade e Veículos
                    _buildSectionTitle('Disponibilidade e Outros'),
                    SwitchListTile(title: const Text('Disponibilidade para viagens'), value: _travelAvailability, onChanged: (v) => setState(() { _travelAvailability = v; _onChanged(); })),
                    SwitchListTile(title: const Text('Disponibilidade para mudança'), value: _relocationAvailability, onChanged: (v) => setState(() { _relocationAvailability = v; _onChanged(); })),
                    const SizedBox(height: 16),
                    CheckboxListTile(title: const Text('Possui veículo próprio (Carro)'), value: _hasCar, onChanged: (v) => setState(() { _hasCar = v ?? false; _onChanged(); })),
                    CheckboxListTile(title: const Text('Possui veículo próprio (Moto)'), value: _hasMotorcycle, onChanged: (v) => setState(() { _hasMotorcycle = v ?? false; _onChanged(); })),
                    const SizedBox(height: 16),

                    // Seção CNH
                    Text('Carteira de Habilitação', style: Theme.of(context).textTheme.bodyLarge),
                    Wrap(spacing: 8.0,
                      children: _allLicenseCategories.map((cat) => FilterChip(
                        label: Text(cat),
                        selected: _selectedLicenseCategories.contains(cat),
                        onSelected: (sel) => setState(() {
                          if (sel) { _selectedLicenseCategories.add(cat); }
                          else { _selectedLicenseCategories.remove(cat); }
                          _onChanged();
                        }),
                      )).toList(),
                    ),
                    const Divider(height: 48),

                    // Seção Resumo
                    _buildSectionTitle('Resumo Profissional'),
                    _buildTextField(controller: _summaryController, labelText: 'Seu resumo...', maxLines: 6),
                    const SizedBox(height: 80), // Espaço para o FAB não cobrir
                  ],
                ),
              ),
            ),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Erro ao carregar dados: $error')),
      ),
    );
  }

  // --- Widgets Auxiliares ---

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
    );
  }

  Widget _buildPhotoSection() {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            backgroundImage: _photoPath != null ? FileImage(File(_photoPath!)) : null,
            child: _photoPath == null ? Icon(Icons.person, size: 60, color: Theme.of(context).colorScheme.onPrimaryContainer) : null,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.upload_file),
                label: const Text('Selecionar Foto'),
                onPressed: () async {
                  final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    setState(() { _photoPath = image.path; _onChanged(); });
                  }
                },
              ),
              if (_photoPath != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: Theme.of(context).colorScheme.error,
                  tooltip: 'Remover Foto',
                  onPressed: () => setState(() { _photoPath = null; _onChanged(); }),
                )
              ],
            ],
          )
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller, required String labelText,
    int? maxLines = 1, TextInputType? keyboardType, bool isRequired = false, bool isEmail = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: TextFormField(
        controller: controller, maxLines: maxLines, keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: labelText, border: const OutlineInputBorder(),
          alignLabelWithHint: true,
        ),
        validator: (value) {
          if (isRequired && (value == null || value.trim().isEmpty)) {
            return 'Este campo é obrigatório.';
          }
          if (isEmail && value != null && value.isNotEmpty && !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
            return 'Formato de e-mail inválido.';
          }
          return null;
        },
      ),
    );
  }
}