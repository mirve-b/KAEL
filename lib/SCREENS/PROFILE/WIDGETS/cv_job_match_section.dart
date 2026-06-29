import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:kael/API/job_match_service.dart';
import 'package:kael/SCREENS/FORMS/DATA%20MODEL/user_data_model.dart';
import 'package:kael/SCREENS/GLOBAL%20WIDGETS/kael_theme.dart';
import 'package:kael/SCREENS/PROFILE/DATA%20MODEL/job_match_result.dart';
import 'package:kael/SCREENS/PROFILE/SERVICES/cv_pdf_service.dart';
import 'package:kael/SCREENS/PROFILE/WIDGETS/cv_ui_helpers.dart';
import 'package:printing/printing.dart';

class CvJobMatchSection extends StatefulWidget {
  final UserDataModel user;
  final KaelTheme theme;

  const CvJobMatchSection({super.key, required this.user, required this.theme});

  @override
  State<CvJobMatchSection> createState() => _CvJobMatchSectionState();
}

class _CvJobMatchSectionState extends State<CvJobMatchSection> {
  final _jobController = TextEditingController();
  final _jobMatchService = JobMatchService();

  bool _isAnalyzing = false;
  bool _isExporting = false;
  JobMatchResult? _result;
  String? _error;

  @override
  void dispose() {
    _jobController.dispose();
    super.dispose();
  }

  Future<void> _analyze() async {
    final description = _jobController.text.trim();
    if (description.isEmpty) {
      setState(() => _error = 'Paste a job description first.');
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _error = null;
      _result = null;
    });

    try {
      final result = await _jobMatchService.analyze(
        user: widget.user,
        jobDescription: description,
      );
      if (!mounted) return;
      setState(() => _result = result);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  Future<void> _previewTailoredCv() async {
    final result = _result;
    if (result == null) return;

    final bytes = await CvPdfService.generateTailored(widget.user, result);
    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF121212),
        insetPadding: const EdgeInsets.all(40),
        child: SizedBox(
          width: 700,
          height: 900,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Text(
                      'TAILORED CV — ${result.compatibilityPercent}% MATCH',
                      style: const TextStyle(color: Colors.white54, letterSpacing: 1.5, fontSize: 11),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white54),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Colors.white10),
              Expanded(
                child: PdfPreview(
                  build: (_) async => bytes,
                  canChangeOrientation: false,
                  canChangePageFormat: false,
                  canDebug: false,
                  pdfPreviewPageDecoration: const BoxDecoration(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _exportTailoredCv() async {
    final result = _result;
    if (result == null || _isExporting) return;

    setState(() => _isExporting = true);
    try {
      final Uint8List bytes = await CvPdfService.generateTailored(widget.user, result);
      final safeName = widget.user.name.trim().isEmpty
          ? 'KAEL_TAILORED_CV'
          : widget.user.name.trim().replaceAll(RegExp(r'[^\w\s-]'), '').replaceAll(' ', '_');

      final path = await FilePicker.platform.saveFile(
        dialogTitle: 'Export tailored CV',
        fileName: '${safeName}_TAILORED_CV.pdf',
        type: FileType.custom,
        allowedExtensions: const ['pdf'],
      );

      if (path != null) {
        await File(path).writeAsBytes(bytes);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Tailored CV exported to $path')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cv = CvThemeScope.of(context);
    final theme = widget.theme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('JOB MATCH', style: cv.heading(size: 16)),
        const SizedBox(height: 6),
        Text(
          'Paste a job description. Kael scores your fit and builds a CV with only the most relevant experience, projects, skills, and certifications.',
          style: cv.body(size: 12).copyWith(color: cv.textColor.withValues(alpha: 0.6)),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _jobController,
          maxLines: 12,
          style: cv.body(size: 13),
          decoration: cv.fieldDecoration('Job description').copyWith(
            alignLabelWithHint: true,
            hintText: 'Paste the full job posting here...',
            hintStyle: cv.body(size: 13).copyWith(color: cv.textColor.withValues(alpha: 0.35)),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _ActionButton(
              theme: theme,
              label: _isAnalyzing ? 'ANALYZING...' : 'ANALYZE MATCH',
              filled: true,
              onTap: _isAnalyzing ? null : _analyze,
            ),
            if (_result != null) ...[
              const SizedBox(width: 12),
              _ActionButton(
                theme: theme,
                label: 'PREVIEW TAILORED CV',
                onTap: _previewTailoredCv,
              ),
              const SizedBox(width: 12),
              _ActionButton(
                theme: theme,
                label: _isExporting ? 'EXPORTING...' : 'EXPORT TAILORED CV',
                onTap: _isExporting ? null : _exportTailoredCv,
              ),
            ],
          ],
        ),
        if (_error != null) ...[
          const SizedBox(height: 16),
          Text(_error!, style: cv.body(size: 12).copyWith(color: Colors.redAccent)),
        ],
        if (_isAnalyzing) ...[
          const SizedBox(height: 32),
          Center(
            child: SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 2, color: theme.accentGrey),
            ),
          ),
        ],
        if (_result != null) ...[
          const SizedBox(height: 32),
          _MatchScoreCard(result: _result!, theme: theme),
          const SizedBox(height: 24),
          _TailoredPreview(result: _result!),
        ],
      ],
    );
  }
}

class _ActionButton extends StatefulWidget {
  final KaelTheme theme;
  final String label;
  final VoidCallback? onTap;
  final bool filled;

  const _ActionButton({
    required this.theme,
    required this.label,
    this.onTap,
    this.filled = false,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: widget.onTap == null ? SystemMouseCursors.basic : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: widget.filled
                ? (widget.onTap == null ? Colors.grey : widget.theme.accentRed)
                : widget.theme.bouncyButtonFill(_hovered),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.filled
                  ? Colors.transparent
                  : (_hovered ? widget.theme.hoverBorder : widget.theme.sidebarBorder.withValues(alpha: 0.4)),
            ),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              color: widget.filled ? Colors.white : widget.theme.bouncyButtonText(_hovered),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
        ),
      ),
    );
  }
}

