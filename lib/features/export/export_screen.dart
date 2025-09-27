// lib/features/export/export_screen.dart
// VERSÃO FINAL COM A NOVA ARQUITETURA

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:screenshot/screenshot.dart';

import 'package:curriculator_free/core/services/isar_service.dart';
import 'package:curriculator_free/models/curriculum_version.dart';
import 'cv_template.dart'; // Importa seu novo template
import 'package:curriculator_free/models/personal_data.dart';
import 'pdf_generator_service.dart';

// Provider para os dados da versão (ID da versão)
final versionProvider = FutureProvider.family.autoDispose<CurriculumVersion?, int>((ref, versionId) async {
  final isar = await ref.watch(isarDbProvider.future);
  return isar.curriculumVersions.get(versionId);
});

// Provider para o bundle de dados do currículo
final curriculumBundleProvider = FutureProvider.family.autoDispose<CurriculumDataBundle, int>((ref, versionId) async {
  final isar = await ref.watch(isarDbProvider.future);
  final version = await isar.curriculumVersions.get(versionId);
  if (version == null) throw Exception('Versão do currículo não encontrada!');

  await Future.wait([
    version.personalData.load(),
    version.experiences.load(),
    version.educations.load(),
    version.skills.load(),
    version.languages.load(),
  ]);

  return CurriculumDataBundle(
    personalData: version.personalData.value,
    experiences: version.experiences.toList(),
    educations: version.educations.toList(),
    skills: version.skills.toList(),
    languages: version.languages.toList(),
  );
});


class ExportScreen extends ConsumerStatefulWidget {
  final int versionId;
  const ExportScreen({super.key, required this.versionId});

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();
  final TransformationController _transformationController = TransformationController();
  bool _initialDataLoaded = false;

  // Estado local para os controles
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

  @override
  void initState() {
    super.initState();
    // Carrega as opções salvas para esta versão específica
    ref.read(versionProvider(widget.versionId).future).then((version) {
      if (mounted && version != null) {
        _loadSavedOptions(version);
      }
    });
  }

