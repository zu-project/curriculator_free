//C:\Users\ziofl\StudioProjects\curriculator_free\lib\features\export\pdf_generator_service.dart

import 'dart:io';
import 'dart:typed_data';

import 'package:curriculator_free/features/export/pdf_widgets.dart' as pdf_widgets;
import 'package:curriculator_free/models/education.dart';
import 'package:curriculator_free/models/experience.dart';
import 'package:curriculator_free/models/language.dart';
import 'package:curriculator_free/models/personal_data.dart';
import 'package:curriculator_free/models/skill.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

// (As classes DTO `CurriculumDataBundle` e `PdfExportOptions` permanecem as mesmas)
class CurriculumDataBundle {
  final PersonalData? personalData; final List<Experience> experiences;
  final List<Education> educations; final List<Skill> skills; final List<Language> languages;
  CurriculumDataBundle({this.personalData, required this.experiences, required this.educations, required this.skills, required this.languages});
}
class PdfExportOptions {
  final String templateName; final double baseFontSize; final String marginPreset;
  final PdfColor accentColor; final bool includePhoto; final bool includeSummary;
  final bool includeAvailability; final bool includeVehicle; final bool includeLicense;
  final bool includeSocialLinks;
  PdfExportOptions({this.templateName = 'Clássico', this.baseFontSize = 10.0, this.marginPreset = 'Normal', required this.accentColor, this.includePhoto = true, this.includeSummary = true, this.includeAvailability = true, this.includeVehicle = true, this.includeLicense = true, this.includeSocialLinks = true});
}

class PdfGeneratorService {
  final CurriculumDataBundle data;
  final PdfExportOptions options;
  late final pw.Font _regularFont, _boldFont, _italicFont, _boldItalicFont;

  PdfGeneratorService(this.data, this.options);

  Future<void> _loadFonts() async {
    _regularFont = await pw.Font.ttf(await rootBundle.load("assets/fonts/Roboto-Regular.ttf"));
    _boldFont = await pw.Font.ttf(await rootBundle.load("assets/fonts/Roboto-Bold.ttf"));
    _italicFont = await pw.Font.ttf(await rootBundle.load("assets/fonts/Roboto-Italic.ttf"));
    _boldItalicFont = await pw.Font.ttf(await rootBundle.load("assets/fonts/Roboto-BoldItalic.ttf"));
  }

  Future<Uint8List> generatePdf() async {
    await _loadFonts();
    final theme = pw.ThemeData.withFont(base: _regularFont, bold: _boldFont, italic: _italicFont, boldItalic: _boldItalicFont);

    switch (options.templateName) {
      case 'Moderno': return _buildModernoTemplate(theme);
      case 'Funcional': return _buildFuncionalTemplate(theme);
      case 'Minimalista': return _buildMinimalistaTemplate(theme);
      default: return _buildClassicoTemplate(theme);
    }
  }

  pw.EdgeInsets _getMargins() {
    switch (options.marginPreset) {
      case 'Estreita': return const pw.EdgeInsets.all(28);
      case 'Larga': return const pw.EdgeInsets.all(85);
      default: return const pw.EdgeInsets.all(56);
    }
  }

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

  // --- TEMPLATE BUILDER: CLÁSSICO ---
  Future<Uint8List> _buildClassicoTemplate(pw.ThemeData theme) async {
    final pdf = pw.Document(theme: theme);
    final pData = data.personalData;
    final extras = _buildExtrasList(pData);

    pw.ImageProvider? photoImage;
    if (options.includePhoto && pData?.photoPath != null && pData!.photoPath!.isNotEmpty) {
      final file = File(pData.photoPath!);
      if (await file.exists()) {
        photoImage = pw.MemoryImage(await file.readAsBytes());
      }
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: _getMargins(),
        build: (context) => [
          pdf_widgets.buildClassicHeader(pData, extras, options.baseFontSize, options.includeSocialLinks, photoImage),

          if (options.includeSummary && (pData?.summary?.isNotEmpty ?? false))
            pdf_widgets.Section(title: "Resumo Profissional", accentColor: options.accentColor, child: pw.Text(pData!.summary!, softWrap: true)),

          if (data.experiences.isNotEmpty)
            pdf_widgets.Section(title: "Experiência Profissional", accentColor: options.accentColor, child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: data.experiences.map((exp) => pdf_widgets.ExperienceItem(exp, options.baseFontSize)).toList())),

          if (data.educations.isNotEmpty)
            pdf_widgets.Section(title: "Formação Acadêmica", accentColor: options.accentColor, child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: data.educations.map((edu) => pdf_widgets.EducationItem(edu, options.baseFontSize)).toList())),

          if (data.skills.isNotEmpty)
            pdf_widgets.Section(title: "Habilidades", accentColor: options.accentColor, child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: data.skills.map((s) => pw.Text('• ${s.name}', softWrap: true)).toList())),

