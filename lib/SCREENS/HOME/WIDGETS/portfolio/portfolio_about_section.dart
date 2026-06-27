import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:kael/SCREENS/FORMS/DATA%20MODEL/user_data_model.dart';

class PortfolioAboutSection extends StatefulWidget {
  final UserDataModel userData;

  const PortfolioAboutSection({super.key, required this.userData});

  @override
  State<PortfolioAboutSection> createState() => _PortfolioAboutSectionState();
}

class _PortfolioAboutSectionState extends State<PortfolioAboutSection> {
  bool _isHovered = false;

  Future<void> _pickAboutImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      // Assuming your model has this method; update if named differently
      widget.userData.updateAboutImage(result.files.single.path);
      setState(() {}); 
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? aboutImagePath = widget.userData.aboutImagePath;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                const Text(
                  "ABOUT ME",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  widget.userData.bio,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 146, 146, 146),
                    fontSize: 13,
                    height: 1.6,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 40),
          Expanded(
            flex: 2,
            child: Container(
              height: 180,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: const Color.fromARGB(60, 150, 143, 132), width: 1),
                image: aboutImagePath != null
                    ? DecorationImage(image: FileImage(File(aboutImagePath)), fit: BoxFit.cover)
                    : null,
              ),
              child: Stack(
                children: [
                  Positioned(
                    bottom: 15,
                    right: 15,
                    child: aboutImagePath == null ? _buildAddButton() : _buildEditButton(),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: _pickAboutImage,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: _isHovered ? const Color(0xFFD4C3A3) : const Color.fromARGB(35, 212, 195, 163),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color.fromARGB(60, 212, 195, 163)),
          ),
          child: Text("ADD AN IMAGE", style: TextStyle(color: _isHovered ? Colors.black : const Color(0xFFD4C3A3), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
        ),
      ),
    );
  }

  Widget _buildEditButton() {
    return PopupMenuButton<String>(
      color: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      onSelected: (value) {
        if (value == 'replace') _pickAboutImage();
        if (value == 'delete') {
          widget.userData.updateAboutImage(null);
          setState(() {});
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'replace', child: Text("Replace", style: TextStyle(color: Colors.white70, fontSize: 11))),
        const PopupMenuItem(value: 'delete', child: Text("Delete", style: TextStyle(color: Colors.redAccent, fontSize: 11))),
      ],
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: _isHovered ? Colors.white : Colors.black54, shape: BoxShape.circle),
          child: Icon(Icons.edit, size: 16, color: _isHovered ? Colors.black : Colors.white),
        ),
      ),
    );
  }
}