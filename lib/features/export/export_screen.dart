import 'dart:typed_data';

import 'package:curriculator_free/core/services/isar_service.dart';
import 'package:curriculator_free/models/curriculum_version.dart';
import 'package:curriculator_free/models/education.dart';
import 'package:curriculator_free/models/experience.dart';
import 'package:curriculator_free/models/language.dart';
import 'package:curriculator_free/models/personal_data.dart';
import 'package:curriculator_free/models/skill.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

// --- Data Layer (Providers e Models de UI) ---

/// Uma classe de conveniência para agrupar todos os dados necessários para a exportação.
class CurriculumDataBundle {
  final CurriculumVersion version;
  final PersonalData? personalData;
  final List<Experience> experiences;
  final List<Education> educations;
  final List<Skill> skills;
  final List<Language> languages;

  CurriculumDataBundle({
    required this.version,
    required this.personalData,
    required this.experiences,
    required this.educations,
    required this.skills,
    required this.languages,
  });
}

/// Provider que busca de forma assíncrona todos os dados de uma versão específica do currículo.
/// Usamos `.family` para poder passar o `versionId` como parâmetro.
final exportDataProvider =
FutureProvider.family.autoDispose<CurriculumDataBundle, int>((ref, versionId) async {
  final isar = await ref.watch(isarServiceProvider).db;

  // 1. Busca a versão do currículo pelo ID.
  final version = await isar.curriculumVersions.get(versionId);
  if (version == null) {
    throw Exception('Versão do currículo não encontrada!');
  }

  // 2. Carrega todos os dados "linkados" a essa versão.
  await version.personalData.load();
  await version.experiences.load();
  await version.educations.load();
  await version.skills.load();
  await version.languages.load();

  // 3. Retorna o pacote de dados completo.
  return CurriculumDataBundle(
    version: version,
    personalData: version.personalData.value,
    experiences: version.experiences.toList(),
    educations: version.educations.toList(),
    skills: version.skills.toList(),
    languages: version.languages.toList(),
  );
});

