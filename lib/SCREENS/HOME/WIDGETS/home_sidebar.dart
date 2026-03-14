import 'dart:io';
import 'package:flutter/material.dart';
import 'package:kael/SCREENS/FORMS/DATA%20MODEL/user_data_model.dart';
import 'package:kael/SCREENS/HOME/PROVIDER/project_provider.dart';
import 'package:kael/SCREENS/PROFILE/pfp_cv.dart';

class HomeSidebar extends StatelessWidget {
  final UserDataModel userData;
  final ProjectProvider projectData;
  final bool isCatalogExpanded;
  final List<String> openTabIds;
  final String currentNavSection; // NEW
  final VoidCallback onToggleCatalog;
  final Function(String) onSectionTap; // NEW
  final Function(int) onProjectTap;
  final Function(int, String) onRenameRequest;
  final Function(int, String) onDeleteRequest;

  const HomeSidebar({
    super.key,
    required this.userData,
    required this.projectData,
    required this.isCatalogExpanded,
    required this.openTabIds,
    required this.currentNavSection, // Initialize
    required this.onToggleCatalog,
    required this.onSectionTap, // Initialize
    required this.onProjectTap,
    required this.onRenameRequest,
    required this.onDeleteRequest,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 0, 0, 0),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: const Color.fromARGB(255, 79, 78, 78), width: 1.5),
      ),
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUserHeader(context, userData),
          const SizedBox(height: 40),
          
          // --- CANVAS SECTION ---
          _buildClickableLabel("CANVAS"), 
          
          const SizedBox(height: 10),

          // --- CATALOG SECTION ---
          GestureDetector(
            onLongPressStart: (details) => _showAddMenu(context, details),
            onTap: onToggleCatalog,
            behavior: HitTestBehavior.opaque,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _sidebarCategory(
                  "CATALOG", 
                  isGold: currentNavSection == "CATALOG"
                ),
                Icon(
                  isCatalogExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: currentNavSection == "CATALOG" 
                      ? const Color(0xFFD4C3A3) 
                      : const Color.fromARGB(255, 79, 78, 78),
                  size: 14,
                ),
              ],
            ),
          ),
          
          if (isCatalogExpanded) ...[
            const SizedBox(height: 5),
            ...projectData.projects.asMap().entries.map((entry) => 
                _buildSidebarProjectItem(context, entry.key, entry.value.title, projectData)),
          ],

          const SizedBox(height: 10),

          // --- PORTFOLIO SECTION ---
          _buildClickableLabel("PORTFOLIO"),

          const Spacer(),
          const CircleAvatar(radius: 12, backgroundColor: Color(0xFFD4C3A3)),
        ],
      ),
    );
  }

  // Helper for CANVAS and PORTFOLIO labels
  Widget _buildClickableLabel(String title) {
    bool isActive = currentNavSection == title;
    return GestureDetector(
      onTap: () => onSectionTap(title),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          title, 
          style: TextStyle(
            color: isActive ? const Color(0xFFD4C3A3) : const Color.fromARGB(255, 171, 163, 153), 
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            letterSpacing: 0.5
          )
        ),
      ),
    );
  }

  // Refactored the Add Menu for clarity
  void _showAddMenu(BuildContext context, LongPressStartDetails details) {
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
              Icon(Icons.add, color: Color(0xFFD4C3A3), size: 16),
              SizedBox(width: 10),
              Text("Create New Project", style: TextStyle(color: Colors.white, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSidebarProjectItem(BuildContext context, int idx, String title, ProjectProvider projects) {
    // Only highlight project if we are actually in the CATALOG section
    bool isSelected = projects.currentIndex == idx && currentNavSection == "CATALOG";
    return GestureDetector(
      onTap: () => onProjectTap(idx),
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
              onTap: () => Future.delayed(Duration.zero, () => onRenameRequest(idx, title)),
              child: const Text("Rename", style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
            PopupMenuItem(
              onTap: () => Future.delayed(Duration.zero, () => onDeleteRequest(idx, title)),
              child: const Text("Delete", style: TextStyle(color: Colors.redAccent, fontSize: 12)),
            ),
          ],
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.only(left: 10, top: 4, bottom: 4),
        color: Colors.transparent, 
        child: Text(
          title, 
          style: TextStyle(
            color: isSelected ? const Color(0xFFD4C3A3) : Colors.white30, 
            fontSize: 11
          )
        ),
      ),
    );
  }

  // --- USER HEADER & STYLES ---

  Widget _buildUserHeader(BuildContext context, UserDataModel user) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PfpCV())),
        behavior: HitTestBehavior.opaque,
        child: Row(
          children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color.fromARGB(81, 130, 129, 127), width: 1)),
              child: ClipOval(
                child: user.finalPfpPath != null && user.finalPfpPath!.isNotEmpty
                    ? Image.file(File(user.finalPfpPath!), fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar())
                    : _buildDefaultAvatar(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(user.name.isEmpty ? "Username" : user.name, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.5), overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(user.title.isEmpty ? "Full Name" : user.title, style: const TextStyle(color: Color.fromARGB(100, 255, 255, 255), fontSize: 10, fontWeight: FontWeight.w400), overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar() => Container(color: Colors.black, child: const Icon(Icons.person, color: Color.fromARGB(255, 97, 97, 97), size: 20));
  
  Widget _sidebarCategory(String t, {bool isGold = false}) => Text(
    t, 
    style: TextStyle(
      color: isGold ? const Color(0xFFD4C3A3) : Colors.white70, 
      fontSize: 11,
      fontWeight: isGold ? FontWeight.bold : FontWeight.normal
    )
  );
}