class _MatchScoreCard extends StatelessWidget {
  final JobMatchResult result;
  final KaelTheme theme;

  const _MatchScoreCard({required this.result, required this.theme});

  @override
  Widget build(BuildContext context) {
    final cv = CvThemeScope.of(context);

    return CvEntryCard(
      label: 'COMPATIBILITY',
      onRemove: () {},
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 88,
            height: 88,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: result.compatibilityPercent / 100,
                  strokeWidth: 6,
                  color: theme.accentRed,
                  backgroundColor: theme.sidebarBorder.withValues(alpha: 0.35),
                ),
                Text(
                  '${result.compatibilityPercent}%',
                  style: cv.heading(size: 18),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Match insights', style: cv.heading(size: 12)),
                const SizedBox(height: 10),
                ...result.matchNotes.map(
                  (note) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text('• $note', style: cv.body(size: 12).copyWith(height: 1.45)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TailoredPreview extends StatelessWidget {
  final JobMatchResult result;

  const _TailoredPreview({required this.result});

  @override
  Widget build(BuildContext context) {
    final cv = CvThemeScope.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('TAILORED CV PREVIEW', style: cv.heading(size: 14)),
        const SizedBox(height: 16),
        CvEntryCard(
          label: 'SUMMARY',
          onRemove: () {},
          child: Text(result.tailoredSummary, style: cv.body(size: 13).copyWith(height: 1.5)),
        ),
        if (result.skills.isNotEmpty)
          _ListCard(title: 'SKILLS', items: result.skills),
        if (result.experiences.isNotEmpty)
          _ListCard(
            title: 'EXPERIENCE',
            items: result.experiences
                .map((e) => '${e.jobTitle}${e.company.isNotEmpty ? ' @ ${e.company}' : ''}')
                .toList(),
          ),
        if (result.projects.isNotEmpty)
          _ListCard(title: 'PROJECTS', items: result.projects.map((p) => p.name).toList()),
        if (result.certifications.isNotEmpty)
          _ListCard(title: 'CERTIFICATIONS', items: result.certifications.map((c) => c.name).toList()),
        if (result.educationEntries.isNotEmpty)
          _ListCard(
            title: 'EDUCATION',
            items: result.educationEntries.map((e) => e.institution).toList(),
          ),
        if (result.languages.isNotEmpty)
          _ListCard(title: 'LANGUAGES', items: result.languages),
      ],
    );
  }
}

class _ListCard extends StatelessWidget {
  final String title;
  final List<String> items;

  const _ListCard({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    final cv = CvThemeScope.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: CvEntryCard(
        label: title,
        onRemove: () {},
        child: Text(items.join('  |  '), style: cv.body(size: 12).copyWith(height: 1.45)),
      ),
    );
  }
}
