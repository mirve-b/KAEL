import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:kael/SCREENS/FORMS/DATA%20MODEL/user_data_model.dart';
import 'package:kael/SCREENS/GLOBAL%20WIDGETS/kael_tab_bar.dart';
import 'package:kael/SCREENS/GLOBAL%20WIDGETS/kael_theme.dart';
import 'package:kael/SCREENS/HOME/PROVIDER/project_provider.dart';
import 'package:kael/SCREENS/PROFILE/SERVICES/cv_pdf_service.dart';
import 'package:kael/SCREENS/PROFILE/WIDGETS/cv_job_match_section.dart';
import 'package:kael/SCREENS/PROFILE/WIDGETS/cv_sections.dart';
import 'package:kael/SCREENS/PROFILE/WIDGETS/cv_ui_helpers.dart';
import 'package:kael/SCREENS/PROFILE/cv_sidebar.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

class PfpCV extends StatefulWidget {
  const PfpCV({super.key});

  @override
  State<PfpCV> createState() => _PfpCVState();
}

class _PfpCVState extends State<PfpCV> {
  List<String> openTabs = ["PROFILE"];
  String activeSection = "PROFILE";
  bool _isExporting = false;

  final List<String> sidebarSections = [
    "PROFILE",
    "EXPERIENCE",
    "PROJECTS",
    "SKILLS",
    "EDUCATION",
    "CERTIFICATIONS",
  ];

  Future<void> _previewCv() async {
    final user = Provider.of<UserDataModel>(context, listen: false);
    user.ensureEducationSeeded();
    final bytes = await CvPdfService.generate(user);

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
                    const Text(
                      'ATS CV PREVIEW',
                      style: TextStyle(color: Colors.white54, letterSpacing: 1.5, fontSize: 11),
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

  Future<void> _exportCv() async {
    if (_isExporting) return;
    setState(() => _isExporting = true);

    try {
      final user = Provider.of<UserDataModel>(context, listen: false);
      user.ensureEducationSeeded();
      final Uint8List bytes = await CvPdfService.generate(user);

      final safeName = user.name.trim().isEmpty
          ? 'KAEL_CV'
          : user.name.trim().replaceAll(RegExp(r'[^\w\s-]'), '').replaceAll(' ', '_');

      final path = await FilePicker.platform.saveFile(
        dialogTitle: 'Export CV as PDF',
        fileName: '${safeName}_CV.pdf',
        type: FileType.custom,
        allowedExtensions: const ['pdf'],
      );

      if (path != null) {
        await File(path).writeAsBytes(bytes);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('CV exported to $path'), duration: const Duration(seconds: 3)),
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
    final user = Provider.of<UserDataModel>(context);
    final theme = KaelTheme.of(context.watch<ProjectProvider>().isLightMode);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
        child: Row(
          children: [
            CVSidebar(
              user: user,
              activeSection: activeSection,
              sections: sidebarSections,
              isExporting: _isExporting,
              onSectionClick: (s) => setState(() {
                activeSection = s;
                if (!openTabs.contains(s)) openTabs.add(s);
              }),
              onPreview: _previewCv,
              onExport: _exportCv,
              onJobMatch: () => setState(() {
                activeSection = 'JOB MATCH';
                if (!openTabs.contains('JOB MATCH')) openTabs.add('JOB MATCH');
              }),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                children: [
                  KaelTabBar(
                    leadingLabel: "CV",
                    tabs: openTabs,
                    activeTab: activeSection,
                    onTabTap: (tab) => setState(() => activeSection = tab),
                    onTabClose: (tab) {
                      setState(() {
                        final indexToRemove = openTabs.indexOf(tab);
                        if (indexToRemove != -1) {
                          openTabs.removeAt(indexToRemove);
                          if (activeSection == tab) {
                            activeSection = openTabs.isNotEmpty
                                ? (indexToRemove > 0 ? openTabs[indexToRemove - 1] : openTabs[0])
                                : "";
                          }
                        }
                      });
                    },
                    onExit: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 20),
                  Expanded(child: _buildCVCanvas(user, theme)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCVCanvas(UserDataModel user, KaelTheme theme) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.cvCanvasBackground.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: theme.sidebarBorder.withValues(alpha: 0.4)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 40),
      child: activeSection.isEmpty
          ? Center(
              child: Text(
                'Open a section from the sidebar',
                style: TextStyle(color: theme.textMuted, letterSpacing: 1.2),
              ),
            )
          : CvThemeScope(
              theme: CvTheme(theme),
              child: SingleChildScrollView(
                child: _buildSectionContent(user, theme),
              ),
            ),
    );
  }

  Widget _buildSectionContent(UserDataModel user, KaelTheme theme) {
    switch (activeSection) {
      case 'PROFILE':
        return CvProfileSection(user: user);
      case 'EXPERIENCE':
        return CvExperienceSection(user: user);
      case 'PROJECTS':
        return CvProjectsSection(user: user);
      case 'SKILLS':
        return CvSkillsSection(user: user);
      case 'EDUCATION':
        return CvEducationSection(user: user);
      case 'CERTIFICATIONS':
        return CvCertificationsSection(user: user);
      case 'JOB MATCH':
        return CvJobMatchSection(user: user, theme: theme);
      default:
        return Center(
          child: Text(
            '$activeSection SECTION',
            style: TextStyle(color: theme.textMuted),
          ),
        );
    }
  }
}
