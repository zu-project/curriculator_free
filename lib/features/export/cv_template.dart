// lib/features/export/cv_template.dart
// VERSÃO FINAL CORRIGIDA: Espaçamento entre as seções reduzido.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:curriculator_free/models/personal_data.dart';
import 'package:curriculator_free/models/experience.dart';
import 'package:curriculator_free/models/education.dart';
import 'package:curriculator_free/models/skill.dart';
import 'package:curriculator_free/models/language.dart';

// As classes CurriculumDataBundle e TemplateOptions não mudam.
class CurriculumDataBundle {
  final PersonalData? personalData;
  final List<Experience> experiences;
  final List<Education> educations;
  final List<Skill> skills;
  final List<Language> languages;
  CurriculumDataBundle({ this.personalData, required this.experiences, required this.educations, required this.skills, required this.languages });
}

class TemplateOptions {
  final String templateName;
  final String marginPreset;
  final double fontSize;
  final Color accentColor;
  final bool includePhoto;
  final bool includeSummary;
  final bool includeAvailability;
  final bool includeVehicle;
  final bool includeLicense;
  final bool includeSocialLinks;

  TemplateOptions({ required this.templateName, required this.marginPreset, required this.fontSize, required this.accentColor, required this.includePhoto, required this.includeSummary, required this.includeAvailability, required this.includeVehicle, required this.includeLicense, required this.includeSocialLinks });

  EdgeInsets get margins {
    switch (marginPreset) {
      case 'Estreita': return const EdgeInsets.all(35);
      case 'Larga': return const EdgeInsets.all(70);
      default: return const EdgeInsets.all(50);
    }
  }
}

class CvTemplate extends StatelessWidget {
  final CurriculumDataBundle data;
  final TemplateOptions options;
  final _dateFormat = DateFormat('MM/yyyy', 'pt_BR');

