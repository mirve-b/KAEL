import 'dart:io';
import 'package:flutter/material.dart';
import 'package:kael/SCREENS/FORMS/DATA%20MODEL/user_data_model.dart';
import 'package:kael/SCREENS/HOME/PROVIDER/project_provider.dart';
import 'package:kael/SCREENS/GLOBAL%20WIDGETS/kael_theme.dart';
import 'package:kael/SCREENS/PROFILE/pfp_cv.dart';

class HomeSidebar extends StatelessWidget {
  final UserDataModel userData;
  final ProjectProvider projectData;
  final bool isCatalogExpanded;
  final List<String> openTabIds;
  final String currentNavSection; 
  final VoidCallback onToggleCatalog;
  final Function(String) onSectionTap; 
  final Function(int) onProjectTap;
  final Function(int, String) onRenameRequest;
  final Function(int, String) onDeleteRequest;

  const HomeSidebar({
    super.key,
    required this.userData,
    required this.projectData,
    required this.isCatalogExpanded,
    required this.openTabIds,
    required this.currentNavSection, 
    required this.onToggleCatalog,
    required this.onSectionTap, 
    required this.onProjectTap,
    required this.onRenameRequest,
    required this.onDeleteRequest,
  });

  @override
  Widget build(BuildContext context) {
    final theme = KaelTheme.of(projectData.isLightMode);

    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: theme.sidebarBackground,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: theme.sidebarBorder, width: 1.5),
      ),
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // REACTIONARY ANIMATED HEADER 
          _AnimatedUserHeader(userData: userData, theme: theme),
          const SizedBox(height: 40),
          
          // --- CANVAS SECTION ---
          _AnimatedHomeCategory(
            label: "CANVAS",
            isSelected: currentNavSection == "CANVAS",
            theme: theme,
            onTap: () => onSectionTap("CANVAS"),
          ), 
          
          const SizedBox(height: 6),

          // --- CATALOG SECTION (DOUBLE TAP ACTIVATED) ---
          _AnimatedHomeCategory(
            label: "CATALOG",
            isSelected: currentNavSection == "CATALOG",
            theme: theme,
            onTap: onToggleCatalog,
            onDoubleTapDetails: (details) => _showAddMenu(context, details),
            trailing: Icon(
              isCatalogExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: currentNavSection == "CATALOG" 
                  ? Colors.red.shade900 
                  : const Color.fromARGB(255, 120, 110, 95),
              size: 14,
            ),
          ),
          
          if (isCatalogExpanded) ...[
            const SizedBox(height: 4),
            ...projectData.projects.asMap().entries.map((entry) {
              bool isSelected = projectData.currentIndex == entry.key && currentNavSection == "CATALOG";
              return _AnimatedProjectItem(
                title: entry.value.title,
                isSelected: isSelected,
                theme: theme,
                onTap: () => onProjectTap(entry.key),
                onSecondaryTapDown: (details) {
                  final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
                  showMenu(
                    context: context,
                    color: const Color(0xFF1A1A1A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    position: RelativeRect.fromRect(
                      details.globalPosition & const Size(40, 40),
                      Offset.zero & overlay.size,
                    ),
                    items: [
                      PopupMenuItem(
                        onTap: () => Future.delayed(Duration.zero, () => onRenameRequest(entry.key, entry.value.title)),
                        child: const Text("Rename", style: TextStyle(color: Colors.white, fontSize: 12)),
                      ),
                      PopupMenuItem(
                        onTap: () => Future.delayed(Duration.zero, () => onDeleteRequest(entry.key, entry.value.title)),
                        child: const Text("Delete", style: TextStyle(color: Colors.redAccent, fontSize: 12)),
                      ),
                    ],
                  );
                },
              );
            }),
          ],

          const SizedBox(height: 6),

          // --- PORTFOLIO SECTION ---
          _AnimatedHomeCategory(
            label: "PORTFOLIO",
            isSelected: currentNavSection == "PORTFOLIO",
            theme: theme,
            onTap: () => onSectionTap("PORTFOLIO"),
          ),

          const Spacer(),
          
          // --- INTERACTIVE BACKGROUND SWITCHER BUTTON ---
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: _ThemeToggleButton(projectData: projectData, theme: theme),
          ),
        ],
      ),
    );
  }

  void _showAddMenu(BuildContext context, TapDownDetails details) {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    showMenu(
      context: context,
      color: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      position: RelativeRect.fromRect(
        details.globalPosition & const Size(40, 40),
        Offset.zero & overlay.size,
      ),
      items: [
        PopupMenuItem(
          onTap: () {
            projectData.addNewProject("New Project");
            final newProject = projectData.projects.last;
            projectData.selectProject(projectData.projects.length - 1);
            if (!openTabIds.contains(newProject.id)) {
              onProjectTap(projectData.projects.length - 1);
            }
          },
          child: const Row(
            children: [
              Icon(Icons.add, color: Colors.white, size: 16),
              SizedBox(width: 10),
              Text("Create New Project", style: TextStyle(color: Colors.white, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }
}

// ==========================================FLUID ANIMATED USER HEADER WIDGET==========================================
class _AnimatedUserHeader extends StatefulWidget {
  final UserDataModel userData;
  final KaelTheme theme;
  const _AnimatedUserHeader({required this.userData, required this.theme});

  @override
  State<_AnimatedUserHeader> createState() => _AnimatedUserHeaderState();
}

class _AnimatedUserHeaderState extends State<_AnimatedUserHeader> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PfpCV())),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutBack,
          padding: EdgeInsets.symmetric(
            vertical: _isHovered ? 14 : 10,
            horizontal: _isHovered ? 12 : 6,
          ),
          decoration: BoxDecoration(
            color: _isHovered ? theme.hoverBackground : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovered ? theme.hoverBorder : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                width: _isHovered ? 45 : 42,
                height: _isHovered ? 45 : 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle, 
                  border: Border.all(
                    color: _isHovered
                        ? theme.textPrimary
                        : const Color.fromARGB(81, 130, 129, 127),
                    width: 1,
                  ),
                ),
                child: ClipOval(
                  child: widget.userData.finalPfpPath != null && widget.userData.finalPfpPath!.isNotEmpty
                      ? Image.file(File(widget.userData.finalPfpPath!), fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar())
                      : _buildDefaultAvatar(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 180),
                      style: TextStyle(
                        color: theme.textPrimary,
                        fontSize: _isHovered ? 13.5 : 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        fontFamily: 'Inter',
                      ),
                      overflow: TextOverflow.ellipsis,
                      child: Text(widget.userData.name.isEmpty ? "Username" : widget.userData.name.toUpperCase()),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.userData.title.isEmpty ? "Full Name" : widget.userData.title, 
                      style: TextStyle(
                        color: theme.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                      ), 
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar() => Container(color: Colors.black, child: const Icon(Icons.person, color: Color.fromARGB(255, 97, 97, 97), size: 20));
}

// ==========================================
// INTERACTIVE SIDEBAR THEME SWITCHER
// ==========================================
class _ThemeToggleButton extends StatefulWidget {
  final ProjectProvider projectData;
  final KaelTheme theme;
  const _ThemeToggleButton({required this.projectData, required this.theme});

  @override
  State<_ThemeToggleButton> createState() => _ThemeToggleButtonState();
}

class _ThemeToggleButtonState extends State<_ThemeToggleButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final isLight = widget.projectData.isLightMode;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => widget.projectData.toggleLightMode(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          width: _isHovered ? 26 : 24,
          height: _isHovered ? 26 : 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.themeToggleFill,
            border: Border.all(
              color: _isHovered ? theme.hoverBorder : Colors.transparent,
              width: 1,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: theme.themeToggleHoverGlow,
                      blurRadius: 6,
                    )
                  ]
                : [],
          ),
          child: isLight
              ? null
              : Center(
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF121212)),
                  ),
                ),
        ),
      ),
    );
  }
}

