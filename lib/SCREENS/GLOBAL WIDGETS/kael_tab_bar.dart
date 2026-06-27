import 'package:flutter/material.dart';
import 'package:kael/SCREENS/GLOBAL%20WIDGETS/kael_theme.dart';
import 'package:kael/SCREENS/HOME/PROVIDER/project_provider.dart';
import 'package:provider/provider.dart';

class KaelTabBar extends StatelessWidget {
  final String leadingLabel;
  final List<String> tabs;
  final String activeTab;
  final Function(String) onTabTap;
  final Function(String) onTabClose;
  final VoidCallback? onExit;

  const KaelTabBar({
    super.key,
    required this.leadingLabel,
    required this.tabs,
    required this.activeTab,
    required this.onTabTap,
    required this.onTabClose,
    this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = KaelTheme.of(context.watch<ProjectProvider>().isLightMode);

    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: theme.tabBarBackground,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: theme.sidebarBorder.withValues(alpha: 0.5)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: [
          Text(leadingLabel, style: TextStyle(color: theme.textMuted, fontSize: 11)),
          const SizedBox(width: 15),
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              children: tabs
                  .map(
                    (tab) => _AnimatedTabItem(
                      label: tab,
                      isSelected: activeTab == tab,
                      theme: theme,
                      onTap: () => onTabTap(tab),
                      onCloseTap: () => onTabClose(tab),
                    ),
                  )
                  .toList(),
            ),
          ),
          if (onExit != null)
            IconButton(
              icon: Icon(Icons.close, color: theme.textDim, size: 18),
              onPressed: onExit,
            )
        ],
      ),
    );
  }
}

class _AnimatedTabItem extends StatefulWidget {
  final String label;
  final bool isSelected;
  final KaelTheme theme;
  final VoidCallback onTap;
  final VoidCallback onCloseTap;

  const _AnimatedTabItem({
    required this.label,
    required this.isSelected,
    required this.theme,
    required this.onTap,
    required this.onCloseTap,
  });

  @override
  State<_AnimatedTabItem> createState() => _AnimatedTabItemState();
}

class _AnimatedTabItemState extends State<_AnimatedTabItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    bool isActive = widget.isSelected || _isHovered;

    return Center(
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutBack,
            margin: const EdgeInsets.only(right: 8),
            padding: EdgeInsets.symmetric(
              vertical: _isHovered ? 8 : 6,
              horizontal: _isHovered ? 16 : 12,
            ),
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? theme.selectedBackground
                  : (_isHovered ? theme.hoverBackground : Colors.transparent),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: (_isHovered && !widget.isSelected) ? theme.hoverBorder : Colors.transparent,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
                  style: TextStyle(
                    color: widget.isSelected || _isHovered ? theme.textPrimary : theme.textDim,
                    fontSize: _isHovered ? 11.5 : 11,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                  child: Text(widget.label),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: widget.onCloseTap,
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedRotation(
                    duration: const Duration(milliseconds: 200),
                    turns: _isHovered ? 0.25 : 0.0,
                    child: Icon(
                      Icons.close,
                      size: 10,
                      color: _isHovered ? theme.textMuted : theme.textDim,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