  CvTemplate({super.key, required this.data, required this.options});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 595,
      color: Colors.white,
      child: DefaultTextStyle(
        style: TextStyle(fontSize: options.fontSize, color: const Color(0xFF333333), fontFamily: 'Roboto'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Padding(
              padding: _getCoreContentPadding(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: _buildCoreContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  EdgeInsets _getCoreContentPadding() {
    if (options.templateName == 'Moderno') {
      return EdgeInsets.only(left: options.margins.left, right: options.margins.right, bottom: options.margins.bottom);
    }
    return options.margins;
  }

  Widget _buildHeader() {
    if (options.templateName != 'Moderno') {
      // Para o Clássico, Minimalista e Funcional, o header está dentro de um Padding geral.
      // Adicionamos um padding extra no fundo para separá-lo do conteúdo.
      return Padding(
        padding: options.margins.copyWith(bottom: 0), // Remove o padding inferior original
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderContent(),
            SizedBox(height: options.margins.bottom / 2), // Adiciona um espaço antes do conteúdo
          ],
        ),
      );
    }
    // O header Moderno já tem seu próprio padding e espaçamento.
    return _buildHeaderContent();
  }

  Widget _buildHeaderContent() {
    switch (options.templateName) {
      case 'Funcional': return _buildFunctionalHeader();
      case 'Minimalista': return _buildMinimalistHeader();
      case 'Moderno': return _buildModernHeader();
      default: return _buildClassicHeader();
    }
  }

  List<Widget> _buildCoreContent() {
    final bool useModernTitle = ['Moderno', 'Funcional'].contains(options.templateName);
    final Color titleColor = options.templateName == 'Minimalista' ? Colors.black : options.accentColor;
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

  Widget _buildClassicHeader() {
    final p = data.personalData;
    if (p == null) return const SizedBox.shrink();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(p.name, style: TextStyle(fontSize: options.fontSize + 16, fontWeight: FontWeight.bold, color: options.accentColor)),
              const SizedBox(height: 12),
              _buildContactAndOtherInfo(p),
            ],
          ),
        ),
        if (options.includePhoto && p.photoPath != null && File(p.photoPath!).existsSync())
          Padding(
            padding: const EdgeInsets.only(left: 24),
            child: ClipOval(child: Image.file(File(p.photoPath!), width: 100, height: 100, fit: BoxFit.cover)),
          ),
      ],
    );
  }

  Widget _buildModernHeader() {
    final p = data.personalData;
    if (p == null) return const SizedBox.shrink();
    return Container(
      color: options.accentColor,
      padding: EdgeInsets.fromLTRB(options.margins.left, options.margins.top, options.margins.right, 20),
      width: double.infinity,
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(p.name, style: TextStyle(fontSize: options.fontSize + 20, fontWeight: FontWeight.bold, color: Colors.white, height: 1.2)),
            if (data.experiences.where((e) => e.isCurrent).isNotEmpty)
              Text(data.experiences.firstWhere((e) => e.isCurrent).jobTitle, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: options.fontSize + 4)),
            Divider(color: Colors.white.withOpacity(0.5), height: 24, thickness: 0.8),
            _buildContactAndOtherInfo(p, useWhiteText: true),
            const SizedBox(height: 10), // Espaço extra no final do header
          ]
      ),
    );
  }

  Widget _buildFunctionalHeader() {
    final p = data.personalData;
    if (p == null) return const SizedBox.shrink();
    return Column(
        children: [
          if (options.includePhoto && p.photoPath != null && File(p.photoPath!).existsSync())
            ClipOval(child: Image.file(File(p.photoPath!), width: 110, height: 110, fit: BoxFit.cover)),
          const SizedBox(height: 12),
          Text(p.name, textAlign: TextAlign.center, style: TextStyle(fontSize: options.fontSize + 16, fontWeight: FontWeight.bold, color: options.accentColor)),
          const SizedBox(height: 8),
          _buildContactAndOtherInfo(p, isCentered: true),
        ]
    );
  }

  Widget _buildMinimalistHeader() {
    final p = data.personalData;
    if (p == null) return const SizedBox.shrink();
    return Column(
        children: [
          Text(p.name.toUpperCase(), textAlign: TextAlign.center, style: TextStyle(fontSize: options.fontSize + 16, fontWeight: FontWeight.bold, color: Colors.black, letterSpacing: 2)),
          const SizedBox(height: 8),
          _buildContactAndOtherInfo(p, isCentered: true, useMinimalistStyle: true),
        ]
    );
  }

  // ***** AQUI ESTÁ A ALTERAÇÃO *****
  Widget _buildSection({required String title, required Widget child, bool useModernTitle = false, required Color titleColor}) {
    // Para a primeira seção, usamos um padding menor. Para as outras, um pouco maior.
    final bool isFirstSection = title.toLowerCase().contains('resumo');
    final double topPadding = isFirstSection ? 0 : 12;

    return Padding(
      // Padding dinâmico: zero para a primeira seção, 12 para as demais
      padding: EdgeInsets.only(top: topPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: options.fontSize + (useModernTitle ? 2 : 4), fontWeight: FontWeight.bold, color: titleColor, letterSpacing: useModernTitle ? 1.2 : 0)),
          useModernTitle ? const SizedBox(height: 6) : Divider(color: titleColor.withOpacity(0.7), height: 8, thickness: 1.5),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _buildSummary() => Text(data.personalData!.summary!, style: TextStyle(fontSize: options.fontSize, height: 1.5, color: Colors.black87));

  Widget _buildExperienceList() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: data.experiences.map((exp) => Padding(padding: const EdgeInsets.only(bottom: 14), child: _buildExperienceItem(exp))).toList());

  Widget _buildExperienceItem(Experience exp) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Text('${exp.jobTitle} at ${exp.company}', style: TextStyle(fontSize: options.fontSize + 1, fontWeight: FontWeight.bold))),
          if (exp.startDate != null)
            Text('${_dateFormat.format(exp.startDate!)} - ${exp.isCurrent ? 'Presente' : (exp.endDate != null ? _dateFormat.format(exp.endDate!) : '')}', style: TextStyle(fontSize: options.fontSize, color: Colors.grey.shade700))
        ]),
        if(exp.location != null && exp.location!.isNotEmpty)
          Text(exp.location!, style: TextStyle(fontSize: options.fontSize, color: Colors.grey.shade600, fontStyle: FontStyle.italic)),
        if (exp.description?.isNotEmpty ?? false)
          Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(exp.description!, style: TextStyle(fontSize: options.fontSize, height: 1.4, color: Colors.black.withOpacity(0.8)))
          ),
      ]
  );

  Widget _buildEducationList() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: data.educations.map((edu) => Padding(padding: const EdgeInsets.only(bottom: 12), child: _buildEducationItem(edu))).toList());

  Widget _buildEducationItem(Education edu) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Text('${edu.degree} in ${edu.fieldOfStudy}', style: TextStyle(fontSize: options.fontSize + 1, fontWeight: FontWeight.bold))),
          if (edu.startDate != null)
            Text('${_dateFormat.format(edu.startDate!)} - ${edu.inProgress ? 'Presente' : (edu.endDate != null ? _dateFormat.format(edu.endDate!) : '')}', style: TextStyle(fontSize: options.fontSize, color: Colors.grey.shade700))
        ]),
        Text(edu.institution, style: TextStyle(fontSize: options.fontSize, color: Colors.grey.shade600, fontStyle: FontStyle.italic)),
      ]
  );

  Widget _buildSkillList() => Wrap(
      spacing: 8, runSpacing: 4, children: [
    for (final skill in data.skills)
      Chip(
        label: Text(skill.name),
        backgroundColor: options.accentColor.withOpacity(0.1),
        side: BorderSide(color: options.accentColor.withOpacity(0.2)),
        labelStyle: TextStyle(fontSize: options.fontSize, color: Colors.black87),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      )
  ]
  );

  Widget _buildLanguageList() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: data.languages.map((lang) =>
          Text('• ${lang.languageName} (${lang.proficiency.displayName})', style: TextStyle(fontSize: options.fontSize, height: 1.6))
      ).toList()
  );

  Widget _buildContactAndOtherInfo(PersonalData p, {bool isCentered = false, bool useWhiteText = false, bool useMinimalistStyle = false}) {
    final textColor = useWhiteText ? Colors.white.withOpacity(0.9) : Colors.grey.shade700;
    final linkColor = useWhiteText ? Colors.white : Colors.blue.shade800;

    final contactItems = <Widget>[];
    if (p.email.isNotEmpty) contactItems.add(Text(p.email, style: TextStyle(color: textColor)));
    if (p.phone?.isNotEmpty ?? false) contactItems.add(Text(p.phone!, style: TextStyle(color: textColor)));
    if (p.address?.isNotEmpty ?? false) contactItems.add(Text(p.address!, style: TextStyle(color: textColor)));
    if (options.includeSocialLinks && (p.linkedinUrl?.isNotEmpty ?? false)) contactItems.add(InkWell(onTap: () => launchUrl(Uri.parse(p.linkedinUrl!)), child: Text(p.linkedinUrl!.replaceAll('https://www.', ''), style: TextStyle(decoration: TextDecoration.underline, color: linkColor))));
    if (options.includeSocialLinks && (p.portfolioUrl?.isNotEmpty ?? false)) contactItems.add(InkWell(onTap: () => launchUrl(Uri.parse(p.portfolioUrl!)), child: Text(p.portfolioUrl!.replaceAll('https://www.', ''), style: TextStyle(decoration: TextDecoration.underline, color: linkColor))));

    final otherItems = <String>[];
    if (options.includeAvailability && p.hasTravelAvailability) otherItems.add('Disponibilidade para viagens');
    if (options.includeAvailability && p.hasRelocationAvailability) otherItems.add('Disponibilidade para mudança');
    if (options.includeVehicle && p.hasCar) otherItems.add('Possui carro');
    if (options.includeVehicle && p.hasMotorcycle) otherItems.add('Possui moto');
    if (options.includeLicense && p.licenseCategories.isNotEmpty) otherItems.add('CNH: ${p.licenseCategories.join(', ')}');

    final separator = useMinimalistStyle ? ' | ' : ' • ';

    return Wrap(
      alignment: isCentered ? WrapAlignment.center : WrapAlignment.start,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8, runSpacing: 4,
      children: [
        for(int i = 0; i < contactItems.length; i++) ...[
          contactItems[i],
          if(i < contactItems.length - 1) Text(separator, style: TextStyle(color: textColor.withOpacity(0.5))),
        ],
        if(otherItems.isNotEmpty && contactItems.isNotEmpty) Text(separator, style: TextStyle(color: textColor.withOpacity(0.5))),
        ...otherItems.map((item) => Text(item, style: TextStyle(fontSize: options.fontSize - 1, color: textColor))),
      ],
    );
  }
}