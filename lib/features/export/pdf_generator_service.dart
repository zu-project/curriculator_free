// lib/features/export/pdf_generator_service.dart
// VERSÃO FINAL E CORRIGIDA: Carrega todas as fontes necessárias.

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'cv_template.dart';
import 'package:curriculator_free/models/education.dart';
import 'package:curriculator_free/models/experience.dart';
import 'package:curriculator_free/models/language.dart';
import 'package:curriculator_free/models/personal_data.dart';
import 'package:curriculator_free/models/skill.dart';

class PdfGeneratorService {
  final CurriculumDataBundle data;
  final TemplateOptions options;
  final _dateFormat = DateFormat('MM/yyyy', 'pt_BR');

  PdfGeneratorService(this.data, this.options);

  Future<Uint8List> generatePdf() async {
    final doc = pw.Document(author: 'Curriculator Free', title: 'Currículo de ${data.personalData?.name}');

    // --- INÍCIO DA CORREÇÃO: CARREGAR TODAS AS VARIANTES DA FONTE ---
    final fontRegular = await rootBundle.load("assets/fonts/Roboto-Regular.ttf");
    final fontBold = await rootBundle.load("assets/fonts/Roboto-Bold.ttf");
    final fontItalic = await rootBundle.load("assets/fonts/Roboto-Italic.ttf");
    final fontBoldItalic = await rootBundle.load("assets/fonts/Roboto-BoldItalic.ttf");

    final theme = pw.ThemeData.withFont(
      base: pw.Font.ttf(fontRegular),
      bold: pw.Font.ttf(fontBold),
      italic: pw.Font.ttf(fontItalic),
      boldItalic: pw.Font.ttf(fontBoldItalic),
    );
    // --- FIM DA CORREÇÃO ---

    doc.addPage(
      pw.MultiPage(
          theme: theme,
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.fromLTRB(
              options.margins.left,
              options.margins.top,
              options.margins.right,
              options.margins.bottom
          ),
          build: (context) {
            final List<pw.Widget> content = [];

            // O template moderno tem um cabeçalho que precisa ser tratado fora do fluxo normal
            if (options.templateName != 'Moderno') {
              content.add(_buildHeader());
            }

            content.addAll(_buildCoreContent());

            return content;
          },
          // O cabeçalho do template moderno é colocado aqui para que ele possa "quebrar" as margens
          header: (context) {
            if (options.templateName == 'Moderno') {
              return _buildModernHeader();
            }
            return pw.SizedBox.shrink();
          }
      ),
    );

    return await doc.save();
  }

  // O resto do arquivo permanece o mesmo, a lógica de layout já está correta.
  pw.Widget _buildHeader() {
    switch (options.templateName) {
      case 'Funcional': return _buildFunctionalHeader();
      case 'Minimalista': return _buildMinimalistHeader();
      default: return _buildClassicHeader();
    }
  }

  List<pw.Widget> _buildCoreContent() {
    final bool useModernTitle = ['Moderno', 'Funcional'].contains(options.templateName);
    final PdfColor titleColor = options.templateName == 'Minimalista' ? PdfColors.black : PdfColor.fromInt(options.accentColor.value);
    final List<pw.Widget> sections = [];
    if (options.includeSummary && (data.personalData?.summary?.isNotEmpty ?? false)) { sections.add(_buildSection(title: useModernTitle ? 'RESUMO' : 'Resumo Profissional', useModernTitle: useModernTitle, titleColor: titleColor, child: _buildSummary())); }
    if (data.experiences.isNotEmpty) { sections.add(_buildSection(title: useModernTitle ? 'EXPERIÊNCIA' : 'Experiência Profissional', useModernTitle: useModernTitle, titleColor: titleColor, child: _buildExperienceList())); }
    if (data.educations.isNotEmpty) { sections.add(_buildSection(title: useModernTitle ? 'FORMAÇÃO' : 'Formação Acadêmica', useModernTitle: useModernTitle, titleColor: titleColor, child: _buildEducationList())); }
    if (data.skills.isNotEmpty) { sections.add(_buildSection(title: useModernTitle ? 'HABILIDADES' : 'Habilidades', useModernTitle: useModernTitle, titleColor: titleColor, child: _buildSkillList())); }
    if (data.languages.isNotEmpty) { sections.add(_buildSection(title: useModernTitle ? 'IDIOMAS' : 'Idiomas', useModernTitle: useModernTitle, titleColor: titleColor, child: _buildLanguageList())); }
    return sections;
  }