// --- Main UI ---

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
  Key _pdfPreviewKey = UniqueKey(); // Chave para forçar a reconstrução do preview

  void _updatePreview() {
    setState(() {
      // Mudar a chave força o widget PdfPreview a reconstruir e chamar a função `build` novamente.
      _pdfPreviewKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    final asyncData = ref.watch(exportDataProvider(widget.versionId));

    return Scaffold(
      appBar: AppBar(
        title: Text(asyncData.valueOrNull?.version.name ?? 'Exportar Currículo'),
        centerTitle: false,
      ),
      body: asyncData.when(
        data: (data) => Row(
          children: [
            // Coluna de Controles (Esquerda)
            SizedBox(
              width: 300,
              child: _buildControlsPanel(),
            ),
            const VerticalDivider(width: 1),
            // Pré-visualização do PDF (Direita)
            Expanded(
              child: PdfPreview(
                key: _pdfPreviewKey,
                build: (format) => _generatePdfBytes(data),
                useActions: true,
                canChangeOrientation: false,
                canChangePageFormat: false,
                canDebug: false,
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Erro ao carregar dados: $error')),
      ),
    );
  }

  Widget _buildControlsPanel() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Seletor de Template
          Text('Template', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedTemplate,
            items: ['Clássico', 'Moderno', 'Minimalista'].map((template) => DropdownMenuItem(value: template, child: Text(template))).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedTemplate = value);
                _updatePreview();
              }
            },
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          const Divider(height: 32),

          // 2. Tamanho da Fonte
          Text('Tamanho da Fonte Principal (${_fontSize.toStringAsFixed(0)})', style: Theme.of(context).textTheme.titleMedium),
          Slider(
            value: _fontSize,
            min: 8, max: 14,
            divisions: 6,
            label: _fontSize.round().toString(),
            onChanged: (value) => setState(() => _fontSize = value),
            onChangeEnd: (value) => _updatePreview(),
          ),
          const Divider(height: 32),

          // 3. Margens
          Text('Margens', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _marginPreset,
            items: ['Estreita', 'Normal', 'Larga'].map((margin) => DropdownMenuItem(value: margin, child: Text(margin))).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _marginPreset = value);
                _updatePreview();
              }
            },
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          const Divider(height: 32),

          // 4. Cor de Destaque
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Cor de Destaque', style: Theme.of(context).textTheme.titleMedium),
            trailing: CircleAvatar(backgroundColor: _accentColor, radius: 14),
            onTap: _showColorPicker,
          )
        ],
      ),
    );
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Selecione uma cor'),
        content: SingleChildScrollView(
          child: BlockPicker(
            pickerColor: _accentColor,
            onColorChanged: (color) => setState(() => _accentColor = color),
          ),
        ),
        actions: <Widget>[
          ElevatedButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
              _updatePreview();
            },
          ),
        ],
      ),
    );
  }

  // --- PDF Generation Logic ---

  pw.EdgeInsets _getMargins() {
    switch(_marginPreset) {
      case 'Estreita': return const pw.EdgeInsets.all(28); // ~1cm
      case 'Larga': return const pw.EdgeInsets.all(85); // ~3cm
      case 'Normal':
      default: return const pw.EdgeInsets.all(56); // ~2cm
    }
  }

  // "Despachante" que escolhe qual template construir
  Future<Uint8List> _generatePdfBytes(CurriculumDataBundle data) async {
    final pdfTheme = pw.ThemeData.withFont(
      // TODO: Adicionar fontes customizadas (como Roboto) para um visual melhor
    );

    switch (_selectedTemplate) {
      case 'Moderno':
        return _buildModernoTemplate(data, pdfTheme);
      case 'Minimalista':
        return _buildMinimalistaTemplate(data, pdfTheme);
      case 'Clássico':
      default:
        return _buildClassicoTemplate(data, pdfTheme);
    }
  }

  // --- TEMPLATE BUILDERS ---

  Future<Uint8List> _buildClassicoTemplate(CurriculumDataBundle data, pw.ThemeData theme) async {
    final pdf = pw.Document(theme: theme);
    final PdfColor accent = PdfColor.fromInt(_accentColor.value);

    pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: _getMargins(),
        build: (context) {
          return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Cabeçalho
                pw.Header(
                  child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text(
                          data.personalData?.name?.toUpperCase() ?? 'SEU NOME',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: _fontSize + 12),
                        ),
                        pw.SizedBox(height: 5),
                        pw.Text(
                            '${data.personalData?.email ?? ""} • ${data.personalData?.phone ?? ""} • ${data.personalData?.linkedinUrl ?? ""}',
                            style: pw.TextStyle(fontSize: _fontSize - 1)
                        ),
                      ]
                  ),
                ),
                _Section(title: "Resumo", accentColor: accent,
                  child: pw.Text(data.personalData?.summary ?? '', style: pw.TextStyle(fontSize: _fontSize)),
                ),
                _Section(title: "Experiência Profissional", accentColor: accent,
                    child: pw.Column(children: data.experiences.map((exp) => _ExperienceItem(exp, _fontSize)).toList())
                ),
                _Section(title: "Formação Acadêmica", accentColor: accent,
                    child: pw.Column(children: data.educations.map((edu) => _EducationItem(edu, _fontSize)).toList())
                ),
                _Section(title: "Habilidades", accentColor: accent,
                    child: pw.Wrap(
                        spacing: 8, runSpacing: 8,
                        children: data.skills.map((s) => pw.Text('• ${s.name}')).toList()
                    )
                )
              ]
          );
        }));

    return pdf.save();
  }

  Future<Uint8List> _buildModernoTemplate(CurriculumDataBundle data, pw.ThemeData theme) async {
    // Implementação do template com barra lateral
    final pdf = pw.Document(theme: theme);
    // ... Lógica para gerar PDF moderno ...
    // Este é um exemplo, a complexidade pode aumentar
    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero, // Margem controlada dentro dos containers
      build: (context) => [
        pw.Partitions(children: [
          pw.Partition(
              width: 200,
              child: pw.Container(
                  color: PdfColor.fromInt(_accentColor.withOpacity(0.2).value),
                  padding: const pw.EdgeInsets.all(28),
                  child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(data.personalData?.name ?? "Seu Nome", style: pw.TextStyle(fontSize: _fontSize + 8, fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 20),
                        _SidebarSection(title: "Contato",
                            child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text(data.personalData?.email ?? ""),
                                  pw.Text(data.personalData?.phone ?? ""),
                                  pw.Text(data.personalData?.linkedinUrl ?? ""),
                                ]
                            )
                        ),
                        _SidebarSection(title: "Habilidades",
                            child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: data.skills.map((s) => pw.Text("• ${s.name}")).toList()
                            )
                        )
                      ]
                  )
              )
          ),
          pw.Partition(
              child: pw.Container(
                  padding: const pw.EdgeInsets.all(28),
                  child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        _Section(title: "Resumo", accentColor: PdfColor.fromInt(_accentColor.value), child: pw.Text(data.personalData?.summary ?? '')),
                        _Section(title: "Experiência", accentColor: PdfColor.fromInt(_accentColor.value), child: pw.Column(children: data.experiences.map((exp) => _ExperienceItem(exp, _fontSize)).toList())),
                        _Section(title: "Formação", accentColor: PdfColor.fromInt(_accentColor.value), child: pw.Column(children: data.educations.map((edu) => _EducationItem(edu, _fontSize)).toList())),
                      ]
                  )
              )
          ),
        ])
      ],
    ));

    return pdf.save();
  }

  Future<Uint8List> _buildMinimalistaTemplate(CurriculumDataBundle data, pw.ThemeData theme) async {
    // Implementação do template focado em dados
    return _buildClassicoTemplate(data, theme); // Placeholder, usar a lógica do clássico por enquanto
  }
}

