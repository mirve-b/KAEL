import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:kael/SCREENS/FORMS/DATA%20MODEL/user_data_model.dart';

class CVSidebar extends StatelessWidget {
  final UserDataModel user;
  final String activeSection;
  final List<String> sections;
  final Function(String) onSectionClick;

  const CVSidebar({
    super.key,
    required this.user,
    required this.activeSection,
    required this.sections,
    required this.onSectionClick,
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
            Icon(icon, size: 16, color: isDelete ? Colors.redAccent : const Color(0xFFD4C3A3)),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(color: isDelete ? Colors.redAccent : Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isHovered = false; 

    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: const Color.fromARGB(255, 79, 78, 78), width: 1.5),
      ),
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Column(
        children: [
          StatefulBuilder(
  builder: (context, setInternalState) {
    return MouseRegion(
      onEnter: (_) => setInternalState(() => isHovered = true),
      onExit: (_) => setInternalState(() => isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _showEditMenu(context),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 1. The Image Container with Clipping
            ClipOval( // This stops the blur from spreading outside
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(
                  sigmaX: isHovered ? 4.0 : 0.0, 
                  sigmaY: isHovered ? 4.0 : 0.0
                ),
                child: CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.black,
                  backgroundImage: user.finalPfpPath != null 
                      ? FileImage(File(user.finalPfpPath!)) 
                      : null,
                  child: user.finalPfpPath == null 
                      ? const Icon(Icons.person, size: 40, color: Colors.white10) 
                      : null,
                ),
              ),
            ),
            Container(
              width: 90, 
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isHovered ? const Color.fromARGB(255, 145, 135, 117) : const Color.fromARGB(0, 255, 255, 255), 
                  width: 1,
                ),
              ),
            ),
            if (isHovered)
              const Icon(Icons.edit_rounded, color: Color.fromARGB(255, 221, 208, 190), size: 22),
          ],
        ),
      ),
    );
  },
),
          const SizedBox(height: 15),
          Text(
            user.name.isEmpty ? "User Name" : user.name,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 40),
          Expanded(
            child: ListView(
              children: sections.map((s) => _sidebarItem(s)).toList(),
            ),
          ),
          const Divider(color: Colors.white10),
          _sidebarItem("PREVIEW ATS CV", isAction: true),
          _sidebarItem("EXPORT", isAction: true),
        ],
      ),
    );
  }

  Widget _sidebarItem(String label, {bool isAction = false}) {
    bool isSelected = activeSection == label;
    return GestureDetector(
      onTap: () => isAction ? null : onSectionClick(label),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        margin: const EdgeInsets.only(bottom: 5),
        decoration: BoxDecoration(
          color: isSelected ? const Color.fromARGB(35, 212, 195, 163) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFFD4C3A3) : (isAction ? Colors.white54 : Colors.white24),
            fontSize: 11,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}