//C:\Users\ziofl\StudioProjects\curriculator_free\lib\features\export\pdf_widgets.dart
import 'package:curriculator_free/models/education.dart';
import 'package:curriculator_free/models/experience.dart';
import 'package:curriculator_free/models/personal_data.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

// --- Widgets de Seção ---

pw.Widget Section({required String title, required pw.Widget child, required PdfColor accentColor}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(top: 15, bottom: 5),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title.toUpperCase(),
          style: pw.TextStyle(color: accentColor, fontWeight: pw.FontWeight.bold, fontSize: 13),
        ),
        pw.Container(height: 2, width: 40, color: accentColor, margin: const pw.EdgeInsets.only(top: 4, bottom: 8)),
        child,
      ],
    ),
  );
}

pw.Widget SimpleSection({required String title, required pw.Widget child}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 8),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title.toUpperCase(), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
        pw.SizedBox(height: 4),
        child,
      ],
    ),
  );
}

pw.Widget SidebarSection({required String title, required pw.Widget child}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 15),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title.toUpperCase(), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
        pw.SizedBox(height: 5),
        child,
      ],
    ),
  );
}

// --- Itens de Lista ---

pw.Widget ExperienceItem(Experience exp, double baseFontSize) {
  final format = DateFormat('MM/yyyy');
  final period = '${exp.startDate != null ? format.format(exp.startDate!) : ''} - ${exp.isCurrent ? 'Presente' : (exp.endDate != null ? format.format(exp.endDate!) : '')}';
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 10),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Expanded(child: pw.Text(exp.jobTitle, softWrap: true, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: baseFontSize + 1))),
            pw.SizedBox(width: 10),
            pw.Text(period, style: pw.TextStyle(fontSize: baseFontSize - 1, fontStyle: pw.FontStyle.italic)),
          ],
        ),
        pw.Text('${exp.company} | ${exp.location ?? ""}', style: pw.TextStyle(fontSize: baseFontSize, fontStyle: pw.FontStyle.italic)),
        if (exp.description?.isNotEmpty ?? false)
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 4),
            child: pw.Text(exp.description!),
          ),
      ],
    ),
  );
}

pw.Widget EducationItem(Education edu, double baseFontSize) {
  final format = DateFormat('MM/yyyy');
  final period = '${edu.startDate != null ? format.format(edu.startDate!) : ''} - ${edu.inProgress ? 'Presente' : (edu.endDate != null ? format.format(edu.endDate!) : '')}';
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 10),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Expanded(child: pw.Text('${edu.degree} em ${edu.fieldOfStudy}', softWrap: true, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: baseFontSize + 1))),
            pw.SizedBox(width: 10),
            pw.Text(period, style: pw.TextStyle(fontSize: baseFontSize - 1, fontStyle: pw.FontStyle.italic)),
          ],
        ),
        pw.Text(edu.institution, style: pw.TextStyle(fontSize: baseFontSize, fontStyle: pw.FontStyle.italic)),
      ],
    ),
  );
}

// --- Cabeçalhos ---

pw.Widget buildClassicHeader(PersonalData? pData, List<String> extras, double baseFontSize, bool includeSocialLinks, [pw.ImageProvider? photo]) {
  final contactInfo = pw.Column(
    crossAxisAlignment: photo == null ? pw.CrossAxisAlignment.center : pw.CrossAxisAlignment.start,
    children: [
      pw.Text(pData?.name.toUpperCase() ?? 'SEU NOME', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: baseFontSize + 12)),
      pw.SizedBox(height: 5),
      pw.Text('${pData?.email ?? ""} • ${pData?.phone ?? ""} • ${pData?.address ?? ""}', textAlign: photo == null ? pw.TextAlign.center : pw.TextAlign.left, style: pw.TextStyle(fontSize: baseFontSize - 1)),
      if (includeSocialLinks && (pData?.linkedinUrl?.isNotEmpty ?? false)) pw.Text(pData!.linkedinUrl!, style: pw.TextStyle(fontSize: baseFontSize - 1)),
      if (includeSocialLinks && (pData?.portfolioUrl?.isNotEmpty ?? false)) pw.Text(pData!.portfolioUrl!, style: pw.TextStyle(fontSize: baseFontSize - 1)),
      if (extras.isNotEmpty) ...[
        pw.SizedBox(height: 5),
        pw.Text(extras.join(' | '), textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: baseFontSize - 1)),
      ],
    ],
  );

  if (photo != null) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 20),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.ClipOval(child: pw.SizedBox(width: 80, height: 80, child: pw.Image(photo, fit: pw.BoxFit.cover))),
          pw.SizedBox(width: 20),
          pw.Expanded(child: contactInfo),
        ],
      ),
    );
  }
  return pw.Padding(padding: const pw.EdgeInsets.only(bottom: 20), child: contactInfo);
}