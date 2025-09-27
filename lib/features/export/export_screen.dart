//C:\Users\ziofl\StudioProjects\curriculator_free\lib\features\export\export_screen.dart
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

// --- Camada de Dados (Provider Corrigido) ---

// Um novo DTO para agrupar TUDO o que a tela precisa.
class ExportScreenData {
  final CurriculumVersion version;
  final CurriculumDataBundle dataBundle;
  ExportScreenData(this.version, this.dataBundle);
}

// Provider único e robusto que busca a versão E os dados linkados.
final exportScreenDataProvider =
FutureProvider.family.autoDispose<ExportScreenData, int>((ref, versionId) async {
  final isar = await ref.watch(isarDbProvider.future); // Usa o novo isarDbProvider

  final version = await isar.curriculumVersions.get(versionId);
  if (version == null) throw Exception('Versão do currículo não encontrada!');

  await version.personalData.load();
  await version.experiences.load();
  await version.educations.load();
  await version.skills.load();
  await version.languages.load();

  final dataBundle = CurriculumDataBundle(
    personalData: version.personalData.value,
    experiences: version.experiences.toList(),
    educations: version.educations.toList(),
    skills: version.skills.toList(),
    languages: version.languages.toList(),
  );

  return ExportScreenData(version, dataBundle);
});

// --- Tela Principal (UI Corrigida) ---

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
  String _marginPreset = 'Normal';
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

  // Carrega as opções salvas na versão do currículo
  void _loadSavedOptions(CurriculumVersion version) {
    setState(() {
      _selectedTemplate = version.lastUsedTemplate ?? 'Clássico';
      _fontSize = version.fontSize ?? 10.0;
      if (version.accentColorHex != null) {
        _accentColor = Color(int.parse(version.accentColorHex!.replaceAll('#', '0xFF')));
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

  // Delega a geração do PDF para o serviço
  Future<Uint8List> _generatePdfBytes(CurriculumDataBundle data) {
    final pdfOptions = PdfExportOptions(
      templateName: _selectedTemplate, baseFontSize: _fontSize, marginPreset: _marginPreset,
      accentColor: PdfColor.fromInt(_accentColor.value),
      includePhoto: _includePhoto, includeSummary: _includeSummary,
      includeAvailability: _includeAvailability, includeVehicle: _includeVehicle,
      includeLicense: _includeLicense, includeSocialLinks: _includeSocialLinks,
    );

    final generator = PdfGeneratorService(data, pdfOptions);
    return generator.generatePdf();
  }

  @override
  Widget build(BuildContext context) {
    final asyncData = ref.watch(exportScreenDataProvider(widget.versionId));

    return Scaffold(
      appBar: AppBar(
        // Adiciona um botão de voltar que funciona com GoRouter
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        title: Text(asyncData.valueOrNull?.version.name ?? 'Exportar e Visualizar'),
      ),
      body: asyncData.when(
        data: (exportData) {
          // Carrega as opções salvas apenas uma vez
          if (!_initialDataLoaded) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _loadSavedOptions(exportData.version);
            });
          }

          return Row(
            children: [
              SizedBox(width: 300, child: _buildControlsPanel(exportData.dataBundle.personalData)),
              const VerticalDivider(width: 1),
              Expanded(
                child: PdfPreview(
                  key: _pdfPreviewKey,
                  build: (format) => _generatePdfBytes(exportData.dataBundle),
                  useActions: true, canChangeOrientation: false,
                  canChangePageFormat: false, canDebug: false,
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Erro ao carregar dados: $error')),
      ),
    );
  }

  // --- Painel de Controles (com os widgets que faltavam) ---
  Widget _buildControlsPanel(PersonalData? pData) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Seção de Aparência
          Text('Aparência', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedTemplate,
            decoration: const InputDecoration(labelText: 'Template', border: OutlineInputBorder()),
            items: ['Clássico', 'Moderno'].map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
            onChanged: (v) { setState(() => _selectedTemplate = v!); _updatePreview(); },
          ),
          const SizedBox(height: 16),
          Text('Tamanho da Fonte (${_fontSize.toStringAsFixed(0)})'),
          Slider(value: _fontSize, min: 8, max: 14, divisions: 6, label: _fontSize.round().toString(), onChanged: (v) => setState(() => _fontSize = v), onChangeEnd: (_) => _updatePreview()),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero, title: const Text('Cor de Destaque'),
            trailing: CircleAvatar(backgroundColor: _accentColor, radius: 14),
            onTap: _showColorPicker,
          ),

          const Divider(height: 48),

          // Seção de Inclusão
          Text('Incluir no Currículo', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),

          if (pData?.photoPath?.isNotEmpty ?? false)
            SwitchListTile(title: const Text('Foto'), value: _includePhoto, onChanged: (v){setState(()=>_includePhoto=v);_updatePreview();}),
          if (pData?.summary?.isNotEmpty ?? false)
            SwitchListTile(title: const Text('Resumo Profissional'), value: _includeSummary, onChanged: (v){setState(()=>_includeSummary=v);_updatePreview();}),
          SwitchListTile(title: const Text('Disponibilidades'), value: _includeAvailability, onChanged: (v){setState(()=>_includeAvailability=v);_updatePreview();}),
          if(pData?.hasCar == true || pData?.hasMotorcycle == true)
            SwitchListTile(title: const Text('Veículo Próprio'), value: _includeVehicle, onChanged: (v){setState(()=>_includeVehicle=v);_updatePreview();}),
          if(pData?.licenseCategories.isNotEmpty ?? false)
            SwitchListTile(title: const Text('Carteira de Habilitação'), value: _includeLicense, onChanged: (v){setState(()=>_includeLicense=v);_updatePreview();}),
          if ((pData?.linkedinUrl?.isNotEmpty??false) || (pData?.portfolioUrl?.isNotEmpty??false))
            SwitchListTile(title: const Text('Links Sociais'), value: _includeSocialLinks, onChanged: (v){setState(()=>_includeSocialLinks=v);_updatePreview();}),
        ],
      ),
    );
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Selecione uma cor'),
        content: SingleChildScrollView(child: BlockPicker(pickerColor: _accentColor, onColorChanged: (c)=>setState(()=>_accentColor=c))),
        actions: [ElevatedButton(child: const Text('OK'), onPressed: (){Navigator.of(context).pop();_updatePreview();})],
      ),
    );
  }
}