  pw.Widget _buildClassicHeader() {
    final p = data.personalData;
    if (p == null) return pw.SizedBox.shrink();
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 20),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(p.name, style: pw.TextStyle(fontSize: options.fontSize + 16, fontWeight: pw.FontWeight.bold, color: PdfColor.fromInt(options.accentColor.value))),
                pw.SizedBox(height: 12),
                _buildContactAndOtherInfo(p),
              ],
            ),
          ),
          if (options.includePhoto && p.photoPath != null && File(p.photoPath!).existsSync())
            pw.Padding(
              padding: const pw.EdgeInsets.only(left: 24),
              child: pw.ClipOval(child: pw.Image(pw.MemoryImage(File(p.photoPath!).readAsBytesSync()), width: 100, height: 100, fit: pw.BoxFit.cover)),
            ),
        ],
      ),
    );
  }

  pw.Widget _buildModernHeader() {
    final p = data.personalData;
    if (p == null) return pw.SizedBox.shrink();
    final accent = PdfColor.fromInt(options.accentColor.value);
    return pw.Container(
      color: accent,
      margin: const pw.EdgeInsets.only(bottom: 20),
      padding: pw.EdgeInsets.fromLTRB(options.margins.left, options.margins.top, options.margins.right, 20),
      child: pw.Column(
          mainAxisSize: pw.MainAxisSize.min,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(p.name, style: pw.TextStyle(fontSize: options.fontSize + 20, fontWeight: pw.FontWeight.bold, color: PdfColors.white, height: 1.2)),
            if (data.experiences.where((e) => e.isCurrent).isNotEmpty)
              pw.Text(data.experiences.firstWhere((e) => e.isCurrent).jobTitle, style: pw.TextStyle(color: PdfColors.white.shade(0.8), fontSize: options.fontSize + 4)),
            pw.Divider(color: PdfColors.white.shade(0.5), height: 24, thickness: 0.8),
            _buildContactAndOtherInfo(p, useWhiteText: true),
          ]
      ),
    );
  }

  pw.Widget _buildFunctionalHeader() {
    final p = data.personalData;
    if (p == null) return pw.SizedBox.shrink();
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 20),
      child: pw.Column(
          children: [
            if (options.includePhoto && p.photoPath != null && File(p.photoPath!).existsSync())
              pw.ClipOval(child: pw.Image(pw.MemoryImage(File(p.photoPath!).readAsBytesSync()), width: 110, height: 110, fit: pw.BoxFit.cover)),
            pw.SizedBox(height: 12),
            pw.Text(p.name, textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: options.fontSize + 16, fontWeight: pw.FontWeight.bold, color: PdfColor.fromInt(options.accentColor.value))),
            pw.SizedBox(height: 8),
            _buildContactAndOtherInfo(p, isCentered: true),
          ]
      ),
    );
  }

  pw.Widget _buildMinimalistHeader() {
    final p = data.personalData;
    if (p == null) return pw.SizedBox.shrink();
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 20),
      child: pw.Column(
          children: [
            pw.Text(p.name.toUpperCase(), textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: options.fontSize + 16, fontWeight: pw.FontWeight.bold, color: PdfColors.black, letterSpacing: 2)),
            pw.SizedBox(height: 8),
            _buildContactAndOtherInfo(p, isCentered: true, useMinimalistStyle: true),
          ]
      ),
    );
  }

  pw.Widget _buildSection({required String title, required pw.Widget child, bool useModernTitle = false, required PdfColor titleColor}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 15, bottom: 5),
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

  pw.Widget _buildSummary() => pw.Text(data.personalData!.summary!, style: pw.TextStyle(fontSize: options.fontSize, height: 1.5, color: PdfColors.grey800));
  pw.Widget _buildExperienceList() => pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: data.experiences.map((exp) => pw.Padding(padding: const pw.EdgeInsets.only(bottom: 14), child: _buildExperienceItem(exp))).toList());
  pw.Widget _buildExperienceItem(Experience exp) => pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
    pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [ pw.Expanded(child: pw.Text('${exp.jobTitle} at ${exp.company}', style: pw.TextStyle(fontSize: options.fontSize + 1, fontWeight: pw.FontWeight.bold))), if (exp.startDate != null) pw.Text('${_dateFormat.format(exp.startDate!)} - ${exp.isCurrent ? 'Presente' : (exp.endDate != null ? _dateFormat.format(exp.endDate!) : '')}', style: pw.TextStyle(fontSize: options.fontSize, color: PdfColors.grey700)) ]),
    if(exp.location != null && exp.location!.isNotEmpty) pw.Text(exp.location!, style: pw.TextStyle(fontSize: options.fontSize, color: PdfColors.grey600, fontStyle: pw.FontStyle.italic)),
    if (exp.description?.isNotEmpty ?? false) pw.Padding(padding: const pw.EdgeInsets.only(top: 4), child: pw.Text(exp.description!, style: pw.TextStyle(fontSize: options.fontSize, height: 1.4, color: PdfColors.grey800))),
  ]);
  pw.Widget _buildEducationList() => pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: data.educations.map((edu) => pw.Padding(padding: const pw.EdgeInsets.only(bottom: 12), child: _buildEducationItem(edu))).toList());
  pw.Widget _buildEducationItem(Education edu) => pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
    pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [ pw.Expanded(child: pw.Text('${edu.degree} in ${edu.fieldOfStudy}', style: pw.TextStyle(fontSize: options.fontSize + 1, fontWeight: pw.FontWeight.bold))), if (edu.startDate != null) pw.Text('${_dateFormat.format(edu.startDate!)} - ${edu.inProgress ? 'Presente' : (edu.endDate != null ? _dateFormat.format(edu.endDate!) : '')}', style: pw.TextStyle(fontSize: options.fontSize, color: PdfColors.grey700)) ]),
    pw.Text(edu.institution, style: pw.TextStyle(fontSize: options.fontSize, color: PdfColors.grey600, fontStyle: pw.FontStyle.italic)),
  ]);
  pw.Widget _buildSkillList() => pw.Wrap(spacing: 8, runSpacing: 4, children: [ for (final skill in data.skills) pw.Container(padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: pw.BoxDecoration(color: PdfColor.fromInt(options.accentColor.value).shade(0.1), borderRadius: pw.BorderRadius.circular(4)), child: pw.Text(skill.name, style: pw.TextStyle(fontSize: options.fontSize, color: PdfColors.black))) ]);
  pw.Widget _buildLanguageList() => pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: data.languages.map((lang) => pw.Text('• ${lang.languageName} (${lang.proficiency.displayName})', style: pw.TextStyle(fontSize: options.fontSize, height: 1.6))).toList());
  pw.Widget _buildContactAndOtherInfo(PersonalData p, {bool isCentered = false, bool useWhiteText = false, bool useMinimalistStyle = false}) {
    final textColor = useWhiteText ? PdfColors.white.shade(0.9) : PdfColors.grey700;
    final linkColor = useWhiteText ? PdfColors.white : PdfColors.blue800;
    final contactWidgets = <pw.Widget>[];
    if (p.email.isNotEmpty) contactWidgets.add(pw.Text(p.email, style: pw.TextStyle(color: textColor)));
    if (p.phone?.isNotEmpty ?? false) contactWidgets.add(pw.Text(p.phone!, style: pw.TextStyle(color: textColor)));
    if (p.address?.isNotEmpty ?? false) contactWidgets.add(pw.Text(p.address!, style: pw.TextStyle(color: textColor)));
    if (options.includeSocialLinks && (p.linkedinUrl?.isNotEmpty ?? false)) { contactWidgets.add(pw.UrlLink(destination: p.linkedinUrl!, child: pw.Text(p.linkedinUrl!.replaceAll('https://www.', '').replaceAll('https://', ''), style: pw.TextStyle(decoration: pw.TextDecoration.underline, color: linkColor)))); }
    if (options.includeSocialLinks && (p.portfolioUrl?.isNotEmpty ?? false)) { contactWidgets.add(pw.UrlLink(destination: p.portfolioUrl!, child: pw.Text(p.portfolioUrl!.replaceAll('https://www.', '').replaceAll('https://', ''), style: pw.TextStyle(decoration: pw.TextDecoration.underline, color: linkColor)))); }
    final otherItems = <String>[];
    if (options.includeAvailability && p.hasTravelAvailability) otherItems.add('Disponibilidade para viagens');
    if (options.includeAvailability && p.hasRelocationAvailability) otherItems.add('Disponibilidade para mudança');
    if (options.includeVehicle && p.hasCar) otherItems.add('Possui carro');
    if (options.includeVehicle && p.hasMotorcycle) otherItems.add('Possui moto');
    if (options.includeLicense && p.licenseCategories.isNotEmpty) otherItems.add('CNH: ${p.licenseCategories.join(', ')}');
    final separator = pw.Text(useMinimalistStyle ? ' | ' : ' • ', style: pw.TextStyle(color: textColor.shade(0.5)));
    final List<pw.Widget> children = [];
    for (int i = 0; i < contactWidgets.length; i++) { children.add(contactWidgets[i]); if (i < contactWidgets.length - 1) { children.add(separator); } }
    if (contactWidgets.isNotEmpty && otherItems.isNotEmpty) { children.add(separator); }
    children.addAll(otherItems.map((item) => pw.Text(item, style: pw.TextStyle(fontSize: options.fontSize - 1, color: textColor))));
    return pw.Wrap(alignment: isCentered ? pw.WrapAlignment.center : pw.WrapAlignment.start, crossAxisAlignment: pw.WrapCrossAlignment.center, spacing: 8, runSpacing: 4, children: children);
  }
}