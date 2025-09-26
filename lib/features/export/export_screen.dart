import 'dart:typed_data';
import 'package:curriculator_free/core/services/isar_service.dart';
import 'package:curriculator_free/features/export/pdf_generator_service.dart'; // Importa o novo serviço
import 'package:curriculator_free/models/curriculum_version.dart';
import 'package:curriculator_free/models/personal_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

// --- Camada de Dados (Providers) ---

// Provider para buscar a versão do currículo e seus dados
final exportDataProvider =
FutureProvider.family.autoDispose<CurriculumDataBundle, int>((ref, versionId) async {
  final isar = await ref.watch(isarServiceProvider).db;
  final version = await isar.curriculumVersions.get(versionId);
  if (version == null) throw Exception('Versão do currículo não encontrada!');

  await version.personalData.load();
  await version.experiences.load();
  await version.educations.load();
  await version.skills.load();
  await version.languages.load();

  return CurriculumDataBundle(
    personalData: version.personalData.value,
    experiences: version.experiences.toList(),
    educations: version.educations.toList(),
    skills: version.skills.toList(),
    languages: version.languages.toList(),
  );
});

// --- Tela Principal (UI) ---

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

  void _updatePreview() => setState(() => _pdfPreviewKey = UniqueKey());

  // Método que agora DELEGA a geração do PDF para o serviço
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
    final asyncData = ref.watch(exportDataProvider(widget.versionId));

    return Scaffold(
      appBar: AppBar(title: const Text('Exportar e Visualizar')),
      body: asyncData.when(
        data: (data) => Row(
          children: [
            SizedBox(width: 300, child: _buildControlsPanel(data.personalData)),
            const VerticalDivider(width: 1),
            Expanded(
              child: PdfPreview(
                key: _pdfPreviewKey,
                build: (format) => _generatePdfBytes(data),
                useActions: true, canChangeOrientation: false,
                canChangePageFormat: false, canDebug: false,
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Erro ao carregar dados: $error')),
      ),
    );
  }

  Widget _buildControlsPanel(PersonalData? pData) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Aparência', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          // ... (Dropdowns, Slider, Color Picker - Código inalterado)

          const Divider(height: 48),
          Text('Incluir no Currículo', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),

          if (pData?.photoPath?.isNotEmpty ?? false)
            SwitchListTile(title: const Text('Foto'), value: _includePhoto, onChanged: (v){setState(()=>_includePhoto=v);_updatePreview();}),
          if (pData?.summary?.isNotEmpty ?? false)
            SwitchListTile(title: const Text('Resumo Profissional'), value: _includeSummary, onChanged: (v){setState(()=>_includeSummary=v);_updatePreview();}),

          SwitchListTile(title: const Text('Disponibilidades'), subtitle: const Text('(Viagem e Mudança)'), value: _includeAvailability, onChanged: (v){setState(()=>_includeAvailability=v);_updatePreview();}),

          if(pData?.hasCar == true || pData?.hasMotorcycle == true)
            SwitchListTile(title: const Text('Veículo Próprio'), value: _includeVehicle, onChanged: (v){setState(()=>_includeVehicle=v);_updatePreview();}),

          if(pData?.licenseCategories.isNotEmpty ?? false)
            SwitchListTile(title: const Text('Carteira de Habilitação'), value: _includeLicense, onChanged: (v){setState(()=>_includeLicense=v);_updatePreview();}),

          if ((pData?.linkedinUrl?.isNotEmpty ?? false) || (pData?.portfolioUrl?.isNotEmpty ?? false))
            SwitchListTile(title: const Text('Links (LinkedIn/Portfólio)'), value: _includeSocialLinks, onChanged: (v){setState(()=>_includeSocialLinks=v);_updatePreview();}),
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