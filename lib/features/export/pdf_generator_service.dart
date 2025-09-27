// C:\Users\ziofl\StudioProjects\curriculator_free\lib\features\export\pdf_generator_service.dart
// VERSÃO CORRIGIDA

import 'dart:typed_data';
import 'package:curriculator_free/features/export/pdf_widgets.dart'; // Importa o layout
import 'package:curriculator_free/models/education.dart';
import 'package:curriculator_free/models/experience.dart';
import 'package:curriculator_free/models/language.dart';
import 'package:curriculator_free/models/personal_data.dart';
import 'package:curriculator_free/models/skill.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;


/// Contém os dados do currículo já carregados, prontos para serem usados pelo gerador de PDF.
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

/// Contém todas as opções de customização selecionadas pelo usuário na tela de exportação.
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


/// Classe principal responsável por orquestrar a geração do PDF.
class PdfGeneratorService {
  final CurriculumDataBundle data;
  final PdfExportOptions options;
  late final pw.ThemeData _theme;

  // Coleção de fontes que serão carregadas e usadas no PDF.
  late final pw.Font _fontRegular;
  late final pw.Font _fontBold;
  late final pw.Font _fontItalic;
  late final pw.Font _fontBoldItalic;
  late final pw.Font _iconFont;


  PdfGeneratorService(this.data, this.options);

  /// Método público que gera o PDF e retorna seus bytes.
  Future<Uint8List> generatePdf() async {
    // Carrega as fontes do projeto.
    await _loadFonts();

    // Define um tema base para o PDF, facilitando a consistência.
    _theme = pw.ThemeData.withFont(
      base: _fontRegular,
      bold: _fontBold,
      italic: _fontItalic,
      boldItalic: _fontBoldItalic,
      icons: _iconFont,
    );

    // Cria o documento PDF.
    final doc = pw.Document(
      theme: _theme,
      title: 'Currículo de ${data.personalData?.name ?? ''}',
      author: 'Curriculator Free',
    );

    // Determina qual layout de template usar.
    final builder = _getTemplateBuilder();

    // Adiciona a página ao documento, construída pelo builder do template.
    doc.addPage(
      pw.MultiPage(
        pageFormat: _getMargin(),
        build: (context) => builder(context),
      ),
    );

    // Salva o documento em memória e retorna os bytes.
    return doc.save();
  }


  /// Carrega todos os arquivos de fonte dos assets para o gerador de PDF.
  Future<void> _loadFonts() async {
    _fontRegular = pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Regular.ttf'));
    _fontBold = pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Bold.ttf'));
    _fontItalic = pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Italic.ttf'));
    _fontBoldItalic = pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-BoldItalic.ttf'));
    _iconFont = pw.Font.ttf(await rootBundle.load('assets/fonts/MaterialIcons-Regular.ttf'));
  }

  /// Retorna o layout de página correto com base na predefinição de margem.
  PdfPageFormat _getMargin() {
    switch (options.marginPreset) {
      case 'Estreita':
        return PdfPageFormat.a4.copyWith(
          marginLeft: 1.5 * PdfPageFormat.cm,
          marginRight: 1.5 * PdfPageFormat.cm,
          marginTop: 1.5 * PdfPageFormat.cm,
          marginBottom: 1.5 * PdfPageFormat.cm,
        );
      case 'Larga':
        return PdfPageFormat.a4.copyWith(
          marginLeft: 2.5 * PdfPageFormat.cm,
          marginRight: 2.5 * PdfPageFormat.cm,
          marginTop: 2.5 * PdfPageFormat.cm,
          marginBottom: 2.5 * PdfPageFormat.cm,
        );
      default: // Normal
        return PdfPageFormat.a4;
    }
  }

  /// Retorna a função que constrói a lista de widgets para o template selecionado.
  List<pw.Widget> Function(pw.Context) _getTemplateBuilder() {
    final layoutService = PdfLayoutService(data, options, _theme);
    switch (options.templateName) {
      case 'Moderno':
        return layoutService.buildModernTemplate;
    // Adicione outros templates aqui
    // case 'Minimalista':
    //   return layoutService.buildMinimalistTemplate;
      case 'Clássico':
      default:
        return layoutService.buildClassicTemplate;
    }
  }
}