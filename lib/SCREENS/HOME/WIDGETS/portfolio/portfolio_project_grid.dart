import 'dart:io';
import 'package:flutter/material.dart';
import 'package:kael/SCREENS/GLOBAL%20WIDGETS/kael_theme.dart';
import 'package:kael/SCREENS/HOME/PROVIDER/project_provider.dart';
import 'package:kael/SCREENS/HOME/DATA%20MODEL/project_model.dart';

class PortfolioProjectGrid extends StatelessWidget {
  final ProjectProvider projectsProvider;
  final KaelTheme theme;
  final Function(String?) onProjectSelect;

  const PortfolioProjectGrid({
    super.key,
    required this.projectsProvider,
    required this.theme,
    required this.onProjectSelect,
  });

  @override
  Widget build(BuildContext context) {
    final savedCaseStudies = projectsProvider.savedProjectsForPortfolio;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 30),
          child: Text(
            "MY WORK",
            style: TextStyle(
              color: theme.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
            ),
          ),
        ),
        if (savedCaseStudies.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 30, top: 4),
            child: Text(
              'DRAG HANDLE TO REORDER · RIGHT-CLICK THUMBNAIL TO CHANGE',
              style: TextStyle(color: theme.textMuted, fontSize: 9, letterSpacing: 1.0),
            ),
          ),
        const SizedBox(height: 10),
        savedCaseStudies.isEmpty
            ? Container(
                width: double.infinity,
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: theme.portfolioSurface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    "NO COMPLETED CASE STUDIES SAVED",
                    style: TextStyle(color: theme.textDim, fontSize: 10),
                  ),
                ),
              )
            : Container(
                width: double.infinity,
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: theme.portfolioSurface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: theme.portfolioSurfaceBorder, width: 1),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount = constraints.maxWidth > 1000 ? 4 : 3;
                    double spacing = 30;
                    double cardWidth = (constraints.maxWidth - (spacing * (crossAxisCount - 1)) - 50) / crossAxisCount;
                    double cardHeight = cardWidth * 0.8;

                    return Wrap(
                      spacing: spacing,
                      runSpacing: 20,
                      children: savedCaseStudies.asMap().entries.map((entry) {
                        final index = entry.key;
                        final project = entry.value;
                        return SizedBox(
                          key: ValueKey('${project.id}_${project.portfolioThumbnailPath}'),
                          width: cardWidth,
                          height: cardHeight + 36,
                          child: _ReorderableProjectCard(
                            index: index,
                            project: project,
                            theme: theme,
                            projectsProvider: projectsProvider,
                            targetHeight: cardHeight,
                            onTap: onProjectSelect,
                            onReorder: projectsProvider.reorderPortfolioProjects,
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
      ],
    );
  }
}

class _ReorderableProjectCard extends StatefulWidget {
  final int index;
  final ProjectPage project;
  final KaelTheme theme;
  final ProjectProvider projectsProvider;
  final double targetHeight;
  final Function(String?) onTap;
  final void Function(int oldIndex, int newIndex) onReorder;

  const _ReorderableProjectCard({
    required this.index,
    required this.project,
    required this.theme,
    required this.projectsProvider,
    required this.targetHeight,
    required this.onTap,
    required this.onReorder,
  });

  @override
  State<_ReorderableProjectCard> createState() => _ReorderableProjectCardState();
}

class _ReorderableProjectCardState extends State<_ReorderableProjectCard> {
  bool _isHovered = false;
  bool _isDragging = false;

  String? get _thumbnailPath => widget.project.portfolioThumbnail;

  void _showThumbnailMenu(TapDownDetails details) {
    final images = widget.project.allImagePaths;
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    showMenu<String>(
      context: context,
      color: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      position: RelativeRect.fromRect(
        details.globalPosition & const Size(1, 1),
        Offset.zero & overlay.size,
      ),
      items: [
        if (images.isNotEmpty)
          const PopupMenuItem<String>(
            enabled: false,
            child: Text('SELECT FROM PROJECT', style: TextStyle(color: Colors.white38, fontSize: 9, letterSpacing: 1.2)),
          ),
        ...images.map((path) {
          final name = path.split('/').last;
          final isSelected = widget.project.portfolioThumbnailPath == path ||
              (widget.project.portfolioThumbnailPath == null && path == images.first);
          return PopupMenuItem<String>(
            value: path,
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.file(File(path), width: 36, height: 28, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(width: 36, height: 28, color: Colors.white10)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    name,
                    style: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontSize: 11),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isSelected) const Icon(Icons.check, size: 14, color: Colors.redAccent),
              ],
            ),
          );
        }),
        const PopupMenuDivider(height: 8),
        const PopupMenuItem<String>(
          value: '__pick__',
          child: Text('Choose from device…', style: TextStyle(color: Colors.white70, fontSize: 11)),
        ),
        if (widget.project.portfolioThumbnailPath != null)
          const PopupMenuItem<String>(
            value: '__reset__',
            child: Text('Reset to default', style: TextStyle(color: Colors.white54, fontSize: 11)),
          ),
      ],
    ).then((value) {
      if (value == null || !mounted) return;
      if (value == '__pick__') {
        widget.projectsProvider.pickProjectPortfolioThumbnail(widget.project.id);
      } else if (value == '__reset__') {
        widget.projectsProvider.setProjectPortfolioThumbnail(widget.project.id, null);
      } else {
        widget.projectsProvider.setProjectPortfolioThumbnail(widget.project.id, value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DragTarget<int>(
      onWillAcceptWithDetails: (details) => details.data != widget.index,
      onAcceptWithDetails: (details) => widget.onReorder(details.data, widget.index),
      builder: (context, candidateData, rejectedData) {
        final isDropTarget = candidateData.isNotEmpty;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: isDropTarget ? Border.all(color: widget.theme.selectedBorder, width: 2) : null,
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              _cardBody(dragging: _isDragging),
              Positioned(
                top: 6,
                left: 6,
                child: Draggable<int>(
                  data: widget.index,
                  onDragStarted: () => setState(() => _isDragging = true),
                  onDragEnd: (_) => setState(() => _isDragging = false),
                  feedback: Material(
                    color: Colors.transparent,
                    child: Opacity(
                      opacity: 0.92,
                      child: SizedBox(
                        width: 140,
                        height: widget.targetHeight + 20,
                        child: _cardBody(dragging: true, hideHandle: true),
                      ),
                    ),
                  ),
                  childWhenDragging: const SizedBox(width: 28, height: 28),
                  child: _dragHandle(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _dragHandle() {
    return MouseRegion(
      cursor: SystemMouseCursors.grab,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.white24),
        ),
        child: Icon(Icons.drag_indicator, size: 14, color: Colors.white.withValues(alpha: 0.85)),
      ),
    );
  }

  Widget _cardBody({required bool dragging, bool hideHandle = false}) {
    final thumb = _thumbnailPath;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => widget.onTap(widget.project.id),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          transform: Matrix4.identity()..scale(_isHovered && !dragging ? 1.03 : 1.0),
          transformAlignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onSecondaryTapDown: _showThumbnailMenu,
                child: Container(
                  height: widget.targetHeight,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: widget.theme.isLightMode
                        ? Colors.white.withValues(alpha: 0.65)
                        : const Color.fromARGB(255, 25, 25, 25),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _isHovered ? widget.theme.hoverBorder : widget.theme.portfolioSurfaceBorder,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (thumb != null)
                        Image.file(
                          File(thumb),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildTextThumbnail(),
                        )
                      else
                        _buildTextThumbnail(),
                      if (_isHovered && !hideHandle)
                        Positioned(
                          top: 6,
                          right: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.55),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'RIGHT-CLICK',
                              style: TextStyle(color: Colors.white70, fontSize: 7, letterSpacing: 0.8),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 2),
                child: Text(
                  widget.project.title.toUpperCase(),
                  style: TextStyle(
                    color: widget.theme.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextThumbnail() {
    return Center(
      child: Text(
        widget.project.title.toUpperCase(),
        textAlign: TextAlign.center,
        style: TextStyle(
          color: widget.theme.accentGrey.withValues(alpha: 0.7),
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
