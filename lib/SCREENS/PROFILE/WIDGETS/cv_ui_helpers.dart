import 'package:flutter/material.dart';
import 'package:kael/SCREENS/GLOBAL%20WIDGETS/kael_theme.dart';
import 'package:material_symbols_icons/symbols.dart';

class CvThemeScope extends InheritedWidget {
  final CvTheme theme;

  const CvThemeScope({super.key, required this.theme, required super.child});

  static CvTheme of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<CvThemeScope>()!.theme;

  @override
  bool updateShouldNotify(CvThemeScope oldWidget) => theme.kael.isLightMode != oldWidget.theme.kael.isLightMode;
}

class CvTheme {
  final KaelTheme kael;

  const CvTheme(this.kael);

  Color get textColor => kael.cvText;

  Color get cardColor => kael.cvCardBackground;

  Color get borderColor => kael.cvCardBorder;

  TextStyle heading({double size = 14}) => TextStyle(
        color: textColor,
        fontSize: size,
        letterSpacing: 1.2,
        fontVariations: const [FontVariation('wght', 400.0)],
      );

  TextStyle body({double size = 14}) => TextStyle(
        color: textColor,
        fontSize: size,
        fontVariations: const [FontVariation('wght', 300.0)],
      );

  InputDecoration fieldDecoration(String label) => InputDecoration(
        labelText: label,
        labelStyle: body(size: 12).copyWith(color: textColor.withValues(alpha: 0.65)),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: kael.cvFieldBorder),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: textColor.withValues(alpha: 0.85)),
        ),
        isDense: true,
      );
}

class CvSectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onAdd;

  const CvSectionHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final cv = CvThemeScope.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: cv.heading(size: 16)),
              const SizedBox(height: 4),
              Text(subtitle, style: cv.body(size: 12).copyWith(color: cv.textColor.withValues(alpha: 0.6))),
            ],
          ),
        ),
        if (onAdd != null)
          TextButton.icon(
            onPressed: onAdd,
            icon: Icon(Symbols.add, size: 16, color: cv.textColor),
            label: Text('ADD', style: cv.body(size: 11).copyWith(letterSpacing: 1.2)),
            style: TextButton.styleFrom(
              side: BorderSide(color: cv.textColor.withValues(alpha: 0.35)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
          ),
      ],
    );
  }
}

class CvEntryCard extends StatelessWidget {
  final Widget child;
  final VoidCallback onRemove;
  final String? label;

  const CvEntryCard({
    super.key,
    required this.child,
    required this.onRemove,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final cv = CvThemeScope.of(context);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cv.cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cv.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (label != null)
                Expanded(child: Text(label!, style: cv.body(size: 11).copyWith(letterSpacing: 1.1))),
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Symbols.delete_outline, size: 18, color: Colors.redAccent),
                tooltip: 'Remove',
              ),
            ],
          ),
          child,
        ],
      ),
    );
  }
}

class CvEmptyState extends StatelessWidget {
  final String message;
  final VoidCallback onAdd;

  const CvEmptyState({super.key, required this.message, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final cv = CvThemeScope.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(message, style: cv.body(size: 13).copyWith(color: cv.textColor.withValues(alpha: 0.45))),
          const SizedBox(height: 16),
          TextButton(
            onPressed: onAdd,
            style: TextButton.styleFrom(
              side: BorderSide(color: cv.textColor.withValues(alpha: 0.35)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text('ADD FIRST ENTRY', style: cv.body(size: 11).copyWith(letterSpacing: 1.2)),
          ),
        ],
      ),
    );
  }
}

class CvChipField extends StatefulWidget {
  final List<String> items;
  final ValueChanged<List<String>> onChanged;
  final String label;

  const CvChipField({
    super.key,
    required this.items,
    required this.onChanged,
    required this.label,
  });

  @override
  State<CvChipField> createState() => _CvChipFieldState();
}

class _CvChipFieldState extends State<CvChipField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addItem() {
    final value = _controller.text.trim();
    if (value.isEmpty || widget.items.contains(value)) return;
    widget.onChanged([...widget.items, value]);
    _controller.clear();
  }

  void _removeItem(int index) {
    final updated = [...widget.items]..removeAt(index);
    widget.onChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    final cv = CvThemeScope.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: cv.body(size: 12).copyWith(color: cv.textColor.withValues(alpha: 0.7))),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...widget.items.asMap().entries.map(
              (entry) => Chip(
                label: Text(entry.value, style: cv.body(size: 12)),
                deleteIcon: const Icon(Symbols.close, size: 14),
                onDeleted: () => _removeItem(entry.key),
                backgroundColor: cv.textColor.withValues(alpha: 0.12),
                side: BorderSide.none,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                style: cv.body(size: 13),
                decoration: cv.fieldDecoration('Type and press Add'),
                onSubmitted: (_) => _addItem(),
              ),
            ),
            const SizedBox(width: 10),
            TextButton(
              onPressed: _addItem,
              child: Text('ADD', style: cv.body(size: 11)),
            ),
          ],
        ),
      ],
    );
  }
}
