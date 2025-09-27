// C:\Users\ziofl\StudioProjects\curriculator_free\lib\features\export\export_screen.dart
import 'dart:typed_data';

import 'package:curriculator_free/core/services/isar_service.dart';
import 'package:curriculator_free/features/export/pdf_generator_service.dart';
import 'package:curriculator_free/models/curriculum_version.dart';
import 'package:curriculator_free/models/personal_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:flutter/services.dart';

// --- Camada de Dados (Provider Corrigido) ---
class ExportScreenData {
  final CurriculumVersion version;
  final CurriculumDataBundle dataBundle;
  ExportScreenData(this.version, this.dataBundle);
}

final exportScreenDataProvider =
FutureProvider.family.autoDispose<ExportScreenData, int>((ref, versionId) async {
  final isar = await ref.watch(isarDbProvider.future);

  final version = await isar.curriculumVersions.get(versionId);
  if (version == null) throw Exception('Versão do currículo não encontrada!');

  // Carrega todos os links
  await Future.wait([
    version.personalData.load(),
    version.experiences.load(),
    version.educations.load(),
    version.skills.load(),
    version.languages.load(),
  ]);

  final dataBundle = CurriculumDataBundle(
    personalData: version.personalData.value,
    experiences: version.experiences.toList(),
    educations: version.educations.toList(),
    skills: version.skills.toList(),
    languages: version.languages.toList(),
  );

  return ExportScreenData(version, dataBundle);
});


class ExportScreen extends ConsumerStatefulWidget {
  final int versionId;
  const ExportScreen({super.key, required this.versionId});

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  // Estado local para os controles de customização
  String _selectedTemplate = 'Clássico';
  double _fontSize = 10.0;
  String _marginPreset = 'Normal'; // RESTAURADO
  Color _accentColor = Colors.deepPurple;
  bool _includePhoto = true;
  bool _includeSummary = true;
  bool _includeAvailability = true;
  bool _includeVehicle = true;
  bool _includeLicense = true;
  bool _includeSocialLinks = true;

  Key _pdfPreviewKey = UniqueKey();
  bool _initialDataLoaded = false;

  void _updatePreview() => setState(() => _pdfPreviewKey = UniqueKey());

  void _loadSavedOptions(CurriculumVersion version) {
    setState(() {
      _selectedTemplate = version.lastUsedTemplate ?? 'Clássico';
      _fontSize = version.fontSize ?? 10.0;
      if (version.accentColorHex != null) {
        try {
          _accentColor = Color(int.parse(version.accentColorHex!.replaceAll('#', '0xFF')));
        } catch (e) {
          _accentColor = Colors.deepPurple;
        }
      }
      _includePhoto = version.includePhoto;
      _includeSummary = version.includeSummary;
      _includeAvailability = version.includeAvailability;
      _includeVehicle = version.includeVehicle;
      _includeLicense = version.includeLicense;
      _includeSocialLinks = version.includeSocialLinks;
      _initialDataLoaded = true;
    });
  }

  Future<Uint8List> _generatePdfBytes(CurriculumDataBundle data) {
    final pdfOptions = PdfExportOptions(
      templateName: _selectedTemplate,
      baseFontSize: _fontSize,
      marginPreset: _marginPreset,
      accentColor: PdfColor.fromInt(_accentColor.value),
      includePhoto: _includePhoto,
      includeSummary: _includeSummary,
      includeAvailability: _includeAvailability,
      includeVehicle: _includeVehicle,
      includeLicense: _includeLicense,
      includeSocialLinks: _includeSocialLinks,
    );

    final generator = PdfGeneratorService(data, pdfOptions);
    return generator.generatePdf();
  }

  @override
  Widget build(BuildContext context) {
    final asyncData = ref.watch(exportScreenDataProvider(widget.versionId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        // CORRIGIDO: Adicionado título "Exportar" e o nome da versão.
        title: Text('Exportar: ${asyncData.valueOrNull?.version.name ?? ''}'),
      ),
      body: asyncData.when(
        data: (exportData) {
          if (!_initialDataLoaded) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _loadSavedOptions(exportData.version);
            });
          }

          return Row(
            children: [
              SizedBox(width: 320, child: _buildControlsPanel(exportData.dataBundle.personalData)),
              const VerticalDivider(width: 1),
              Expanded(
                child: PdfPreview(
                  key: _pdfPreviewKey,
                  build: (format) => _generatePdfBytes(exportData.dataBundle),
                  useActions: true,
                  canChangeOrientation: false,
                  canChangePageFormat: false,
                  canDebug: false,
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Erro ao carregar dados da versão: $error'),
            )),
      ),
    );
  }

