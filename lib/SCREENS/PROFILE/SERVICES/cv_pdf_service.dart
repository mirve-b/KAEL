import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:kael/SCREENS/FORMS/DATA%20MODEL/user_data_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class CvPdfService {
  static pw.Font? _regularFont;
  static pw.Font? _boldFont;

  static Future<void> _ensureFonts() async {
    if (_regularFont != null) return;
    final data = await rootBundle.load('assets/fonts/Inter-VariableFont_opsz,wght.ttf');
    _regularFont = pw.Font.ttf(data);
    _boldFont = _regularFont;
  }

  static Future<Uint8List> generate(UserDataModel user) async {
    user.ensureEducationSeeded();
    await _ensureFonts();

    final baseFont = _regularFont!;
    final boldFont = _boldFont!;

    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(48),
        build: (context) => [
          _buildHeader(user, boldFont, baseFont),
          pw.SizedBox(height: 16),
          if (user.bio.trim().isNotEmpty) ...[
            _sectionTitle('PROFESSIONAL SUMMARY', boldFont),
            pw.Text(
              _pdfText(user.bio.trim()),
              style: pw.TextStyle(font: baseFont, fontSize: 10, lineSpacing: 1.4),
            ),
            pw.SizedBox(height: 12),
          ],
          if (user.experiences.any((e) => e.jobTitle.isNotEmpty || e.company.isNotEmpty)) ...[
            _sectionTitle('EXPERIENCE', boldFont),
            ...user.experiences.where((e) => e.jobTitle.isNotEmpty || e.company.isNotEmpty).map(
              (e) => _experienceBlock(e, boldFont, baseFont),
            ),
            pw.SizedBox(height: 8),
          ],
          if (user.educationEntries.any((e) => e.institution.isNotEmpty || e.fieldOfStudy.isNotEmpty)) ...[
            _sectionTitle('EDUCATION', boldFont),
            ...user.educationEntries
                .where((e) => e.institution.isNotEmpty || e.fieldOfStudy.isNotEmpty)
                .map((e) => _educationBlock(e, boldFont, baseFont)),
            pw.SizedBox(height: 8),
          ],
          if (user.skills.isNotEmpty) ...[
            _sectionTitle('SKILLS', boldFont),
            pw.Text(
              _pdfText(user.skills.where((s) => s.trim().isNotEmpty).join('  |  ')),
              style: pw.TextStyle(font: baseFont, fontSize: 10, lineSpacing: 1.3),
            ),
            pw.SizedBox(height: 12),
          ],
          if (user.cvProjects.any((p) => p.name.isNotEmpty)) ...[
            _sectionTitle('PROJECTS', boldFont),
            ...user.cvProjects.where((p) => p.name.isNotEmpty).map(
              (p) => _projectBlock(p, boldFont, baseFont),
            ),
            pw.SizedBox(height: 8),
          ],
          if (user.certifications.any((c) => c.name.isNotEmpty)) ...[
            _sectionTitle('CERTIFICATIONS', boldFont),
            ...user.certifications.where((c) => c.name.isNotEmpty).map(
              (c) => _certificationBlock(c, boldFont, baseFont),
            ),
          ],
          if (user.languages.isNotEmpty) ...[
            pw.SizedBox(height: 8),
            _sectionTitle('LANGUAGES', boldFont),
            pw.Text(
              _pdfText(user.languages.join('  |  ')),
              style: pw.TextStyle(font: baseFont, fontSize: 10),
            ),
          ],
        ],
      ),
    );

    return doc.save();
  }

  static String _pdfText(String value) {
    return value
        .replaceAll('\u2019', "'")
        .replaceAll('\u2018', "'")
        .replaceAll('\u201C', '"')
        .replaceAll('\u201D', '"')
        .replaceAll('\u2022', '|')
        .replaceAll('\u2013', '-')
        .replaceAll('\u2014', '-');
  }

  static pw.Widget _buildHeader(UserDataModel user, pw.Font bold, pw.Font regular) {
    final contactParts = <String>[
      if (user.email.isNotEmpty) user.email,
      if (user.phone.isNotEmpty) user.phone,
      if (user.country.isNotEmpty) user.country,
      if (user.linkedinUrl.isNotEmpty) user.linkedinUrl,
      if (user.websiteUrl.isNotEmpty) user.websiteUrl,
    ];

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          user.name.isNotEmpty ? _pdfText(user.name.toUpperCase()) : 'YOUR NAME',
          style: pw.TextStyle(font: bold, fontSize: 20, letterSpacing: 0.5),
        ),
        if (user.title.isNotEmpty)
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 4),
            child: pw.Text(
              _pdfText(user.title),
              style: pw.TextStyle(font: regular, fontSize: 11),
            ),
          ),
        if (contactParts.isNotEmpty)
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 6),
            child: pw.Text(
              _pdfText(contactParts.join('  |  ')),
              style: pw.TextStyle(font: regular, fontSize: 9),
            ),
          ),
        pw.SizedBox(height: 8),
        pw.Divider(thickness: 1),
      ],
    );
  }

  static pw.Widget _sectionTitle(String title, pw.Font bold) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6, top: 4),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(font: bold, fontSize: 11, letterSpacing: 0.8),
          ),
          pw.SizedBox(height: 2),
          pw.Container(width: double.infinity, height: 0.5, color: PdfColors.grey600),
          pw.SizedBox(height: 6),
        ],
      ),
    );
  }

  static pw.Widget _experienceBlock(dynamic e, pw.Font bold, pw.Font regular) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Text(
                  _pdfText('${e.jobTitle}${e.company.isNotEmpty ? ' — ${e.company}' : ''}'),
                  style: pw.TextStyle(font: bold, fontSize: 10),
                ),
              ),
              if (e.dateRange.isNotEmpty)
                pw.Text(_pdfText(e.dateRange), style: pw.TextStyle(font: regular, fontSize: 9)),
            ],
          ),
          if (e.location.isNotEmpty)
            pw.Text(_pdfText(e.location), style: pw.TextStyle(font: regular, fontSize: 9, color: PdfColors.grey700)),
          if (e.description.trim().isNotEmpty)
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 4),
              child: pw.Text(
                _pdfText(e.description.trim()),
                style: pw.TextStyle(font: regular, fontSize: 9, lineSpacing: 1.35),
              ),
            ),
        ],
      ),
    );
  }

  static pw.Widget _educationBlock(dynamic e, pw.Font bold, pw.Font regular) {
    final degree = [
      if (e.level.isNotEmpty) e.level,
      if (e.fieldOfStudy.isNotEmpty) e.fieldOfStudy,
    ].join(', ');

    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Expanded(
                child: pw.Text(
                  _pdfText(e.institution.isNotEmpty ? e.institution : 'Institution'),
                  style: pw.TextStyle(font: bold, fontSize: 10),
                ),
              ),
              if (e.gradYear.isNotEmpty)
                pw.Text(_pdfText(e.gradYear), style: pw.TextStyle(font: regular, fontSize: 9)),
            ],
          ),
          if (degree.isNotEmpty)
            pw.Text(_pdfText(degree), style: pw.TextStyle(font: regular, fontSize: 9)),
          if (e.gpa.isNotEmpty)
            pw.Text(_pdfText('GPA: ${e.gpa}'), style: pw.TextStyle(font: regular, fontSize: 9)),
          if (e.honors.isNotEmpty)
            pw.Text(_pdfText(e.honors), style: pw.TextStyle(font: regular, fontSize: 9)),
        ],
      ),
    );
  }

  static pw.Widget _projectBlock(dynamic p, pw.Font bold, pw.Font regular) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            _pdfText(p.name),
            style: pw.TextStyle(font: bold, fontSize: 10),
          ),
          if (p.role.isNotEmpty || p.technologies.isNotEmpty)
            pw.Text(
              _pdfText([if (p.role.isNotEmpty) p.role, if (p.technologies.isNotEmpty) p.technologies].join(' | ')),
              style: pw.TextStyle(font: regular, fontSize: 9, color: PdfColors.grey700),
            ),
          if (p.description.trim().isNotEmpty)
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 3),
              child: pw.Text(
                _pdfText(p.description.trim()),
                style: pw.TextStyle(font: regular, fontSize: 9, lineSpacing: 1.35),
              ),
            ),
          if (p.url.isNotEmpty)
            pw.Text(_pdfText(p.url), style: pw.TextStyle(font: regular, fontSize: 8, color: PdfColors.grey600)),
        ],
      ),
    );
  }

  static pw.Widget _certificationBlock(dynamic c, pw.Font bold, pw.Font regular) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(_pdfText(c.name), style: pw.TextStyle(font: bold, fontSize: 10)),
                if (c.issuer.isNotEmpty)
                  pw.Text(_pdfText(c.issuer), style: pw.TextStyle(font: regular, fontSize: 9)),
                if (c.credentialId.isNotEmpty)
                  pw.Text(_pdfText('ID: ${c.credentialId}'), style: pw.TextStyle(font: regular, fontSize: 8)),
              ],
            ),
          ),
          if (c.date.isNotEmpty)
            pw.Text(_pdfText(c.date), style: pw.TextStyle(font: regular, fontSize: 9)),
        ],
      ),
    );
  }
}
