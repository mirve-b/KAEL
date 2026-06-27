import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:kael/SCREENS/FORMS/DATA%20MODEL/user_data_model.dart';

class PortfolioHeroBanner extends StatefulWidget {
  final UserDataModel userData;

  const PortfolioHeroBanner({super.key, required this.userData});

  @override
  State<PortfolioHeroBanner> createState() => _PortfolioHeroBannerState();
}

class _PortfolioHeroBannerState extends State<PortfolioHeroBanner> {
  bool _isHovered = false;

  Future<void> _pickBanner() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      widget.userData.updateBanner(result.files.single.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? bannerPath = widget.userData.bannerPath;
    final String displayName = widget.userData.name.isEmpty ? "USERNAME" : widget.userData.name.toUpperCase();
    final String displayTagline = widget.userData.title.isEmpty ? "TAG LINE | DESIGNER" : widget.userData.title.toUpperCase();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            // Banner
            Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color:const Color.fromARGB(60, 150, 143, 132), width: 1),
                image: bannerPath != null
                    ? DecorationImage(image: FileImage(File(bannerPath)), fit: BoxFit.cover)
                    : null,
              ),
              child: Stack(
                children: [
                  Positioned(
                    bottom: 20,
                    right: 20,
                    child: bannerPath == null ? _buildAddButton() : _buildEditButton(),
                  )
                ],
              ),
            ),
            // PFP and Username Row 
            Positioned(
              bottom: -50,
              left: 30,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color.fromARGB(255, 60, 56, 50),
                      border: Border.all(color: Colors.black, width: 3),
                      image: widget.userData.finalPfpPath != null
                          ? DecorationImage(
                              image: FileImage(File(widget.userData.finalPfpPath!)),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: widget.userData.finalPfpPath == null
                        ? const Icon(Icons.person, color: Colors.white54, size: 40)
                        : null,
                  ),
                  const SizedBox(width: 15),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Text(
                      displayName.toLowerCase(),
                      style: const TextStyle(

                        fontSize: 16,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 60), 

        Padding(
          padding: const EdgeInsets.only(left: 30),
          child: Text(
            displayTagline,
            style: const TextStyle(

              fontSize: 30,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddButton() {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: _pickBanner,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: _isHovered ? const Color(0xFFD4C3A3) : const Color.fromARGB(35, 212, 195, 163),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color.fromARGB(60, 212, 195, 163)),
          ),
          child: Text("ADD BANNER", style: TextStyle(color: _isHovered ? Colors.black : const Color(0xFFD4C3A3), fontSize: 9, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildEditButton() {
    return PopupMenuButton<String>(
      color: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      onSelected: (value) {
        if (value == 'replace') _pickBanner();
        if (value == 'delete') widget.userData.updateBanner(null);
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