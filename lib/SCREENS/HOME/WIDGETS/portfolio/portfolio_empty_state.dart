import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:kael/SCREENS/FORMS/DATA%20MODEL/user_data_model.dart';
import 'package:kael/SCREENS/GLOBAL%20WIDGETS/kael_theme.dart';

class PortfolioEmptyState extends StatefulWidget {
  final UserDataModel userData;
  final KaelTheme theme;
  final VoidCallback onGenerateTap;

  const PortfolioEmptyState({
    super.key,
    required this.userData,
    required this.theme,
    required this.onGenerateTap,
  });

  @override
  State<PortfolioEmptyState> createState() => _PortfolioEmptyStateState();
}

class _PortfolioEmptyStateState extends State<PortfolioEmptyState> {
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

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.userData.portfolioTemplateId;

    return ClipRRect(
      key: const ValueKey('EmptyPortfolioState'),
      borderRadius: BorderRadius.circular(25),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(95, 12, 12, 12),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.white10),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.art_track_rounded,
                    color: const Color(0xFF6E6E6E).withValues(alpha: 0.35),
                    size: 70,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'NO PORTFOLIO ACTIVATED',
                    style: TextStyle(
                      color: Color(0xFF9A9A9A),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4.0,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Compile your generated case studies into an opulent showcase layout.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white10, fontSize: 11, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'CHOOSE A TEMPLATE TO CREATE A PORTFOLIO',
                    style: TextStyle(
                      color: Color(0xFF9A9A9A),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 520;
                      final cardWidth = isWide ? 200.0 : (constraints.maxWidth - 16) / 2;
                      final cardHeight = cardWidth * 1.15;

                      return Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          _TemplateCard(
                            width: cardWidth,
                            height: cardHeight,
                            label: 'TEMPLATE 1',
                            isSelected: selected == 'template1',
                            preview: _Template1Preview(theme: widget.theme),
                            onTap: () => widget.userData.updatePortfolioTemplate('template1'),
                          ),
                          _TemplateCard(
                            width: cardWidth,
                            height: cardHeight,
                            label: 'TEMPLATE 2',
                            isSelected: selected == 'template2',
                            preview: _Template2Preview(theme: widget.theme),
                            onTap: () => widget.userData.updatePortfolioTemplate('template2'),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  GestureDetector(
                    onTap: widget.onGenerateTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFB71C1C),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Text(
                        'GENERATE YOUR PORTFOLIO',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TemplateCard extends StatefulWidget {
  final double width;
  final double height;
  final String label;
  final bool isSelected;
  final Widget preview;
  final VoidCallback onTap;

  const _TemplateCard({
    required this.width,
    required this.height,
    required this.label,
    required this.isSelected,
    required this.preview,
    required this.onTap,
  });

  @override
  State<_TemplateCard> createState() => _TemplateCardState();
}

class _TemplateCardState extends State<_TemplateCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: widget.width,
          height: widget.height,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color.fromARGB(60, 255, 255, 255),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: widget.isSelected
                  ? const Color(0xFFB71C1C)
                  : _hovered
                      ? Colors.white38
                      : Colors.white12,
              width: widget.isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Expanded(child: widget.preview),
              const SizedBox(height: 8),
              Text(
                widget.label,
                style: TextStyle(
                  color: widget.isSelected ? Colors.white : const Color(0xFF9A9A9A),
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Template1Preview extends StatelessWidget {
  final KaelTheme theme;

  const _Template1Preview({required this.theme});

  @override
  Widget build(BuildContext context) {
    final surface = theme.portfolioSurface;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Column(
        children: [
          Container(height: 28, color: surface),
          const SizedBox(height: 4),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(color: surface.withValues(alpha: 0.7)),
                ),
                const SizedBox(width: 4),
                Expanded(child: Container(color: surface)),
              ],
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 24,
            child: Row(
              children: List.generate(
                3,
                (i) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: i < 2 ? 4 : 0),
                    child: Container(color: surface),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Template2Preview extends StatelessWidget {
  final KaelTheme theme;

  const _Template2Preview({required this.theme});

  @override
  Widget build(BuildContext context) {
    final surface = theme.portfolioSurface;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Column(
        children: [
          Container(height: 42, color: surface),
          const SizedBox(height: 4),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(color: surface.withValues(alpha: 0.7)),
                ),
                const SizedBox(width: 4),
                Expanded(child: Container(color: surface)),
              ],
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 16,
            child: Row(
              children: List.generate(
                4,
                (i) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: i < 3 ? 3 : 0),
                    child: Container(color: surface),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 18,
            child: Row(
              children: List.generate(
                3,
                (i) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: i < 2 ? 4 : 0),
                    child: Container(color: surface),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
