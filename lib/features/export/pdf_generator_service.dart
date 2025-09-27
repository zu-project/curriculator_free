// lib/features/export/pdf_generator_service.dart
// VERSÃO FINAL E SEGURA: Abordagem de layout simplificada para garantir estabilidade.

import 'dart:io';
import 'dart:typed_data';

import 'package:curriculator_free/models/education.dart';
import 'package:curriculator_free/models/experience.dart';
import 'package:curriculator_free/models/language.dart';
import 'package:curriculator_free/models/personal_data.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'cv_template.dart';

class PdfGeneratorService {
  final CurriculumDataBundle data;
  final TemplateOptions options;
  final _dateFormat = DateFormat('MM/yyyy', 'pt_BR');

  pw.Font? _regularFont;
  pw.Font? _boldFont;
  pw.Font? _italicFont;

  PdfGeneratorService(this.data, this.options);

  Future<Uint8List> generatePdf() async {
    final doc = pw.Document();

    _regularFont = await PdfGoogleFonts.robotoRegular();
    _boldFont = await PdfGoogleFonts.robotoBold();
    _italicFont = await PdfGoogleFonts.robotoItalic();

    final theme = pw.ThemeData.withFont(
      base: _regularFont!,
      bold: _boldFont!,
      italic: _italicFont!,
    );

    // *** MUDANÇA ESTRUTURAL E SOLUÇÃO FINAL ***
    // Usamos UMA ÚNICA abordagem para TODOS os templates.
    // O MultiPage tem margens, e todo o conteúdo é renderizado dentro delas.
    // Isso remove toda a complexidade que estava causando o erro de layout.
    doc.addPage(
      pw.MultiPage(
        theme: theme,
        pageFormat: PdfPageFormat.a4,
        margin: _getPdfMargins(), // Margens definidas para todos.
        build: (context) {
          // A lista de widgets é construída de forma linear e simples.
          return [
            _buildHeader(context),
            ..._buildCoreContent(context),
          ];
        },
      ),
    );

    return doc.save();
  }

  // --- MÉTODOS DE CONSTRUÇÃO (versão para o pacote PDF) ---

  pw.EdgeInsets _getPdfMargins() {
    switch (options.marginPreset) {
      case 'Estreita': return const pw.EdgeInsets.all(35);
      case 'Larga': return const pw.EdgeInsets.all(70);
      default: return const pw.EdgeInsets.all(50);
    }
  }

  PdfColor get _accentPdfColor => PdfColor.fromInt(options.accentColor.value);

  pw.Widget _buildHeader(pw.Context context) {
    // A lógica para decidir qual header construir permanece, agora incluindo o Moderno.
    switch (options.templateName) {
      case 'Moderno': return _buildModernHeader(context);
      case 'Funcional': return _buildFunctionalHeader(context);
      case 'Minimalista': return _buildMinimalistHeader(context);
      default: return _buildClassicHeader(context);
    }
  }

  List<pw.Widget> _buildCoreContent(pw.Context context) {
    final bool useModernTitle = ['Moderno', 'Funcional'].contains(options.templateName);
    final PdfColor titleColor = options.templateName == 'Minimalista' ? PdfColors.black : _accentPdfColor;
    return [
      if (options.includeSummary && (data.personalData?.summary?.isNotEmpty ?? false))
        _buildSection(title: useModernTitle ? 'RESUMO' : 'Resumo Profissional', useModernTitle: useModernTitle, titleColor: titleColor, child: _buildSummary()),
      if (data.experiences.isNotEmpty)
        _buildSection(title: useModernTitle ? 'EXPERIÊNCIA' : 'Experiência Profissional', useModernTitle: useModernTitle, titleColor: titleColor, child: _buildExperienceList()),
      if (data.educations.isNotEmpty)
        _buildSection(title: useModernTitle ? 'FORMAÇÃO' : 'Formação Acadêmica', useModernTitle: useModernTitle, titleColor: titleColor, child: _buildEducationList()),
      if (data.skills.isNotEmpty)
        _buildSection(title: useModernTitle ? 'HABILIDADES' : 'Habilidades', useModernTitle: useModernTitle, titleColor: titleColor, child: _buildSkillList()),
      if (data.languages.isNotEmpty)
        _buildSection(title: useModernTitle ? 'IDIOMAS' : 'Idiomas', useModernTitle: useModernTitle, titleColor: titleColor, child: _buildLanguageList()),
    ];
  }

