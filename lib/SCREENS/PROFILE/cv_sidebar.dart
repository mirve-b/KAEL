import 'dart:io';
import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:kael/SCREENS/FORMS/DATA%20MODEL/user_data_model.dart';
import 'package:kael/SCREENS/GLOBAL%20WIDGETS/kael_theme.dart';
import 'package:kael/SCREENS/HOME/PROVIDER/project_provider.dart';
import 'package:provider/provider.dart';

class CVSidebar extends StatelessWidget {
  final UserDataModel user;
  final String activeSection;
  final List<String> sections;
  final Function(String) onSectionClick;
  final VoidCallback onPreview;
  final VoidCallback onExport;
  final bool isExporting;

  const CVSidebar({
    super.key,
    required this.user,
    required this.activeSection,
    required this.sections,
    required this.onSectionClick,
    required this.onPreview,
    required this.onExport,
    this.isExporting = false,
  });

  // --- LOGIC: PICK IMAGE ---
  Future<void> _pickImage(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      user.setFinalPfp(result.files.single.path);
    }
  }

  // --- UI: THE EDIT POPUP ---
  void _showEditMenu(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF121212),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("EDIT PROFILE PICTURE", style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 1.2)),
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.black,
                backgroundImage: user.finalPfpPath != null ? FileImage(File(user.finalPfpPath!)) : null,
                child: user.finalPfpPath == null ? const Icon(Icons.person, size: 40, color: Colors.white10) : null,
              ),
              const SizedBox(height: 30),
              _menuButton("REPLACE IMAGE", Icons.upload_file, () {
                Navigator.pop(context);
                _pickImage(context);
              }),
              if (user.finalPfpPath != null)
                _menuButton("DELETE IMAGE", Icons.delete_outline, () {
                  _confirmDelete(context);
                }, isDelete: true),
              const SizedBox(height: 10),
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("CLOSE", style: TextStyle(color: Colors.white24, fontSize: 10))),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (innerContext) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text("Delete Photo?", style: TextStyle(color: Colors.white, fontSize: 16)),
        content: const Text("Are you sure you want to remove your profile picture?", style: TextStyle(color: Colors.white38, fontSize: 13)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(innerContext), child: const Text("CANCEL", style: TextStyle(color: Colors.white24))),
          TextButton(
            onPressed: () {
              user.deletePfp();
              Navigator.pop(innerContext); // Close Alert
              Navigator.pop(context);      // Close Edit Menu
            },
            child: const Text("DELETE", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  Widget _menuButton(String label, IconData icon, VoidCallback onTap, {bool isDelete = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
        decoration: BoxDecoration(
          color: isDelete ? const Color.fromARGB(48, 255, 82, 82) : const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: isDelete ? Colors.redAccent : const Color(0xFF9A9A9A)),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(color: isDelete ? Colors.redAccent : Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = KaelTheme.of(context.watch<ProjectProvider>().isLightMode);

    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: theme.sidebarBackground,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: theme.sidebarBorder, width: 1.5),
      ),
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
      child: Column(
        children: [
          // --- STAR BURST BACK LAYER HEAD ---
          _AnimatedAvatarHeader(
            user: user,
            theme: theme,
            onTap: () => _showEditMenu(context),
          ),
          
          const SizedBox(height: 15),
          Text(
            user.name.isEmpty ? "User Name" : user.name.toUpperCase(),
            style: TextStyle(
              color: theme.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 40),
          Expanded(
            child: ListView(
              physics: const NeverScrollableScrollPhysics(), 
              children: sections.map((s) => _AnimatedSidebarItem(
                label: s,
                isSelected: activeSection == s,
                theme: theme,
                onTap: () => onSectionClick(s),
              )).toList(),
            ),
          ),
          Divider(color: theme.sidebarBorder.withValues(alpha: 0.4), height: 30),
          _AnimatedSidebarItem(
            label: "PREVIEW ATS CV",
            isSelected: false,
            isAction: true,
            theme: theme,
            onTap: onPreview,
          ),
          _AnimatedSidebarItem(
            label: isExporting ? "EXPORTING..." : "EXPORT CV",
            isSelected: false,
            isAction: true,
            theme: theme,
            onTap: isExporting ? () {} : onExport,
          ),
        ],
      ),
    );
  }
}

class _AnimatedAvatarHeader extends StatefulWidget {
  final UserDataModel user;
  final KaelTheme theme;
  final VoidCallback onTap;

  const _AnimatedAvatarHeader({required this.user, required this.theme, required this.onTap});

  @override
  State<_AnimatedAvatarHeader> createState() => _AnimatedAvatarHeaderState();
}

class _AnimatedAvatarHeaderState extends State<_AnimatedAvatarHeader> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _starController;

  @override
  void initState() {
    super.initState();
    _starController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    _starController.dispose();
    super.dispose();
  }

  void _triggerBurst() {
    _starController.reset();
    _starController.forward();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: _triggerBurst,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none, 
          children: [
            
            // LAYER 1: The Particle System Engine
            ...List.generate(5, (index) {
              return AnimatedBuilder(
                animation: _starController,
                builder: (context, child) {
                  if (!_starController.isAnimating && _starController.isDismissed) {
                    return const SizedBox.shrink();
                  }
                  double angle = (index * (2 * math.pi / 5)) - (math.pi / 2);

                  double radiusDistance = 75.0 * _starController.value; 

                  double xOffset = math.cos(angle) * radiusDistance;
                  double yOffset = math.sin(angle) * radiusDistance;
                  
                  double scale = (1.0 - _starController.value);

                  bool isOutline = index == 1 || index == 3;

                  return Positioned(
                    left: 47 + xOffset - 12, 
                    top: 47 + yOffset - 12,
                    child: Transform.scale(
                      scale: scale,
                      child: Transform.rotate(
                        angle: _starController.value * (1.5 * math.pi), 
                        child: Icon(
                          isOutline ? Icons.star_border_rounded : Icons.star_rounded, 
                          color: const Color.fromARGB(255, 241, 119, 157), 
                          size: 50,
                        ),
                      ),
                    ),
                  );
                },
              );
            }),

            // LAYER 2: The Main Avatar Image
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutBack,
              width: _isHovered ? 102 : 94,
              height: _isHovered ? 102 : 94,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _isHovered ? widget.theme.hoverBorder : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Center(
                child: ClipOval(
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(
                      sigmaX: _isHovered ? 3.0 : 0.0,
                      sigmaY: _isHovered ? 3.0 : 0.0,
                    ),
                    child: CircleAvatar(
                      radius: 44,
                      backgroundColor: Colors.black,
                      backgroundImage: widget.user.finalPfpPath != null
                          ? FileImage(File(widget.user.finalPfpPath!))
                          : null,
                      child: widget.user.finalPfpPath == null
                          ? const Icon(Icons.person, size: 40, color: Colors.white10)
                          : null,
                    ),
                  ),
                ),
              ),
            ),
            
            // LAYER 3: Hover Edit Icon Label
            if (_isHovered)
              IgnorePointer(
                child: Icon(Icons.edit_rounded, color: widget.theme.textMuted, size: 22),
              ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedSidebarItem extends StatefulWidget {
  final String label;
  final bool isSelected;
  final bool isAction;
  final KaelTheme theme;
  final VoidCallback onTap;

  const _AnimatedSidebarItem({
    required this.label,
    required this.isSelected,
    required this.theme,
    this.isAction = false,
    required this.onTap,
  });

  @override
  State<_AnimatedSidebarItem> createState() => _AnimatedSidebarItemState();
}

class _AnimatedSidebarItemState extends State<_AnimatedSidebarItem> {
  bool _isHovered = false;

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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutBack, 
          margin: const EdgeInsets.only(bottom: 8),
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
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            style: TextStyle(
              color: widget.isSelected || _isHovered
                  ? theme.textPrimary
                  : (widget.isAction ? theme.textSecondary : theme.textDim), 
              fontSize: _isHovered ? 11.5 : 11, 
              letterSpacing: 1.5,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
            child: Text(widget.label),
          ),
        ),
      ),
    );
  }
}