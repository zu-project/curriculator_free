import 'dart:io';
import 'dart:typed_data';

import 'package:curriculator_free/models/education.dart';
import 'package:curriculator_free/models/experience.dart';
import 'package:curriculator_free/models/language.dart';
import 'package:curriculator_free/models/personal_data.dart';
import 'package:curriculator_free/models/skill.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

// Estruturas de dados para passar informações de forma organizada
class CurriculumDataBundle {
  final PersonalData? personalData;
  final List<Experience> experiences;
  final List<Education> educations;
  final List<Skill> skills;
  final List<Language> languages;

  CurriculumDataBundle({
    this.personalData,
    required this.experiences,
    required this.educations,
    required this.skills,
    required this.languages,
  });
}

class PdfExportOptions {
  final String templateName;
  final double baseFontSize;
  final String marginPreset;
  final PdfColor accentColor;
  final bool includePhoto;
  final bool includeSummary;
  final bool includeAvailability;
  final bool includeVehicle;
  final bool includeLicense;
  final bool includeSocialLinks;

  PdfExportOptions({
    this.templateName = 'Clássico',
    this.baseFontSize = 10.0,
    this.marginPreset = 'Normal',
    required this.accentColor,
    this.includePhoto = true,
    this.includeSummary = true,
    this.includeAvailability = true,
    this.includeVehicle = true,
    this.includeLicense = true,
    this.includeSocialLinks = true,
  });
}

// O Serviço Gerador de PDF
class PdfGeneratorService {
  final CurriculumDataBundle data;
  final PdfExportOptions options;
  late final pw.Font _regularFont;
  late final pw.Font _boldFont;
  late final pw.Font _italicFont;
  late final pw.Font _boldItalicFont;

  PdfGeneratorService(this.data, this.options);

  // Método para carregar as fontes antes de gerar o PDF
  Future<void> _loadFonts() async {
    _regularFont = await pw.Font.ttf(await rootBundle.load("assets/fonts/Roboto-Regular.ttf"));
    _boldFont = await pw.Font.ttf(await rootBundle.load("assets/fonts/Roboto-Bold.ttf"));
    _italicFont = await pw.Font.ttf(await rootBundle.load("assets/fonts/Roboto-Italic.ttf"));
    _boldItalicFont = await pw.Font.ttf(await rootBundle.load("assets/fonts/Roboto-BoldItalic.ttf"));
  }

  // Método principal que escolhe e constrói o template
  Future<Uint8List> generatePdf() async {
    await _loadFonts();

    final theme = pw.ThemeData.withFont(
      base: _regularFont,
      bold: _boldFont,
      italic: _italicFont,
      boldItalic: _boldItalicFont,
    );

    switch (options.templateName) {
      case 'Moderno':
        return _buildModernoTemplate(theme);
      case 'Minimalista':
      // Placeholder, você pode criar a lógica para ele depois
        return _buildClassicoTemplate(theme);
      case 'Clássico':
      default:
        return _buildClassicoTemplate(theme);
    }
  }

  pw.EdgeInsets _getMargins() {
    switch(options.marginPreset) {
      case 'Estreita': return const pw.EdgeInsets.all(28); // ~1cm
      case 'Larga': return const pw.EdgeInsets.all(85); // ~3cm
      case 'Normal':
      default: return const pw.EdgeInsets.all(56); // ~2cm
    }
  }