  // PAINEL DE CONTROLES COMPLETAMENTE RESTAURADO E MELHORADO
  Widget _buildControlsPanel(PersonalData? pData) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Aparência', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            value: _selectedTemplate,
            decoration: const InputDecoration(labelText: 'Template', border: OutlineInputBorder()),
            // Adicionados todos os templates
            items: ['Clássico', 'Moderno', 'Funcional', 'Minimalista']
                .map((i) => DropdownMenuItem(value: i, child: Text(i)))
                .toList(),
            onChanged: (v) {
              if (v != null) {
                setState(() => _selectedTemplate = v);
                _updatePreview();
              }
            },
          ),
          const SizedBox(height: 20),

          DropdownButtonFormField<String>(
            value: _marginPreset,
            decoration: const InputDecoration(labelText: 'Margens', border: OutlineInputBorder()),
            items: ['Normal', 'Estreita', 'Larga']
                .map((i) => DropdownMenuItem(value: i, child: Text(i)))
                .toList(),
            onChanged: (v) {
              if (v != null) {
                setState(() => _marginPreset = v);
                _updatePreview();
              }
            },
          ),

          const SizedBox(height: 20),
          Text('Tamanho da Fonte (${_fontSize.toStringAsFixed(0)})'),
          Slider(
            value: _fontSize,
            min: 8,
            max: 14,
            divisions: 6,
            label: _fontSize.round().toString(),
            onChanged: (v) => setState(() => _fontSize = v),
            onChangeEnd: (_) => _updatePreview(),
          ),
          const SizedBox(height: 16),

          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Cor de Destaque'),
            trailing: CircleAvatar(backgroundColor: _accentColor, radius: 14),
            onTap: _showColorPicker,
          ),
          const Divider(height: 48),

          Text('Incluir no Currículo', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          _buildToggle(title: 'Foto', value: _includePhoto, enabled: pData?.photoPath?.isNotEmpty ?? false, onChanged: (v) => _includePhoto = v),
          _buildToggle(title: 'Resumo Profissional', value: _includeSummary, enabled: pData?.summary?.isNotEmpty ?? false, onChanged: (v) => _includeSummary = v),
          _buildToggle(title: 'Disponibilidades', value: _includeAvailability, onChanged: (v) => _includeAvailability = v),
          _buildToggle(title: 'Veículo Próprio', value: _includeVehicle, enabled: (pData?.hasCar ?? false) || (pData?.hasMotorcycle ?? false), onChanged: (v) => _includeVehicle = v),
          _buildToggle(title: 'Carteira de Habilitação', value: _includeLicense, enabled: pData?.licenseCategories.isNotEmpty ?? false, onChanged: (v) => _includeLicense = v),
          _buildToggle(title: 'Links Sociais', value: _includeSocialLinks, enabled: (pData?.linkedinUrl?.isNotEmpty??false) || (pData?.portfolioUrl?.isNotEmpty??false), onChanged: (v) => _includeSocialLinks = v),
        ],
      ),
    );
  }

  // Widget auxiliar para criar os toggles, desabilitando se não houver dados
  Widget _buildToggle({required String title, required bool value, bool enabled = true, required Function(bool) onChanged}) {
    return SwitchListTile(
      title: Text(title, style: TextStyle(color: enabled ? null : Colors.grey)),
      value: value,
      onChanged: enabled ? (v) {
        setState(() => onChanged(v));
        _updatePreview();
      } : null,
    );
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Selecione uma cor'),
        content: SingleChildScrollView(child: BlockPicker(pickerColor: _accentColor, onColorChanged: (c) => setState(() => _accentColor = c))),
        actions: [ElevatedButton(child: const Text('OK'), onPressed: () { Navigator.of(context).pop(); _updatePreview(); })],
      ),
    );
  }
}