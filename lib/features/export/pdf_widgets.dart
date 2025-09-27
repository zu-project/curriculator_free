// C:\Users\ziofl\StudioProjects\curriculator_free\lib\features\export\pdf_widgets.dart
// VERSÃO FINAL CORRIGIDA

import 'dart:io';
import 'package:curriculator_free/features/export/pdf_generator_service.dart';
import 'package:curriculator_free/models/education.dart';
import 'package:curriculator_free/models/experience.dart';
import 'package:curriculator_free/models/language.dart';
import 'package:curriculator_free/models/personal_data.dart';
import 'package:curriculator_free/models/skill.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

// --- CORREÇÃO 1: Classe auxiliar para os ícones ---
// Mapeia os ícones do Material para seus code points, permitindo seu uso no PDF.
class PdfIcons {
  static const pw.IconData email = pw.IconData(0xe22a);
  static const pw.IconData phone = pw.IconData(0xe4a2);
  static const pw.IconData location_on = pw.IconData(0xe3ab);
  static const pw.IconData link = pw.IconData(0xe380);
  static const pw.IconData public = pw.IconData(0xe55b);
}

/// Serviço que contém a lógica de construção dos widgets e layouts para os templates de PDF.
class PdfLayoutService {
  final CurriculumDataBundle data;
  final PdfExportOptions options;
  final pw.ThemeData theme;
  final double _baseFontSize;
  final _dateFormat = DateFormat('MM/yyyy', 'pt_BR');

  PdfLayoutService(this.data, this.options, this.theme) : _baseFontSize = options.baseFontSize;

