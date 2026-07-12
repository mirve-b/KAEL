import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:kael/SCREENS/FORMS/DATA%20MODEL/user_data_model.dart';
import 'package:kael/SCREENS/GLOBAL%20WIDGETS/kael_theme.dart';

class PortfolioWorkGallery extends StatefulWidget {
  final UserDataModel userData;
  final KaelTheme theme;

  const PortfolioWorkGallery({
    super.key,
    required this.userData,
    required this.theme,
  });

  @override
  State<PortfolioWorkGallery> createState() => _PortfolioWorkGalleryState();
}

class _PortfolioWorkGalleryState extends State<PortfolioWorkGallery> {
  static const _addToken = '__add__';
  static const _gap = 10.0;
  static const _widthPatterns = [
    [0.20, 0.36, 0.28, 0.16],
    [0.24, 0.24, 0.28, 0.24],
    [0.42, 0.30, 0.28],
    [0.18, 0.34, 0.22, 0.26],
    [0.30, 0.30, 0.40],
    [0.22, 0.22, 0.32, 0.24],
  ];

  int? _hoveredIndex;

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

  Future<void> _pickAndAddImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      widget.userData.addGalleryImage(result.files.single.path!);
    }
  }

  Future<void> _pickReplaceImage(int index) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      widget.userData.replaceGalleryImageAt(index, result.files.single.path!);
    }
  }

  void _showImageMenu(int index, TapDownDetails details) {
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    showMenu<String>(
      context: context,
      color: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      position: RelativeRect.fromRect(
        details.globalPosition & const Size(1, 1),
        Offset.zero & overlay.size,
      ),
      items: const [
        PopupMenuItem(
          value: 'replace',
          child: Text('Replace image', style: TextStyle(color: Colors.white70, fontSize: 11)),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Text('Remove image', style: TextStyle(color: Colors.redAccent, fontSize: 11)),
        ),
      ],
    ).then((value) {
      if (value == null || !mounted) return;
      if (value == 'replace') {
        _pickReplaceImage(index);
      } else if (value == 'delete') {
        widget.userData.removeGalleryImageAt(index);
      }
    });
  }

  List<_GalleryRow> _buildRows(List<String> images) {
    final items = [...images, _addToken];
    final rows = <_GalleryRow>[];
    var cursor = 0;
    var patternIndex = 0;

    while (cursor < items.length) {
      final pattern = _widthPatterns[patternIndex % _widthPatterns.length];
      final rowHeight = patternIndex.isEven ? 156.0 : 108.0;
      final rowItems = <_GalleryCell>[];
      var patternCursor = 0;
      var widthUsed = 0.0;

      while (cursor < items.length && patternCursor < pattern.length) {
        final fraction = pattern[patternCursor];
        if (widthUsed > 0 && widthUsed + fraction > 1.02) break;

        final item = items[cursor];
        rowItems.add(
          _GalleryCell(
            token: item,
            imageIndex: item == _addToken ? null : cursor,
            widthFraction: fraction,
          ),
        );

        widthUsed += fraction;
        cursor++;
        patternCursor++;
      }

      if (rowItems.isEmpty) break;

      rows.add(_GalleryRow(cells: rowItems, height: rowHeight));
      patternIndex++;
    }

    return rows;
  }

  @override
  Widget build(BuildContext context) {
    final textColor = widget.theme.textPrimary;
    final surface = widget.theme.portfolioOpaqueSurface;
    final images = widget.userData.activeGalleryImages;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
          color: surface,
          child: Column(
            children: [
                Text(
                  'WORK GALLERY',
                  style: TextStyle(
                    fontFamily: 'AnticDidone',
                    color: widget.userData.resolveHeadingColor(widget.theme),
                  fontSize: 34,
                  letterSpacing: 3.0,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 18),
              LayoutBuilder(
                builder: (context, constraints) {
                  final rows = _buildRows(images);
                  if (rows.isEmpty) {
                    return SizedBox(
                      height: 140,
                      child: _addTile(textColor, surface, width: constraints.maxWidth),
                    );
                  }

                  return Column(
                    children: [
                      for (var i = 0; i < rows.length; i++) ...[
                        _buildRow(
                          row: rows[i],
                          rowWidth: constraints.maxWidth,
                          textColor: textColor,
                          surface: surface,
                        ),
                        if (i < rows.length - 1) const SizedBox(height: _gap),
                      ],
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRow({
    required _GalleryRow row,
    required double rowWidth,
    required Color textColor,
    required Color surface,
  }) {
    final gaps = _gap * (row.cells.length - 1);
    final usableWidth = rowWidth - gaps;

    return SizedBox(
      height: row.height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < row.cells.length; i++) ...[
            SizedBox(
              width: usableWidth * row.cells[i].widthFraction,
              child: row.cells[i].token == _addToken
                  ? _addTile(textColor, surface, width: usableWidth * row.cells[i].widthFraction)
                  : _imageTile(
                      index: row.cells[i].imageIndex!,
                      path: widget.userData.activeGalleryImages[row.cells[i].imageIndex!],
                      textColor: textColor,
                      surface: surface,
                    ),
            ),
            if (i < row.cells.length - 1) const SizedBox(width: _gap),
          ],
        ],
      ),
    );
  }

  Widget _imageTile({
    required int index,
    required String path,
    required Color textColor,
    required Color surface,
  }) {
    final hovered = _hoveredIndex == index;

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredIndex = index),
      onExit: (_) => setState(() => _hoveredIndex = null),
      child: GestureDetector(
        onTap: () => _pickReplaceImage(index),
        onSecondaryTapDown: (d) => _showImageMenu(index, d),
        child: Container(
          decoration: BoxDecoration(
            color: surface,
            border: Border.all(
              color: hovered ? widget.theme.hoverBorder : widget.theme.portfolioSurfaceBorder,
            ),
            image: DecorationImage(
              image: FileImage(File(path)),
              fit: BoxFit.cover,
            ),
          ),
          child: hovered
              ? Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () => _pickReplaceImage(index),
                          child: _chip('EDIT'),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => widget.userData.removeGalleryImageAt(index),
                          child: _chip('DELETE'),
                        ),
                      ],
                    ),
                  ),
                )
              : null,
        ),
      ),
    );
  }

  Widget _addTile(Color textColor, Color surface, {required double width}) {
    final hovered = _hoveredIndex == -1;

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredIndex = -1),
      onExit: (_) => setState(() => _hoveredIndex = null),
      child: GestureDetector(
        onTap: _pickAndAddImage,
        child: Container(
          width: width,
          decoration: BoxDecoration(
            color: surface,
            border: Border.all(
              color: hovered ? widget.theme.hoverBorder : widget.theme.portfolioSurfaceBorder,
            ),
          ),
          child: Stack(
            children: [
              Center(
                child: Text(
                  '+ ADD WORK',
                  style: TextStyle(
                    color: textColor.withValues(alpha: 0.4),
                    fontSize: 10,
                    letterSpacing: 1.8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (hovered)
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: _chip('ADD'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      color: Colors.black.withValues(alpha: 0.65),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white70, fontSize: 8, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _GalleryRow {
  final List<_GalleryCell> cells;
  final double height;

  const _GalleryRow({required this.cells, required this.height});
}

class _GalleryCell {
  final String token;
  final int? imageIndex;
  final double widthFraction;

  const _GalleryCell({
    required this.token,
    required this.imageIndex,
    required this.widthFraction,
  });
}