          if (data.languages.isNotEmpty)
            pdf_widgets.Section(title: "Idiomas", accentColor: options.accentColor, child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: data.languages.map((l) => pw.Text('• ${l.languageName}: ${l.proficiency.name}', softWrap: true)).toList())),
        ],
      ),
    );
    return pdf.save();
  }

  // --- TEMPLATE BUILDER: MODERNO (HEADER CURTO, CONTEÚDO EM SEÇÕES SEPARADAS) ---
  Future<Uint8List> _buildModernoTemplate(pw.ThemeData theme) async {
    final pdf = pw.Document(theme: theme);
    final pData = data.personalData;
    final extras = _buildExtrasList(pData);

    pw.ImageProvider? photoImage;
    if (options.includePhoto && pData?.photoPath != null && pData!.photoPath!.isNotEmpty) {
      final file = File(pData.photoPath!);
      if (await file.exists()) {
        photoImage = pw.MemoryImage(await file.readAsBytes());
      }
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: _getMargins(),
        build: (context) => [
          if (photoImage != null)
            _buildModernoHeaderComFoto(pData, photoImage, extras)
          else
            pdf_widgets.buildClassicHeader(pData, extras, options.baseFontSize, options.includeSocialLinks),

          if (options.includeSummary && (pData?.summary?.isNotEmpty ?? false))
            pdf_widgets.Section(title: "Resumo Profissional", accentColor: options.accentColor, child: pw.Text(pData!.summary!, softWrap: true)),

          if (data.skills.isNotEmpty)
            pdf_widgets.Section(title: "Habilidades", accentColor: options.accentColor, child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: data.skills.map((s) => pw.Text('• ${s.name}', softWrap: true)).toList())),

          if (data.languages.isNotEmpty)
            pdf_widgets.Section(title: "Idiomas", accentColor: options.accentColor, child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: data.languages.map((l) => pw.Text('• ${l.languageName}: ${l.proficiency.name}', softWrap: true)).toList())),

          if (data.experiences.isNotEmpty)
            pdf_widgets.Section(title: "Experiência Profissional", accentColor: options.accentColor, child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: data.experiences.map((exp) => pdf_widgets.ExperienceItem(exp, options.baseFontSize)).toList())),

          if (data.educations.isNotEmpty)
            pdf_widgets.Section(title: "Formação Acadêmica", accentColor: options.accentColor, child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: data.educations.map((edu) => pdf_widgets.EducationItem(edu, options.baseFontSize)).toList())),
        ],
      ),
    );
    return pdf.save();
  }

  // --- TEMPLATE BUILDER: FUNCIONAL (SKILLS PRIMEIRO, COM COLUMN) ---
  Future<Uint8List> _buildFuncionalTemplate(pw.ThemeData theme) async {
    final pdf = pw.Document(theme: theme);
    final pData = data.personalData;
    final extras = _buildExtrasList(pData);

    pw.ImageProvider? photoImage;
    if (options.includePhoto && pData?.photoPath != null && pData!.photoPath!.isNotEmpty) {
      final file = File(pData.photoPath!);
      if (await file.exists()) {
        photoImage = pw.MemoryImage(await file.readAsBytes());
      }
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: _getMargins(),
        build: (context) => [
          pdf_widgets.buildClassicHeader(pData, extras, options.baseFontSize, options.includeSocialLinks, photoImage),

          if (data.skills.isNotEmpty)
            pdf_widgets.Section(
              title: "Habilidades Principais",
              accentColor: options.accentColor,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: data.skills
                    .map((s) => pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 4),
                  padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: pw.BoxDecoration(border: pw.Border.all(color: options.accentColor), borderRadius: pw.BorderRadius.circular(4)),
                  child: pw.Text(s.name, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: options.baseFontSize)),
                ))
                    .toList(),
              ),
            ),

          if (options.includeSummary && (pData?.summary?.isNotEmpty ?? false))
            pdf_widgets.Section(title: "Resumo Profissional", accentColor: options.accentColor, child: pw.Text(pData!.summary!, softWrap: true)),

          if (data.experiences.isNotEmpty)
            pdf_widgets.Section(title: "Experiência Profissional", accentColor: options.accentColor, child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: data.experiences.map((exp) => pdf_widgets.ExperienceItem(exp, options.baseFontSize)).toList())),

          if (data.educations.isNotEmpty)
            pdf_widgets.Section(title: "Formação Acadêmica", accentColor: options.accentColor, child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: data.educations.map((edu) => pdf_widgets.EducationItem(edu, options.baseFontSize)).toList())),

          if (data.languages.isNotEmpty)
            pdf_widgets.Section(title: "Idiomas", accentColor: options.accentColor, child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: data.languages.map((l) => pw.Text('• ${l.languageName}: ${l.proficiency.name}', softWrap: true)).toList())),
        ],
      ),
    );
    return pdf.save();
  }

  // --- TEMPLATE BUILDER: MINIMALISTA ---
  Future<Uint8List> _buildMinimalistaTemplate(pw.ThemeData theme) async {
    final pdf = pw.Document(theme: theme);
    final pData = data.personalData;
    final extras = _buildExtrasList(pData);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: _getMargins(),
        build: (context) => [
          _buildMinimalistaHeader(pData, extras),

          if (options.includeSummary && (pData?.summary?.isNotEmpty ?? false))
            pdf_widgets.SimpleSection(title: "Resumo", child: pw.Text(pData!.summary!, softWrap: true)),

          if (data.experiences.isNotEmpty)
            pdf_widgets.SimpleSection(title: "Experiência", child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: data.experiences.map((exp) => pdf_widgets.ExperienceItem(exp, options.baseFontSize)).toList())),

          if (data.educations.isNotEmpty)
            pdf_widgets.SimpleSection(title: "Formação", child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: data.educations.map((edu) => pdf_widgets.EducationItem(edu, options.baseFontSize)).toList())),

          if (data.skills.isNotEmpty)
            pdf_widgets.SimpleSection(title: "Habilidades", child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: data.skills.map((s) => pw.Text('• ${s.name}', softWrap: true)).toList())),

          if (data.languages.isNotEmpty)
            pdf_widgets.SimpleSection(title: "Idiomas", child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: data.languages.map((l) => pw.Text('• ${l.languageName}: ${l.proficiency.name}', softWrap: true)).toList())),
        ],
      ),
    );
    return pdf.save();
  }

  // --- HEADER MINIMALISTA ---
  pw.Widget _buildMinimalistaHeader(PersonalData? pData, List<String> extras) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 20),
      child: pw.Center(
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Text(pData?.name.toUpperCase() ?? 'SEU NOME', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: options.baseFontSize + 14)),
            pw.SizedBox(height: 10),
            pw.Text(pData?.email ?? '', softWrap: true, style: pw.TextStyle(fontSize: options.baseFontSize)),
            if (extras.isNotEmpty) ...[
              pw.SizedBox(height: 5),
              pw.Text(extras.join(' | '), softWrap: true, style: pw.TextStyle(fontSize: options.baseFontSize - 1)),
            ],
          ],
        ),
      ),
    );
  }

  // --- HEADER MODERNO COM FOTO (CURTO, SEM CONTEÚDO LONGO) ---
  pw.Widget _buildModernoHeaderComFoto(PersonalData? pData, pw.ImageProvider photoImage, List<String> extras) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 20),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 180,
            padding: const pw.EdgeInsets.only(right: 15),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisSize: pw.MainAxisSize.min,
              children: [
                pw.ClipOval(child: pw.SizedBox(width: 120, height: 120, child: pw.Image(photoImage, fit: pw.BoxFit.cover))),
                pw.SizedBox(height: 10),
                pdf_widgets.SidebarSection(title: "Contato", child: _buildContactInfo(pData)),
                if (extras.isNotEmpty) pdf_widgets.SidebarSection(title: "Extras", child: _buildExtrasColumn(extras)),
              ],
            ),
          ),
          pw.Expanded(
            child: pw.Text(pData?.name.toUpperCase() ?? "SEU NOME", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: options.baseFontSize + 14, color: options.accentColor)),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildContactInfo(PersonalData? pData) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        if (pData?.email.isNotEmpty ?? false) pw.Text(pData!.email, softWrap: true, style: pw.TextStyle(fontSize: options.baseFontSize - 1)),
        if (pData?.phone?.isNotEmpty ?? false) pw.Text(pData!.phone!, softWrap: true, style: pw.TextStyle(fontSize: options.baseFontSize - 1)),
        if (pData?.address?.isNotEmpty ?? false) pw.Text(pData!.address!, softWrap: true, style: pw.TextStyle(fontSize: options.baseFontSize - 1)),
        if (options.includeSocialLinks && (pData?.linkedinUrl?.isNotEmpty ?? false)) pw.Text(pData!.linkedinUrl!, softWrap: true, style: pw.TextStyle(fontSize: options.baseFontSize - 1)),
        if (options.includeSocialLinks && (pData?.portfolioUrl?.isNotEmpty ?? false)) pw.Text(pData!.portfolioUrl!, softWrap: true, style: pw.TextStyle(fontSize: options.baseFontSize - 1)),
      ],
    );
  }

  pw.Widget _buildExtrasColumn(List<String> extras) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: extras.map((e) => pw.Text("• $e", softWrap: true, style: pw.TextStyle(fontSize: options.baseFontSize - 1))).toList(),
    );
  }
}