  // ===========================================================================
  // === TEMPLATE BUILDER: CLÁSSICO
  // ===========================================================================
  List<pw.Widget> buildClassicTemplate(pw.Context context) {
    return [
      _buildClassicHeader(),
      pw.SizedBox(height: 0.8 * PdfPageFormat.cm),
      if (options.includeSummary && (data.personalData?.summary?.isNotEmpty ?? false))
        _buildSection(
          title: 'Resumo Profissional',
          child: _buildSummary(),
        ),
      if (data.experiences.isNotEmpty)
        _buildSection(
          title: 'Experiência Profissional',
          child: _buildExperienceList(),
        ),
      if (data.educations.isNotEmpty)
        _buildSection(
          title: 'Formação Acadêmica',
          child: _buildEducationList(),
        ),
      if (data.skills.isNotEmpty || data.languages.isNotEmpty)
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            if (data.skills.isNotEmpty)
              pw.Expanded(
                child: _buildSection(
                  title: 'Habilidades',
                  child: _buildSkillList(),
                ),
              ),
            if (data.skills.isNotEmpty && data.languages.isNotEmpty)
              pw.SizedBox(width: 1.5 * PdfPageFormat.cm),
            if (data.languages.isNotEmpty)
              pw.Expanded(
                child: _buildSection(
                  title: 'Idiomas',
                  child: _buildLanguageList(),
                ),
              )
          ],
        ),
      _buildOtherInfoSection(),
    ];
  }

  // ===========================================================================
  // === TEMPLATE BUILDER: MODERNO (DUAS COLUNAS)
  // ===========================================================================
  List<pw.Widget> buildModernTemplate(pw.Context context) {
    const sidebarWidth = 160.0;
    return [
      _buildModernHeader(),
      pw.SizedBox(height: 0.8 * PdfPageFormat.cm),
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // --- COLUNA PRINCIPAL (ESQUERDA) ---
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (options.includeSummary && (data.personalData?.summary?.isNotEmpty ?? false))
                  _buildSection(
                    title: 'RESUMO',
                    useModernTitle: true,
                    child: _buildSummary(),
                  ),
                if (data.experiences.isNotEmpty)
                  _buildSection(
                    title: 'EXPERIÊNCIA',
                    useModernTitle: true,
                    child: _buildExperienceList(),
                  ),
                if (data.educations.isNotEmpty)
                  _buildSection(
                    title: 'FORMAÇÃO',
                    useModernTitle: true,
                    child: _buildEducationList(),
                  ),
              ],
            ),
          ),
          pw.SizedBox(width: 1 * PdfPageFormat.cm),
          // --- SIDEBAR (DIREITA) ---
          pw.SizedBox(
            width: sidebarWidth,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildSection(
                  title: 'CONTATO',
                  useModernTitle: true,
                  child: _buildModernContactInfo(),
                ),
                if (data.skills.isNotEmpty)
                  _buildSection(
                    title: 'HABILIDADES',
                    useModernTitle: true,
                    child: _buildSkillList(isCompact: true),
                  ),
                if (data.languages.isNotEmpty)
                  _buildSection(
                    title: 'IDIOMAS',
                    useModernTitle: true,
                    child: _buildLanguageList(isCompact: true),
                  ),
                if(options.includeAvailability || options.includeLicense || options.includeVehicle)
                  _buildSection(
                    title: 'OUTROS',
                    useModernTitle: true,
                    child: _buildOtherInfoSection(isCompact: true),
                  )
              ],
            ),
          ),
        ],
      )
    ];
  }


  // ===========================================================================
  // === WIDGETS DE CABEÇALHO
  // ===========================================================================
  pw.Widget _buildClassicHeader() {
    final p = data.personalData;
    if (p == null) return pw.Container();
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          flex: 4,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                p.name.toUpperCase(),
                style: pw.TextStyle(
                  fontSize: _baseFontSize + 14,
                  fontWeight: pw.FontWeight.bold,
                  color: options.accentColor,
                ),
              ),
              pw.SizedBox(height: 0.3 * PdfPageFormat.cm),
              pw.Wrap(
                spacing: 12,
                runSpacing: 4,
                children: [
                  _buildIconText(PdfIcons.email, p.email),
                  if (p.phone?.isNotEmpty ?? false) _buildIconText(PdfIcons.phone, p.phone!),
                  if (p.address?.isNotEmpty ?? false) _buildIconText(PdfIcons.location_on, p.address!),
                ],
              ),
              if(options.includeSocialLinks)
                pw.Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    children: [
                      if (p.linkedinUrl?.isNotEmpty ?? false)
                        _buildLink(PdfIcons.link, p.linkedinUrl!),
                      if (p.portfolioUrl?.isNotEmpty ?? false)
                        _buildLink(PdfIcons.public, p.portfolioUrl!),
                    ]
                ),
            ],
          ),
        ),
        if (options.includePhoto && (p.photoPath?.isNotEmpty ?? false) && File(p.photoPath!).existsSync())
          pw.SizedBox(
            width: 3.0 * PdfPageFormat.cm,
            height: 3.0 * PdfPageFormat.cm,
            child: pw.ClipOval(child: pw.Image(pw.MemoryImage(File(p.photoPath!).readAsBytesSync()))),
          ),
      ],
    );
  }

  pw.Widget _buildModernHeader() {
    final p = data.personalData;
    if (p == null) return pw.Container();
    return pw.Container(
      color: options.accentColor,
      padding: const pw.EdgeInsets.all(16),
      child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            if (options.includePhoto && (p.photoPath?.isNotEmpty ?? false) && File(p.photoPath!).existsSync())
              pw.SizedBox(
                  width: 3.5 * PdfPageFormat.cm,
                  height: 3.5 * PdfPageFormat.cm,
                  child: pw.ClipOval(
                    child: pw.Image(
                        pw.MemoryImage(File(p.photoPath!).readAsBytesSync()),
                        fit: pw.BoxFit.cover
                    ),
                  )
              ),
            if (options.includePhoto && (p.photoPath?.isNotEmpty ?? false) && File(p.photoPath!).existsSync())
              pw.SizedBox(width: 0.8 * PdfPageFormat.cm),
            pw.Expanded(
              child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      p.name,
                      style: pw.TextStyle(
                        fontSize: _baseFontSize + 20,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                        height: 1.2, // --- CORREÇÃO: lineHeight -> height ---
                      ),
                    ),
                    // Se houver uma experiência, pega o cargo atual
                    if(data.experiences.where((e) => e.isCurrent).isNotEmpty)
                      pw.Text(
                        data.experiences.firstWhere((e) => e.isCurrent).jobTitle,
                        style: pw.TextStyle(
                          // --- CORREÇÃO: withOpacity -> Construtor PdfColor ---
                          color: PdfColor(PdfColors.white.red, PdfColors.white.green, PdfColors.white.blue, 0.8),
                          fontSize: _baseFontSize + 4,
                        ),
                      ),
                  ]
              ),
            )
          ]
      ),
    );
  }

  // ===========================================================================
  // === WIDGETS DE SEÇÃO E CONTEÚDO
  // ===========================================================================
  pw.Widget _buildSection({
    required String title,
    required pw.Widget child,
    bool useModernTitle = false,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        useModernTitle
            ? pw.Text(
          title.toUpperCase(),
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: _baseFontSize + 2,
            color: options.accentColor,
          ),
        )
            : pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: _baseFontSize + 4,
            fontWeight: pw.FontWeight.bold,
            color: options.accentColor,
          ),
        ),
        // --- CORREÇÃO: withOpacity -> Construtor PdfColor ---
        useModernTitle ? pw.SizedBox(height: 6) : pw.Divider(color: PdfColor(options.accentColor.red, options.accentColor.green, options.accentColor.blue, 0.7), height: 8, thickness: 1.5),
        pw.SizedBox(height: 0.3 * PdfPageFormat.cm),
        child,
        pw.SizedBox(height: 0.7 * PdfPageFormat.cm),
      ],
    );
  }

  pw.Widget _buildSummary() {
    return pw.Text(
      data.personalData?.summary ?? '',
      // --- CORREÇÃO: lineHeight -> height ---
      style: pw.TextStyle(fontSize: _baseFontSize, height: 1.4),
    );
  }

  pw.Widget _buildExperienceList() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        for (final exp in data.experiences) ...[
          _buildExperienceItem(exp),
          pw.SizedBox(height: 0.5 * PdfPageFormat.cm)
        ],
      ],
    );
  }

  pw.Widget _buildExperienceItem(Experience exp) {
    return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Text(
                    exp.jobTitle,
                    style: pw.TextStyle(fontSize: _baseFontSize + 1, fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.SizedBox(width: 8),
                if (exp.startDate != null)
                  pw.Text(
                    '${_dateFormat.format(exp.startDate!)} - ${exp.isCurrent ? 'Presente' : (exp.endDate != null ? _dateFormat.format(exp.endDate!) : '')}',
                    style: pw.TextStyle(fontSize: _baseFontSize),
                  )
              ]
          ),
          pw.Text(
            '${exp.company}${exp.location != null && exp.location!.isNotEmpty ? ' | ${exp.location}' : ''}',
            style: pw.TextStyle(fontSize: _baseFontSize, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700),
          ),
          if(exp.description?.isNotEmpty ?? false)
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 4, left: 10),
              child:  pw.Text(
                exp.description!,
                // --- CORREÇÃO: lineHeight -> height ---
                style: pw.TextStyle(fontSize: _baseFontSize, height: 1.3),
              ),
            ),
        ]
    );
  }

  pw.Widget _buildEducationList() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        for (final edu in data.educations) ...[
          _buildEducationItem(edu),
          pw.SizedBox(height: 0.5 * PdfPageFormat.cm)
        ],
      ],
    );
  }

  pw.Widget _buildEducationItem(Education edu) {
    return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Text(
                    '${edu.degree} em ${edu.fieldOfStudy}',
                    style: pw.TextStyle(fontSize: _baseFontSize + 1, fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.SizedBox(width: 8),
                if (edu.startDate != null)
                  pw.Text(
                    '${_dateFormat.format(edu.startDate!)} - ${edu.inProgress ? 'Presente' : (edu.endDate != null ? _dateFormat.format(edu.endDate!) : '')}',
                    style: pw.TextStyle(fontSize: _baseFontSize),
                  )
              ]
          ),
          pw.Text(
            edu.institution,
            style: pw.TextStyle(fontSize: _baseFontSize, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700),
          ),
          if(edu.description?.isNotEmpty ?? false)
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 4),
              child:  pw.Text(
                edu.description!,
                // --- CORREÇÃO: lineHeight -> height ---
                style: pw.TextStyle(fontSize: _baseFontSize, height: 1.3),
              ),
            ),
        ]
    );
  }

  pw.Widget _buildSkillList({bool isCompact = false}) {
    if(isCompact) {
      return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            for (final skill in data.skills)
              pw.Text('• ${skill.name}', style: pw.TextStyle(fontSize: _baseFontSize, height: 1.5))
          ]
      );
    }
    return pw.Wrap(
        spacing: 8,
        runSpacing: 6,
        children: [
          for(final skill in data.skills)
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: pw.BoxDecoration(
                // --- CORREÇÃO: withOpacity -> Construtor PdfColor ---
                color: PdfColor(options.accentColor.red, options.accentColor.green, options.accentColor.blue, 0.15),
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Text(
                skill.name,
                // --- CORREÇÃO: darken -> shade ---
                style: pw.TextStyle(fontSize: _baseFontSize, color: options.accentColor.shade(0.7)),
              ),
            )
        ]
    );
  }

  pw.Widget _buildLanguageList({bool isCompact = false}) {
    return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          for (final lang in data.languages)
            pw.Text(
                '${lang.languageName} (${lang.proficiency.displayName})',
                style: pw.TextStyle(fontSize: _baseFontSize, height: isCompact ? 1.5 : 1.3)
            )
        ]
    );
  }

  pw.Widget _buildOtherInfoSection({bool isCompact = false}) {
    final p = data.personalData;
    if (p == null) return pw.Container();
    final items = <String>[];
    if(options.includeAvailability && p.hasTravelAvailability) items.add('Disponibilidade para viagens');
    if(options.includeAvailability && p.hasRelocationAvailability) items.add('Disponibilidade para mudança');
    if(options.includeVehicle && p.hasCar) items.add('Possui carro');
    if(options.includeVehicle && p.hasMotorcycle) items.add('Possui moto');
    if(options.includeLicense && p.licenseCategories.isNotEmpty) items.add('CNH: ${p.licenseCategories.join(', ')}');

    if (items.isEmpty) return pw.Container();
    if(isCompact) {
      return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: items.map((i) => pw.Text('• $i', style: pw.TextStyle(fontSize: _baseFontSize, height: 1.5))).toList()
      );
    }

    return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(height: 0.5 * PdfPageFormat.cm),
          pw.Center(
            child: pw.Text(
                items.join('  •  '),
                style: pw.TextStyle(fontSize: _baseFontSize, color: PdfColors.grey700),
                textAlign: pw.TextAlign.center
            ),
          )
        ]
    );
  }

  pw.Widget _buildModernContactInfo() {
    final p = data.personalData;
    if (p == null) return pw.Container();
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // p.email é não-nulo no modelo, então não precisa de verificação
        _buildIconText(PdfIcons.email, p.email, isCompact: true),

        // Condição CORRIGIDA para o telefone
        if (p.phone?.isNotEmpty ?? false)
          _buildIconText(PdfIcons.phone, p.phone!, isCompact: true),

        // Condição CORRIGIDA para o endereço
        if (p.address?.isNotEmpty ?? false)
          _buildIconText(PdfIcons.location_on, p.address!, isCompact: true),

        // Condição CORRIGIDA para o LinkedIn
        if (options.includeSocialLinks && (p.linkedinUrl?.isNotEmpty ?? false))
          _buildLink(PdfIcons.link, p.linkedinUrl!, isCompact: true),

        // Condição CORRIGIDA para o Portfólio
        if (options.includeSocialLinks && (p.portfolioUrl?.isNotEmpty ?? false))
          _buildLink(PdfIcons.public, p.portfolioUrl!, isCompact: true),
      ],
    );
  }

  // ===========================================================================
  // === WIDGETS AUXILIARES
  // ===========================================================================

  pw.Widget _buildIconText(pw.IconData icon, String text, {bool isCompact = false}) {
    return pw.Padding(
      padding: pw.EdgeInsets.only(bottom: isCompact ? 4 : 0),
      child: pw.Row(
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.Icon(icon, size: _baseFontSize + 2, color: PdfColors.grey700),
          pw.SizedBox(width: isCompact? 6 : 4),
          pw.Flexible(child: pw.Text(text, style: pw.TextStyle(fontSize: _baseFontSize, height: isCompact ? 1.6 : 1))),
        ],
      ),
    );
  }

  pw.Widget _buildLink(pw.IconData icon, String url, {bool isCompact = false}) {
    final cleanUrl = url.replaceAll('https://', '').replaceAll('www.', '');
    return pw.Padding(
      padding: pw.EdgeInsets.only(bottom: isCompact ? 4 : 0),
      child: pw.Row(
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.Icon(icon, size: _baseFontSize + 2, color: PdfColors.grey700),
          pw.SizedBox(width: isCompact? 6 : 4),
          pw.Flexible(
            child: pw.UrlLink(
                destination: url,
                child: pw.Text(
                    cleanUrl,
                    style: pw.TextStyle(
                      fontSize: _baseFontSize,
                      height: isCompact? 1.6 : 1,
                      decoration: pw.TextDecoration.underline,
                      color: PdfColors.blue,
                    )
                )
            ),
          ),
        ],
      ),
    );
  }
}