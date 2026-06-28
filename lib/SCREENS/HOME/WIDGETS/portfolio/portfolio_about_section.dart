import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:kael/SCREENS/FORMS/DATA%20MODEL/user_data_model.dart';
import 'package:kael/SCREENS/GLOBAL%20WIDGETS/kael_theme.dart';

class PortfolioAboutSection extends StatefulWidget {
  final UserDataModel userData;
  final KaelTheme theme;

  const PortfolioAboutSection({super.key, required this.userData, required this.theme});

  @override
  State<PortfolioAboutSection> createState() => _PortfolioAboutSectionState();
}

class _PortfolioAboutSectionState extends State<PortfolioAboutSection> {
  bool _isHovered = false;
  late TextEditingController _bioController;

  @override
  void initState() {
    super.initState();
    _bioController = TextEditingController(text: widget.userData.bio);
    widget.userData.addListener(_syncFromModel);
  }

  @override
  void dispose() {
    widget.userData.removeListener(_syncFromModel);
    _bioController.dispose();
    super.dispose();
  }

  void _syncFromModel() {
    if (_bioController.text != widget.userData.bio) {
      _bioController.text = widget.userData.bio;
    }
    if (mounted) setState(() {});
  }

  Future<void> _pickAboutImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      widget.userData.updateAboutImage(result.files.single.path);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
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
                Text(
                  "ABOUT ME",
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _bioController,
                  maxLines: null,
                  style: TextStyle(
                    color: theme.textSecondary,
                    fontSize: 13,
                    height: 1.6,
                    fontWeight: FontWeight.w300,
                    fontFamily: widget.userData.fontFamily,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: 'Write your bio...',
                    hintStyle: TextStyle(color: theme.textMuted, fontSize: 13),
                  ),
                  onChanged: (v) => widget.userData.updatePortfolioIdentity(bio: v),
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
                color: theme.portfolioSurface,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: theme.portfolioSurfaceBorder, width: 1),
                image: aboutImagePath != null
                    ? DecorationImage(image: FileImage(File(aboutImagePath)), fit: BoxFit.cover)
                    : null,
              ),
              child: Stack(
                children: [
                  Positioned(
                    bottom: 15,
                    right: 15,
                    child: aboutImagePath == null ? _buildAddButton(theme) : _buildEditButton(),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(KaelTheme theme) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: _pickAboutImage,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: theme.bouncyButtonFill(_isHovered),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _isHovered ? theme.hoverBorder : theme.portfolioSurfaceBorder),
          ),
          child: Text(
            "ADD AN IMAGE",
            style: TextStyle(
              color: theme.bouncyButtonText(_isHovered),
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
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