  pw.Widget _buildClassicHeader(pw.Context context) {
    final p = data.personalData;
    if (p == null) return pw.SizedBox.shrink();
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(p.name, style: pw.TextStyle(fontSize: options.fontSize + 16, fontWeight: pw.FontWeight.bold, color: _accentPdfColor)),
              pw.SizedBox(height: 12),
              _buildContactAndOtherInfo(p),
            ],
          ),
        ),
        if (options.includePhoto && p.photoPath != null && File(p.photoPath!).existsSync())
          pw.Padding(
            padding: const pw.EdgeInsets.only(left: 24),
            child: pw.ClipOval(
              child: pw.Image(
                pw.MemoryImage(File(p.photoPath!).readAsBytesSync()),
                width: 100,
                height: 100,
                fit: pw.BoxFit.cover,
              ),
            ),
          ),
      ],
    );
  }

  // Versão segura do header Moderno. Usa um Container simples.
  pw.Widget _buildModernHeader(pw.Context context) {
    final p = data.personalData;
    if (p == null) return pw.SizedBox.shrink();

    // O Container agora vive dentro das margens da página.
    // Usamos padding para o espaço interno.
    return pw.Container(
      color: _accentPdfColor,
      padding: const pw.EdgeInsets.all(20),
      child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(p.name, style: pw.TextStyle(fontSize: options.fontSize + 20, fontWeight: pw.FontWeight.bold, color: PdfColors.white, lineSpacing: 2)),
            if (data.experiences.where((e) => e.isCurrent).isNotEmpty)
              pw.Text(data.experiences.firstWhere((e) => e.isCurrent).jobTitle, style: pw.TextStyle(color: PdfColors.white.shade(0.8), fontSize: options.fontSize + 4)),
            pw.Divider(color: PdfColors.white.shade(0.5), height: 24, thickness: 0.8),
            _buildContactAndOtherInfo(p, useWhiteText: true),
          ]
      ),
    );
  }


  pw.Widget _buildFunctionalHeader(pw.Context context) {
    final p = data.personalData;
    if (p == null) return pw.SizedBox.shrink();
    return pw.Column(
        children: [
          if (options.includePhoto && p.photoPath != null && File(p.photoPath!).existsSync())
            pw.ClipOval(
              child: pw.Image(
                pw.MemoryImage(File(p.photoPath!).readAsBytesSync()),
                width: 110,
                height: 110,
                fit: pw.BoxFit.cover,
              ),
            ),
          pw.SizedBox(height: 12),
          pw.Text(p.name, textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: options.fontSize + 16, fontWeight: pw.FontWeight.bold, color: _accentPdfColor)),
          pw.SizedBox(height: 8),
          _buildContactAndOtherInfo(p, isCentered: true),
        ]
    );
  }

  pw.Widget _buildMinimalistHeader(pw.Context context) {
    final p = data.personalData;
    if (p == null) return pw.SizedBox.shrink();
    return pw.Column(
        children: [
          pw.Text(p.name.toUpperCase(), textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: options.fontSize + 16, fontWeight: pw.FontWeight.bold, color: PdfColors.black, letterSpacing: 2)),
          pw.SizedBox(height: 8),
          _buildContactAndOtherInfo(p, isCentered: true, useMinimalistStyle: true),
        ]
    );
  }

  pw.Widget _buildSection({required String title, required pw.Widget child, bool useModernTitle = false, required PdfColor titleColor}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 20),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title, style: pw.TextStyle(fontSize: options.fontSize + (useModernTitle ? 2 : 4), fontWeight: pw.FontWeight.bold, color: titleColor, letterSpacing: useModernTitle ? 1.2 : 0)),
          useModernTitle ? pw.SizedBox(height: 6) : pw.Divider(color: titleColor.shade(0.7), height: 8, thickness: 1.5),
          pw.SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  pw.Widget _buildSummary() => pw.Text(data.personalData!.summary!, style: pw.TextStyle(fontSize: options.fontSize, lineSpacing: 1.5, color: PdfColors.black.shade(0.87)));

  pw.Widget _buildExperienceList() => pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: data.experiences.map((exp) => pw.Padding(padding: const pw.EdgeInsets.only(bottom: 14), child: _buildExperienceItem(exp))).toList());

  pw.Widget _buildExperienceItem(Experience exp) => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Expanded(child: pw.Text('${exp.jobTitle} at ${exp.company}', style: pw.TextStyle(fontSize: options.fontSize + 1, fontWeight: pw.FontWeight.bold))),
          if (exp.startDate != null)
            pw.Text('${_dateFormat.format(exp.startDate!)} - ${exp.isCurrent ? 'Presente' : (exp.endDate != null ? _dateFormat.format(exp.endDate!) : '')}', style: pw.TextStyle(fontSize: options.fontSize, color: PdfColors.grey700))
        ]),
        if(exp.location != null && exp.location!.isNotEmpty)
          pw.Text(exp.location!, style: pw.TextStyle(fontSize: options.fontSize, color: PdfColors.grey600, fontStyle: pw.FontStyle.italic)),
        if (exp.description?.isNotEmpty ?? false)
          pw.Padding(
              padding: const pw.EdgeInsets.only(top: 4),
              child: pw.Text(exp.description!, style: pw.TextStyle(fontSize: options.fontSize, lineSpacing: 1.4, color: PdfColors.black.shade(0.8)))
          ),
      ]
  );

  pw.Widget _buildEducationList() => pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: data.educations.map((edu) => pw.Padding(padding: const pw.EdgeInsets.only(bottom: 12), child: _buildEducationItem(edu))).toList());

  pw.Widget _buildEducationItem(Education edu) => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Expanded(child: pw.Text('${edu.degree} in ${edu.fieldOfStudy}', style: pw.TextStyle(fontSize: options.fontSize + 1, fontWeight: pw.FontWeight.bold))),
          if (edu.startDate != null)
            pw.Text('${_dateFormat.format(edu.startDate!)} - ${edu.inProgress ? 'Presente' : (edu.endDate != null ? _dateFormat.format(edu.endDate!) : '')}', style: pw.TextStyle(fontSize: options.fontSize, color: PdfColors.grey700))
        ]),
        pw.Text(edu.institution, style: pw.TextStyle(fontSize: options.fontSize, color: PdfColors.grey600, fontStyle: pw.FontStyle.italic)),
      ]
  );

  pw.Widget _buildSkillList() => pw.Wrap(
      spacing: 8, runSpacing: 4, children: [
    for (final skill in data.skills)
      pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: pw.BoxDecoration(
            color: _accentPdfColor.shade(0.1),
            border: pw.Border.all(color: _accentPdfColor.shade(0.2)),
            borderRadius: pw.BorderRadius.circular(12)
        ),
        child: pw.Text(skill.name, style: pw.TextStyle(fontSize: options.fontSize, color: PdfColors.black.shade(0.87))),
      )
  ]
  );

  pw.Widget _buildLanguageList() => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: data.languages.map((lang) =>
          pw.Text('• ${lang.languageName} (${lang.proficiency.displayName})', style: pw.TextStyle(fontSize: options.fontSize, lineSpacing: 1.6))
      ).toList()
  );

  pw.Widget _buildContactAndOtherInfo(PersonalData p, {bool isCentered = false, bool useWhiteText = false, bool useMinimalistStyle = false}) {
    final textColor = useWhiteText ? PdfColors.white.shade(0.9) : PdfColors.grey700;
    final linkColor = useWhiteText ? PdfColors.white : PdfColors.blue800;
    final separator = useMinimalistStyle ? ' | ' : ' • ';

    final contactItems = <pw.Widget>[];
    if (p.email.isNotEmpty) contactItems.add(pw.Text(p.email, style: pw.TextStyle(color: textColor)));
    if (p.phone?.isNotEmpty ?? false) contactItems.add(pw.Text(p.phone!, style: pw.TextStyle(color: textColor)));
    if (p.address?.isNotEmpty ?? false) contactItems.add(pw.Text(p.address!, style: pw.TextStyle(color: textColor)));
    if (options.includeSocialLinks && (p.linkedinUrl?.isNotEmpty ?? false)) contactItems.add(pw.UrlLink(destination: p.linkedinUrl!, child: pw.Text(p.linkedinUrl!.replaceAll('https://www.', ''), style: pw.TextStyle(decoration: pw.TextDecoration.underline, color: linkColor))));
    if (options.includeSocialLinks && (p.portfolioUrl?.isNotEmpty ?? false)) contactItems.add(pw.UrlLink(destination: p.portfolioUrl!, child: pw.Text(p.portfolioUrl!.replaceAll('https://www.', ''), style: pw.TextStyle(decoration: pw.TextDecoration.underline, color: linkColor))));

    final otherItems = <String>[];
    if (options.includeAvailability && p.hasTravelAvailability) otherItems.add('Disponibilidade para viagens');
    if (options.includeAvailability && p.hasRelocationAvailability) otherItems.add('Disponibilidade para mudança');
    if (options.includeVehicle && p.hasCar) otherItems.add('Possui carro');
    if (options.includeVehicle && p.hasMotorcycle) otherItems.add('Possui moto');
    if (options.includeLicense && p.licenseCategories.isNotEmpty) otherItems.add('CNH: ${p.licenseCategories.join(', ')}');

    final separatorWidget = pw.Text(separator, style: pw.TextStyle(color: textColor.shade(0.5)));

    List<pw.Widget> allItems = [];
    for (int i = 0; i < contactItems.length; i++) {
      allItems.add(contactItems[i]);
      if (i < contactItems.length - 1) {
        allItems.add(separatorWidget);
      }
    }
    if (otherItems.isNotEmpty && contactItems.isNotEmpty) {
      allItems.add(separatorWidget);
    }
    allItems.addAll(otherItems.map((item) => pw.Text(item, style: pw.TextStyle(fontSize: options.fontSize - 1, color: textColor))));

    return pw.Wrap(
      alignment: isCentered ? pw.WrapAlignment.center : pw.WrapAlignment.start,
      crossAxisAlignment: pw.WrapCrossAlignment.center,
      spacing: 8, runSpacing: 4,
      children: allItems,
    );
  }
}