  // --- TEMPLATE BUILDER: CLÁSSICO ---
  Future<Uint8List> _buildClassicoTemplate(pw.ThemeData theme) async {
    final pdf = pw.Document(theme: theme);
    final pData = data.personalData;

    final extras = _buildExtrasList(pData);

    pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: _getMargins(),
        build: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader(pData, extras),
              if (options.includeSummary && (pData?.summary?.isNotEmpty ?? false))
                _Section(title: "Resumo Profissional", accentColor: options.accentColor, child: pw.Text(pData!.summary!, style: pw.TextStyle(fontSize: options.baseFontSize))),

              if (data.experiences.isNotEmpty)
                _Section(title: "Experiência Profissional", accentColor: options.accentColor, child: pw.Column(children: data.experiences.map((exp) => _ExperienceItem(exp, options.baseFontSize)).toList())),

              if (data.educations.isNotEmpty)
                _Section(title: "Formação Acadêmica", accentColor: options.accentColor, child: pw.Column(children: data.educations.map((edu) => _EducationItem(edu, options.baseFontSize)).toList())),

              if (data.skills.isNotEmpty || data.languages.isNotEmpty)
                pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                  if (data.skills.isNotEmpty)
                    pw.Expanded(child: _Section(title: "Habilidades", accentColor: options.accentColor, child: pw.Wrap(spacing: 6, runSpacing: 6, children: data.skills.map((s) => pw.Text('• ${s.name}')).toList()))),
                  if (data.skills.isNotEmpty && data.languages.isNotEmpty) pw.SizedBox(width: 24),
                  if (data.languages.isNotEmpty)
                    pw.Expanded(child: _Section(title: "Idiomas", accentColor: options.accentColor, child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: data.languages.map((l) => pw.Text('• ${l.languageName}: ${l.proficiency.name}')).toList()))),
                ]),
            ]))
    );
    return pdf.save();
  }

  // --- TEMPLATE BUILDER: MODERNO ---
  Future<Uint8List> _buildModernoTemplate(pw.ThemeData theme) async {
    final pdf = pw.Document(theme: theme);
    final pData = data.personalData;
    final extras = _buildExtrasList(pData);

    pw.ImageProvider? photoImage;
    if (options.includePhoto && pData?.photoPath != null) {
      final file = File(pData!.photoPath!);
      if (await file.exists()) {
        photoImage = pw.MemoryImage(await file.readAsBytes());
      }
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (context) =>
        [
          pw.Partitions(
            children: [
              pw.Partition(
                width: 200,
                child: pw.Opacity(
                  opacity: 0.2, // 20% de opacidade
                  child: pw.Container(
                    color: PdfColor.fromInt(
                        (options.accentColor as Color).value),
                    padding: const pw.EdgeInsets.all(28),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        if (photoImage != null)
                          pw.ClipOval(
                            child: pw.Container(
                              width: 100,
                              height: 100,
                              child: pw.Image(photoImage, fit: pw.BoxFit.cover),
                            ),
                          ),
                        if (photoImage != null) pw.SizedBox(height: 20),
                        pw.Text(
                          pData?.name ?? "Seu Nome",
                          style: pw.TextStyle(
                            fontSize: options.baseFontSize + 8,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 20),
                        _SidebarSection(
                          title: "Contato",
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              if (pData?.email.isNotEmpty ?? false) pw.Text(
                                  pData!.email),
                              if (pData?.phone?.isNotEmpty ?? false) pw.Text(
                                  pData!.phone!),
                              if (pData?.address?.isNotEmpty ?? false) pw.Text(
                                  pData!.address!),
                              if (options.includeSocialLinks &&
                                  (pData?.linkedinUrl?.isNotEmpty ?? false)) pw
                                  .Text(pData!.linkedinUrl!),
                              if (options.includeSocialLinks &&
                                  (pData?.portfolioUrl?.isNotEmpty ?? false)) pw
                                  .Text(pData!.portfolioUrl!),
                            ],
                          ),
                        ),
                        if (extras.isNotEmpty)
                          _SidebarSection(
                            title: "Disponibilidade",
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: extras
                                  .map((e) => pw.Text("• $e"))
                                  .toList(),
                            ),
                          ),
                        if (data.skills.isNotEmpty)
                          _SidebarSection(
                            title: "Habilidades",
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: data.skills.map((s) =>
                                  pw.Text("• ${s.name}")).toList(),
                            ),
                          ),
                        if (data.languages.isNotEmpty)
                          _SidebarSection(
                            title: "Idiomas",
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: data.languages.map((l) =>
                                  pw.Text("• ${l.languageName}")).toList(),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              pw.Partition(
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(28),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      if (options.includeSummary &&
                          (pData?.summary?.isNotEmpty ?? false))
                        _Section(
                          title: "Resumo",
                          accentColor: PdfColor.fromInt((options
                              .accentColor as Color).value),
                          child: pw.Text(pData!.summary!),
                        ),
                      if (data.experiences.isNotEmpty)
                        _Section(
                          title: "Experiência",
                          accentColor: PdfColor.fromInt((options
                              .accentColor as Color).value),
                          child: pw.Column(
                            children: data.experiences
                                .map((exp) =>
                                _ExperienceItem(exp, options.baseFontSize))
                                .toList(),
                          ),
                        ),
                      if (data.educations.isNotEmpty)
                        _Section(
                          title: "Formação",
                          accentColor: PdfColor.fromInt((options
                              .accentColor as Color).value),
                          child: pw.Column(
                            children: data.educations
                                .map((edu) =>
                                _EducationItem(edu, options.baseFontSize))
                                .toList(),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
    return pdf.save();
  }

    // --- WIDGETS DE PDF REUTILIZÁVEIS ---

  List<String> _buildExtrasList(PersonalData? pData) {
    final List<String> extras = [];
    if (pData != null) {
      if (options.includeAvailability && pData.hasTravelAvailability) extras.add('Disponibilidade para viagens');
      if (options.includeAvailability && pData.hasRelocationAvailability) extras.add('Disponibilidade para mudança');

      final vehicles = <String>[];
      if (options.includeVehicle && pData.hasCar) vehicles.add('Carro');
      if (options.includeVehicle && pData.hasMotorcycle) vehicles.add('Moto');
      if (vehicles.isNotEmpty) extras.add('Veículo Próprio (${vehicles.join('/')})');

      if (options.includeLicense && pData.licenseCategories.isNotEmpty) extras.add('CNH: ${pData.licenseCategories.join(', ')}');
    }
    return extras;
  }

  pw.Widget _buildHeader(PersonalData? pData, List<String> extras) {
    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.center, children: [
      pw.Text(pData?.name.toUpperCase() ?? 'SEU NOME', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: options.baseFontSize + 12)),
      pw.SizedBox(height: 5),
      pw.Text('${pData?.email ?? ""} • ${pData?.phone ?? ""} • ${pData?.address ?? ""}', style: pw.TextStyle(fontSize: options.baseFontSize - 1)),
      if(options.includeSocialLinks && (pData?.linkedinUrl?.isNotEmpty ?? false)) pw.Text(pData!.linkedinUrl!, style: pw.TextStyle(fontSize: options.baseFontSize - 1)),
      if(options.includeSocialLinks && (pData?.portfolioUrl?.isNotEmpty ?? false)) pw.Text(pData!.portfolioUrl!, style: pw.TextStyle(fontSize: options.baseFontSize - 1)),
      if (extras.isNotEmpty) ...[
        pw.SizedBox(height: 5),
        pw.Text(extras.join(' | '), textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: options.baseFontSize - 1)),
      ],
      pw.SizedBox(height: 10),
    ],
    );
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