import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:kael/SCREENS/FORMS/DATA%20MODEL/user_data_model.dart';
import 'package:kael/SCREENS/GLOBAL%20WIDGETS/kael_theme.dart';
import 'package:kael/SCREENS/HOME/PROVIDER/project_provider.dart';
import 'package:provider/provider.dart';
import 'package:kael/SCREENS/HOME/WIDGETS/casestudy/home_casestudy.dart';
import 'package:kael/SCREENS/HOME/WIDGETS/portfolio/portfolio_about_section.dart';
import 'package:kael/SCREENS/HOME/WIDGETS/portfolio/portfolio_empty_state.dart';
import 'package:kael/SCREENS/HOME/WIDGETS/portfolio/portfolio_hero_banner.dart';
import 'package:kael/SCREENS/HOME/WIDGETS/portfolio/portfolio_project_grid.dart';

class HomePortfolio extends StatefulWidget {
  final UserDataModel userData;
  final ProjectProvider projectsProvider;
  final bool isGenerated;
  final VoidCallback onGenerateTap;
  final String? activeProjectId;
  final Function(String?) onProjectSelect;

  const HomePortfolio({
    super.key,
    required this.userData,
    required this.projectsProvider,
    required this.isGenerated,
    required this.onGenerateTap,
    required this.activeProjectId,
    required this.onProjectSelect,
  });

  @override
  State<HomePortfolio> createState() => _HomePortfolioState();
}

class _HomePortfolioState extends State<HomePortfolio> {
  @override
  void initState() {
    super.initState();
    widget.userData.addListener(_refresh);
  }

  @override
  void dispose() {
    widget.userData.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final theme = KaelTheme.of(context.watch<ProjectProvider>().isLightMode);

    return ListenableBuilder(
      listenable: widget.userData,
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      child: !widget.isGenerated
                          ? PortfolioEmptyState(onGenerateTap: widget.onGenerateTap)
                          : _buildLivePortfolioCanvas(constraints.maxWidth, theme),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: constraints.maxWidth,
                  child: PortfolioCustomizer(userData: widget.userData, theme: theme),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildLivePortfolioCanvas(double width, KaelTheme theme) {
    if (widget.activeProjectId != null) {
      final activeProject = widget.projectsProvider.projects.firstWhere(
        (p) => p.id == widget.activeProjectId,
        orElse: () => widget.projectsProvider.savedProjectsForPortfolio.first,
      );

      return _buildGlassShell(
        width: width,
        theme: theme,
        child: CaseStudyView(
          project: activeProject,
          theme: theme,
          glassMode: true,
          onBackToEdit: () => widget.onProjectSelect(null),
          onDonePressed: () => widget.onProjectSelect(null),
        ),
      );
    }

    return _buildGlassShell(
      width: width,
      theme: theme,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        child: DefaultTextStyle(
          style: TextStyle(
            fontFamily: widget.userData.fontFamily,
            color: theme.textPrimary,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              PortfolioHeroBanner(userData: widget.userData, theme: theme),
              const SizedBox(height: 10),
              PortfolioAboutSection(userData: widget.userData, theme: theme),
              const SizedBox(height: 10),
              PortfolioProjectGrid(
                projectsProvider: widget.projectsProvider,
                theme: theme,
                onProjectSelect: widget.onProjectSelect,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassShell({
    required double width,
    required KaelTheme theme,
    required Widget child,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      width: width,
      height: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: theme.sidebarBorder.withValues(alpha: 0.35)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            color: Color.alphaBlend(
              widget.userData.portfolioBgColor.withValues(alpha: 0.48),
              theme.panelBackground.withValues(alpha: 0.94),
            ),
            padding: const EdgeInsets.all(24),
            child: child,
          ),
        ),
      ),
    );
  }
}

class PortfolioCustomizer extends StatefulWidget {
  final UserDataModel userData;
  final KaelTheme theme;

  const PortfolioCustomizer({super.key, required this.userData, required this.theme});

  @override
  State<PortfolioCustomizer> createState() => _PortfolioCustomizerState();
}

class _PortfolioCustomizerState extends State<PortfolioCustomizer> {
  void _pickColor(bool isBg) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isBg ? 'Background Color' : 'Text Color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: isBg ? widget.userData.portfolioBgColor : widget.userData.textColor,
            onColorChanged: (c) => widget.userData.updatePortfolioTheme(bg: isBg ? c : null, text: isBg ? null : c),
          ),
        ),
      ),
    );
  }

  void _showFontOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['Inter', 'Serif', 'Monospace'].map((f) => ListTile(
            title: Text(f, style: TextStyle(fontFamily: f, color: Colors.white)),
            onTap: () {
              widget.userData.updatePortfolioTheme(font: f);
              Navigator.pop(context);
            },
          )).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: theme.bottomBarBackground,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: theme.sidebarBorder.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("STYLE", style: TextStyle(color: theme.textMuted, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
          const SizedBox(width: 20),
          _CustomBouncyButton(label: "FONT", theme: theme, onTap: _showFontOptions),
          _CustomBouncyButton(label: "TEXT COLOUR", theme: theme, onTap: () => _pickColor(false)),
          _CustomBouncyButton(label: "BG COLOUR", theme: theme, onTap: () => _pickColor(true)),
        ],
      ),
    );
  }
}

class _CustomBouncyButton extends StatefulWidget {
  final String label;
  final KaelTheme theme;
  final VoidCallback onTap;

  const _CustomBouncyButton({required this.label, required this.theme, required this.onTap});

  @override
  State<_CustomBouncyButton> createState() => _CustomBouncyButtonState();
}

class _CustomBouncyButtonState extends State<_CustomBouncyButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutBack,
        padding: EdgeInsets.symmetric(horizontal: _isHovered ? 20 : 5),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOutBack,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            decoration: BoxDecoration(
              color: theme.bouncyButtonFill(_isHovered),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _isHovered ? theme.hoverBorder : Colors.transparent,
              ),
            ),
            child: Text(
              widget.label,
              style: TextStyle(
                color: theme.bouncyButtonText(_isHovered),
                fontSize: 11,
                fontWeight: _isHovered ? FontWeight.bold : FontWeight.normal,
                letterSpacing: 1.1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