// ==========================================
// FLUID ANIMATED CATEGORY ITEM WIDGET
// ==========================================
class _AnimatedHomeCategory extends StatefulWidget {
  final String label;
  final bool isSelected;
  final KaelTheme theme;
  final VoidCallback onTap;
  final Function(TapDownDetails)? onDoubleTapDetails;
  final Widget? trailing;

  const _AnimatedHomeCategory({
    required this.label,
    required this.isSelected,
    required this.theme,
    required this.onTap,
    this.onDoubleTapDetails,
    this.trailing,
  });

  @override
  State<_AnimatedHomeCategory> createState() => _AnimatedHomeCategoryState();
}

class _AnimatedHomeCategoryState extends State<_AnimatedHomeCategory> {
  bool _isHovered = false;
  TapDownDetails? _lastTapDownDetails; 

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    bool isActive = widget.isSelected || _isHovered;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (details) => _lastTapDownDetails = details,
        onDoubleTap: () {
          if (widget.onDoubleTapDetails != null && _lastTapDownDetails != null) {
            widget.onDoubleTapDetails!(_lastTapDownDetails!);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutBack,
          margin: const EdgeInsets.only(bottom: 4),
          padding: EdgeInsets.symmetric(
            vertical: _isHovered ? 12 : 10, 
            horizontal: _isHovered ? 16 : 12,
          ),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? theme.selectedBackground
                : (_isHovered ? theme.hoverBackground : Colors.transparent),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: (_isHovered && !widget.isSelected) ? theme.hoverBorder : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                style: TextStyle(
                  color: theme.textPrimary,
                  fontSize: _isHovered ? 11.5 : 11, 
                  letterSpacing: 1.5,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
                child: Text(widget.label),
              ),
              if (widget.trailing != null) widget.trailing!,
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// FLUID ANIMATED NESTED PROJECT SUB-ITEM
// ==========================================
class _AnimatedProjectItem extends StatefulWidget {
  final String title;
  final bool isSelected;
  final KaelTheme theme;
  final VoidCallback onTap;
  final Function(TapDownDetails) onSecondaryTapDown;

  const _AnimatedProjectItem({
    required this.title,
    required this.isSelected,
    required this.theme,
    required this.onTap,
    required this.onSecondaryTapDown,
  });

  @override
  State<_AnimatedProjectItem> createState() => _AnimatedProjectItemState();
}

class _AnimatedProjectItemState extends State<_AnimatedProjectItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        onSecondaryTapDown: widget.onSecondaryTapDown,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutBack,
          width: double.infinity,
          margin: const EdgeInsets.only(left: 12, bottom: 4),
          padding: EdgeInsets.symmetric(
            vertical: 6, 
            horizontal: _isHovered ? 14 : 10,
          ),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? theme.selectedBackground
                : (_isHovered ? theme.hoverBackground : Colors.transparent),
            borderRadius: BorderRadius.circular(8),
          ),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOutCubic,
            style: TextStyle(
              color: theme.textPrimary,
              fontSize: _isHovered ? 11.5 : 11,
              fontWeight: widget.isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            child: Text(widget.title),
          ),
        ),
      ),
    );
  }
}