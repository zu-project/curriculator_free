// lib/features/export/html_generator_service.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'cv_template.dart'; //
import 'package:curriculator_free/models/education.dart';
import 'package:curriculator_free/models/experience.dart';
import 'package:curriculator_free/models/personal_data.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class HtmlGeneratorService {
  final CurriculumDataBundle data;
  final TemplateOptions options;
  final _dateFormat = DateFormat('MM/yyyy', 'pt_BR');

  HtmlGeneratorService(this.data, this.options);

  String _colorToCss(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  Future<String> generateHtml() async {
    final accentColorCss = _colorToCss(options.accentColor);
    final personalData = data.personalData;
    if (personalData == null) return "<h1>Erro: Dados Pessoais não encontrados.</h1>";

    final String css = """
    <style>
      @import url('https://fonts.googleapis.com/css2?family=Roboto:wght@400;700&display=swap');
      
      :root {
        --accent-color: $accentColorCss;
        --font-size-base: ${options.fontSize}pt;
        --margin-normal: ${options.margins.top}px;
      }

      body {
        font-family: 'Roboto', Arial, sans-serif;
        line-height: 1.6;
        background-color: #f0f0f0;
        margin: 0;
        padding: 20px;
        -webkit-print-color-adjust: exact;
        color-adjust: exact;
      }
      .cv-container {
        background-color: white;
        max-width: 595pt;
        min-height: 842pt;
        margin: auto;
        padding: var(--margin-normal);
        box-shadow: 0 0 10px rgba(0,0,0,0.1);
        color: #333333;
        font-size: var(--font-size-base);
      }
      h1, h2, h3 { font-weight: 700; margin: 0; }
      h1 { font-size: calc(var(--font-size-base) + 16pt); color: var(--accent-color); }
      h2 { font-size: calc(var(--font-size-base) + 4pt); border-bottom: 1.5px solid var(--accent-color); padding-bottom: 4px; margin-top: 10px; }
      p { margin: 0 0 1em 0; }
      ul { padding-left: 20px; }
      a { color: #0066cc; text-decoration: none; }
      
      /* *** A CORREÇÃO PRINCIPAL ESTÁ AQUI *** */
      .photo {
        width: 100px;         /* Largura fixa */
        height: 100px;        /* Altura fixa */
        border-radius: 50%;   /* Transforma em círculo */
        object-fit: cover;    /* Garante que a imagem preencha o círculo sem distorcer */
      }
      /* Fim da correção */

      .contact-info a { color: inherit; text-decoration: underline; }
      .contact-info .white-text a { color: white; }

      .section { margin-top: 20px; }
      .item { margin-bottom: 14px; }
      .item .title-line { display: flex; justify-content: space-between; align-items: flex-start; }
      .item .job-title { font-weight: 700; font-size: calc(var(--font-size-base) + 1pt); }
      .item .company, .item .institution { font-style: italic; color: #555; }
      .item .date { color: #666; white-space: nowrap; padding-left: 1em; }
      .item .description { margin-top: 4px; text-align: justify; }
      
      .skills-list { display: flex; flex-wrap: wrap; gap: 8px; margin-top: 8px; }
      .skill-chip { background-color: #f1f1f1; padding: 4px 10px; border-radius: 16px; font-size: calc(var(--font-size-base) - 1pt); }
      
      /* --- Template: Moderno --- */
      .template-modern .header {
        background-color: var(--accent-color);
        color: white;
        padding: var(--margin-normal);
        margin: calc(-1 * var(--margin-normal));
        margin-bottom: 20px;
      }
      .template-modern h1 { color: white; }
      .template-modern .job-title-header { color: rgba(255,255,255,0.8); font-size: calc(var(--font-size-base) + 4pt); }
      .template-modern .header hr { border-color: rgba(255,255,255,0.5); }
      .template-modern h2 { border: none; font-size: calc(var(--font-size-base) + 2pt); letter-spacing: 1.2px; color: var(--accent-color); }
      
      /* --- Template: Minimalista --- */
      .template-minimalist { text-align: center; }
      .template-minimalist h1 { color: black; font-size: calc(var(--font-size-base) + 16pt); letter-spacing: 2px; }
      .template-minimalist h2 { color: black; border-bottom: 1.5px solid black; }
      .template-minimalist .header { margin-bottom: 20px; }
      .template-minimalist .section { text-align: left; }

      /* --- Template: Funcional --- */
      .template-funcional { text-align: center; }
      /* A foto no funcional é um pouco maior e precisa de margem inferior */
      .template-funcional .photo { width: 110px; height: 110px; margin-bottom: 12px; }
      .template-funcional .header { margin-bottom: 20px; }
      .template-funcional .section { text-align: left; }
      .template-funcional h2 { border: none; font-size: calc(var(--font-size-base) + 2pt); letter-spacing: 1.2px; color: var(--accent-color); }
      
      @media print {
        body { background-color: white; padding: 0; }
        .cv-container { box-shadow: none; margin: 0; max-width: 100%; }
      }
    </style>
    """;

    // O resto do arquivo permanece o mesmo, pois a geração do HTML já está correta.
    return """
    <!DOCTYPE html>
    <html lang="pt-BR">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Currículo de ${personalData.name}</title>
        $css
    </head>
    <body>
        <div class="cv-container template-${options.templateName.toLowerCase()}">
            ${_buildHtmlHeader()}
            ${_buildHtmlCoreContent()}
        </div>
    </body>
    </html>
    """;
  }

  String _buildHtmlHeader() {
    final p = data.personalData!;
    String photoHtml = '';
    // Adicionamos a classe 'photo' à tag img
    if (p.photoPath != null && File(p.photoPath!).existsSync()) {
      final imageBytes = File(p.photoPath!).readAsBytesSync();
      final base64Image = 'data:image/${p.photoPath!.split('.').last};base64,${base64.encode(imageBytes)}';
      photoHtml = '<img src="$base64Image" alt="Foto de ${p.name}" class="photo">';
    }

    String contactHtml = _buildContactInfo(p);
    String headerClass = 'header';

    switch(options.templateName) {
      case 'Moderno':
        return """
        <header class="$headerClass">
            <h1>${p.name}</h1>
            ${data.experiences.where((e) => e.isCurrent).isNotEmpty ? '<div class="job-title-header">${data.experiences.firstWhere((e) => e.isCurrent).jobTitle}</div>' : ''}
            <hr>
            $contactHtml
        </header>
        """;
      case 'Minimalista':
        return """
        <header class="$headerClass">
            <h1>${p.name.toUpperCase()}</h1>
            ${_buildContactInfo(p, useMinimalistStyle: true)}
        </header>
        """;
      case 'Funcional':
        return """
        <header class="$headerClass">
            $photoHtml
            <h1>${p.name}</h1>
            $contactHtml
        </header>
        """;
      case 'Clássico':
      default:
      // Estrutura para alinhar texto à esquerda e foto à direita
        return """
        <header class="$headerClass" style="display: flex; align-items: flex-start; justify-content: space-between;">
            <div style="flex-grow: 1;">
              <h1>${p.name}</h1>
              $contactHtml
            </div>
            ${options.includePhoto ? '<div style="padding-left: 24px;">$photoHtml</div>' : ''}
        </header>
        """;
    }
  }

  String _buildHtmlCoreContent() {
    final p = data.personalData!;
    return """
    ${(options.includeSummary && (p.summary?.isNotEmpty ?? false)) ? _buildSection("RESUMO", '<p>${p.summary!.replaceAll('\n', '<br>')}</p>') : ''}
    ${data.experiences.isNotEmpty ? _buildSection("EXPERIÊNCIA", data.experiences.map(_buildExperienceItem).join()) : ''}
    ${data.educations.isNotEmpty ? _buildSection("FORMAÇÃO", data.educations.map(_buildEducationItem).join()) : ''}
    ${data.skills.isNotEmpty ? _buildSection("HABILIDADES", _buildSkillList()) : ''}
    ${data.languages.isNotEmpty ? _buildSection("IDIOMAS", _buildLanguageList()) : ''}
    """;
  }

  String _buildContactInfo(PersonalData p, {bool useMinimalistStyle = false}) {
    final whiteTextClass = options.templateName == 'Moderno' ? 'white-text' : '';
    final separator = useMinimalistStyle ? ' | ' : ' &bull; ';

    List<String> items = [];
    if (p.email.isNotEmpty) items.add(p.email);
    if (p.phone?.isNotEmpty ?? false) items.add(p.phone!);
    if (p.address?.isNotEmpty ?? false) items.add(p.address!);
    if (options.includeSocialLinks) {
      if(p.linkedinUrl?.isNotEmpty ?? false) items.add('<a href="${p.linkedinUrl}" target="_blank">${p.linkedinUrl!.replaceAll('https://www.', '')}</a>');
      if(p.portfolioUrl?.isNotEmpty ?? false) items.add('<a href="${p.portfolioUrl}" target="_blank">${p.portfolioUrl!.replaceAll('https://www.', '')}</a>');
    }

    String contactString = items.join(separator);

    List<String> otherItems = [];
    if (options.includeAvailability && p.hasTravelAvailability) otherItems.add('Disponibilidade para viagens');
    if (options.includeAvailability && p.hasRelocationAvailability) otherItems.add('Disponibilidade para mudança');
    if (options.includeVehicle && p.hasCar) otherItems.add('Possui carro');
    if (options.includeVehicle && p.hasMotorcycle) otherItems.add('Possui moto');
    if (options.includeLicense && p.licenseCategories.isNotEmpty) otherItems.add('CNH: ${p.licenseCategories.join(', ')}');

    String otherItemsString = otherItems.join(separator);

    return '<div class="contact-info $whiteTextClass">$contactString <br> $otherItemsString</div>';
  }

  String _buildSection(String title, String content) {
    String originalTitle = title;
    switch(title) {
      case 'RESUMO': originalTitle = 'Resumo Profissional'; break;
      case 'EXPERIÊNCIA': originalTitle = 'Experiência Profissional'; break;
      case 'FORMAÇÃO': originalTitle = 'Formação Acadêmica'; break;
    }

    final modernTitles = ['Moderno', 'Funcional'];
    String sectionTitle = modernTitles.contains(options.templateName) ? title.toUpperCase() : originalTitle;

    return """
    <section class="section">
      <h2>$sectionTitle</h2>
      <div>$content</div>
    </section>
    """;
  }

  String _buildExperienceItem(Experience exp) {
    return """
    <div class="item">
      <div class="title-line">
        <div>
          <div class="job-title">${exp.jobTitle} at ${exp.company}</div>
          <div class="company">${exp.location ?? ''}</div>
        </div>
        <div class="date">${_dateFormat.format(exp.startDate!)} - ${exp.isCurrent ? 'Presente' : (exp.endDate != null ? _dateFormat.format(exp.endDate!) : '')}</div>
      </div>
      ${(exp.description?.isNotEmpty ?? false) ? '<p class="description">${exp.description!.replaceAll('\n', '<br>')}</p>' : ''}
    </div>
    """;
  }

  String _buildEducationItem(Education edu) {
    return """
     <div class="item">
      <div class="title-line">
        <div>
          <div class="job-title">${edu.degree} in ${edu.fieldOfStudy}</div>
          <div class="institution">${edu.institution}</div>
        </div>
        <div class="date">${_dateFormat.format(edu.startDate!)} - ${edu.inProgress ? 'Presente' : (edu.endDate != null ? _dateFormat.format(edu.endDate!) : '')}</div>
      </div>
    </div>
    """;
  }

  String _buildSkillList() {
    return '<div class="skills-list">${data.skills.map((s) => '<span class="skill-chip">${s.name}</span>').join()}</div>';
  }

  String _buildLanguageList() {
    return '<ul>${data.languages.map((l) => '<li>${l.languageName} (${l.proficiency.displayName})</li>').join()}</ul>';
  }
}