  void _loadSavedOptions(CurriculumVersion version) {
    setState(() {
      _selectedTemplate = version.lastUsedTemplate ?? 'Clássico';
      _fontSize = version.fontSize ?? 10.0;
      if (version.accentColorHex != null) {
        try {
          _accentColor = Color(int.parse(version.accentColorHex!.replaceAll('#', '0xFF')));
        } catch (e) { /* Usa a cor padrão se falhar */ }
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

  void _zoomIn() {
    final currentScale = _transformationController.value.getMaxScaleOnAxis();
    _transformationController.value = Matrix4.identity()..scale(currentScale + 0.1);
  }

  void _zoomOut() {
    final currentScale = _transformationController.value.getMaxScaleOnAxis();
    if (currentScale > 0.2) {
      _transformationController.value = Matrix4.identity()..scale(currentScale - 0.1);
    }
  }

  Future<void> _saveAsPdf() async {
    final bundle = await ref.read(curriculumBundleProvider(widget.versionId).future);

    final currentOptions = TemplateOptions(
      templateName: _selectedTemplate,
      marginPreset: _marginPreset,
      fontSize: _fontSize,
      accentColor: _accentColor,
      includePhoto: _includePhoto,
      includeSummary: _includeSummary,
      includeAvailability: _includeAvailability,
      includeVehicle: _includeVehicle,
      includeLicense: _includeLicense,
      includeSocialLinks: _includeSocialLinks,
    );

    final pdfService = PdfGeneratorService(bundle, currentOptions);
    final Uint8List pdfBytes = await pdfService.generatePdf();

    final version = await ref.read(versionProvider(widget.versionId).future);
    final fileName = '${(version?.name ?? "curriculo").replaceAll(' ', '_')}.pdf';

    await Printing.sharePdf(bytes: pdfBytes, filename: fileName);
  }

  @override
  Widget build(BuildContext context) {
    final asyncBundle = ref.watch(curriculumBundleProvider(widget.versionId));
    final asyncVersion = ref.watch(versionProvider(widget.versionId));

    final shortcuts = <ShortcutActivator, Intent>{
      LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.equal):  _ZoomInIntent(),
      LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.add):  _ZoomInIntent(),
      LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.minus):  _ZoomOutIntent(),
      LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.numpadSubtract):  _ZoomOutIntent(),
    };
    final actions = <Type, Action<Intent>>{
      _ZoomInIntent: CallbackAction<_ZoomInIntent>(onInvoke: (_) => _zoomIn()),
      _ZoomOutIntent: CallbackAction<_ZoomOutIntent>(onInvoke: (_) => _zoomOut()),
    };

    return Scaffold(
      appBar: AppBar(
        title: Text('Exportar: ${asyncVersion.valueOrNull?.name ?? "Carregando..."}'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/')),
        actions: [
          IconButton(tooltip: 'Diminuir Zoom (Ctrl-)', icon: const Icon(Icons.zoom_out), onPressed: _zoomOut),
          IconButton(tooltip: 'Aumentar Zoom (Ctrl+)', icon: const Icon(Icons.zoom_in), onPressed: _zoomIn),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: FilledButton.icon(
              icon: const Icon(Icons.print_outlined),
              label: const Text('Salvar/Imprimir'),
              onPressed: _saveAsPdf,
            ),
          )
        ],
      ),
      body: Row(
        children: [
          SizedBox(width: 320, child: _buildControlsPanel(asyncBundle.valueOrNull?.personalData)),
          const VerticalDivider(width: 1),
          Expanded(
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor.computeLuminance() > 0.5 ? Colors.grey.shade300 : Colors.grey.shade900,
              child: Shortcuts(
                shortcuts: shortcuts,
                child: Actions(
                  actions: actions,
                  child: Focus(
                    autofocus: true,
                    child: InteractiveViewer(
                      transformationController: _transformationController,
                      minScale: 0.1, maxScale: 4.0,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Material(
                            elevation: 4.0,
                            child: asyncBundle.when(
                              data: (data) => Screenshot(
                                controller: _screenshotController,
                                child: CvTemplate(
                                  data: data,
                                  options: TemplateOptions(
                                    templateName: _selectedTemplate,
                                    marginPreset: _marginPreset,
                                    fontSize: _fontSize,
                                    accentColor: _accentColor,
                                    includePhoto: _includePhoto,
                                    includeSummary: _includeSummary,
                                    includeAvailability: _includeAvailability,
                                    includeVehicle: _includeVehicle,
                                    includeLicense: _includeLicense,
                                    includeSocialLinks: _includeSocialLinks,
                                  ),
                                ),
                              ),
                              loading: () => const SizedBox(width: 595, height: 842, child: Center(child: CircularProgressIndicator())),
                              error: (e, s) => SizedBox(width: 595, height: 842, child: Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text("Erro ao carregar dados: $e")))),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
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
          DropdownButtonFormField<String>(
            value: _selectedTemplate,
            decoration: const InputDecoration(labelText: 'Template', border: OutlineInputBorder()),
            items: ['Clássico', 'Moderno', 'Funcional', 'Minimalista'].map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
            onChanged: (v) => setState(() => _selectedTemplate = v ?? 'Clássico'),
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            value: _marginPreset,
            decoration: const InputDecoration(labelText: 'Margens', border: OutlineInputBorder()),
            items: ['Normal', 'Estreita', 'Larga'].map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
            onChanged: (v) => setState(() => _marginPreset = v ?? 'Normal'),
          ),
          const SizedBox(height: 20),
          Text('Tamanho da Fonte (${_fontSize.toStringAsFixed(0)})'),
          Slider(value: _fontSize, min: 8, max: 14, divisions: 6, label: _fontSize.round().toString(), onChanged: (v) => setState(() => _fontSize = v)),
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
          _buildToggle(title: 'Resumo', value: _includeSummary, enabled: pData?.summary?.isNotEmpty ?? false, onChanged: (v) => _includeSummary = v),
          _buildToggle(title: 'Disponibilidades', value: _includeAvailability, onChanged: (v) => _includeAvailability = v),
          _buildToggle(title: 'Veículo', value: _includeVehicle, enabled: (pData?.hasCar ?? false) || (pData?.hasMotorcycle ?? false), onChanged: (v) => _includeVehicle = v),
          _buildToggle(title: 'Habilitação', value: _includeLicense, enabled: pData?.licenseCategories.isNotEmpty ?? false, onChanged: (v) => _includeLicense = v),
          _buildToggle(title: 'Links Sociais', value: _includeSocialLinks, enabled: (pData?.linkedinUrl?.isNotEmpty??false) || (pData?.portfolioUrl?.isNotEmpty??false), onChanged: (v) => _includeSocialLinks = v),
        ],
      ),
    );
  }

  Widget _buildToggle({required String title, required bool value, bool enabled = true, required Function(bool) onChanged}) {
    return SwitchListTile(
        title: Text(title, style: TextStyle(color: enabled ? null : Colors.grey)),
        value: value,
        onChanged: enabled ? (v) => setState(() => onChanged(v)) : null);
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Selecione uma cor'),
        content: SingleChildScrollView(child: BlockPicker(pickerColor: _accentColor, onColorChanged: (c) => setState(() => _accentColor = c))),
        actions: [ElevatedButton(child: const Text('OK'), onPressed: () => Navigator.of(context).pop())],
      ),
    );
  }
}

class _ZoomInIntent extends Intent {}
class _ZoomOutIntent extends Intent {}