// --- Widgets de PDF reutilizáveis ---

pw.Widget _Section({required String title, required pw.Widget child, required PdfColor accentColor}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 10),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title.toUpperCase(),
          style: pw.TextStyle(color: accentColor, fontWeight: pw.FontWeight.bold, fontSize: 12),
        ),
        pw.Container(height: 2, width: 40, color: accentColor, margin: const pw.EdgeInsets.symmetric(vertical: 4)),
        child,
      ],
    ),
  );
}

pw.Widget _SidebarSection({required String title, required pw.Widget child}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 10),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title.toUpperCase(),
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
        ),
        pw.SizedBox(height: 5),
        child,
      ],
    ),
  );
}


pw.Widget _ExperienceItem(Experience exp, double baseFontSize) {
  final format = DateFormat('MM/yyyy');
  final period = '${exp.startDate != null ? format.format(exp.startDate!) : ''} - ${exp.isCurrent ? 'Presente' : (exp.endDate != null ? format.format(exp.endDate!) : '')}';

  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 8),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(exp.jobTitle ?? '', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: baseFontSize + 1)),
            pw.Text(period, style: pw.TextStyle(fontSize: baseFontSize -1, fontStyle: pw.FontStyle.italic)),
          ],
        ),
        pw.Text('${exp.company} | ${exp.location}', style: pw.TextStyle(fontSize: baseFontSize, fontStyle: pw.FontStyle.italic)),
        if (exp.description != null && exp.description!.isNotEmpty)
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 4),
            child: pw.Text(exp.description!, style: pw.TextStyle(fontSize: baseFontSize)),
          ),
      ],
    ),
  );
}

pw.Widget _EducationItem(Education edu, double baseFontSize) {
  final format = DateFormat('MM/yyyy');
  final period = '${edu.startDate != null ? format.format(edu.startDate!) : ''} - ${edu.inProgress ? 'Presente' : (edu.endDate != null ? format.format(edu.endDate!) : '')}';

  return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Flexible(child: pw.Text('${edu.degree} em ${edu.fieldOfStudy}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: baseFontSize + 1))),
              pw.Text(period, style: pw.TextStyle(fontSize: baseFontSize -1, fontStyle: pw.FontStyle.italic)),
            ],
          ),
          pw.Text(edu.institution ?? '', style: pw.TextStyle(fontSize: baseFontSize, fontStyle: pw.FontStyle.italic)),
        ],
      )
  );
}