import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:kael/SCREENS/FORMS/DATA%20MODEL/user_data_model.dart';
import 'package:kael/SCREENS/GLOBAL%20WIDGETS/kael_theme.dart';

class PortfolioHeroBanner extends StatefulWidget {
  final UserDataModel userData;
  final KaelTheme theme;

  const PortfolioHeroBanner({super.key, required this.userData, required this.theme});

  @override
  State<PortfolioHeroBanner> createState() => _PortfolioHeroBannerState();
}

class _PortfolioHeroBannerState extends State<PortfolioHeroBanner> {
  bool _isHovered = false;
  bool _isPfpHovered = false;
  late TextEditingController _nameController;
  late TextEditingController _taglineController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userData.name);
    _taglineController = TextEditingController(text: widget.userData.title);
    widget.userData.addListener(_syncFromModel);
  }

  @override
  void dispose() {
    widget.userData.removeListener(_syncFromModel);
    _nameController.dispose();
    _taglineController.dispose();
    super.dispose();
  }

  void _syncFromModel() {
    if (_nameController.text != widget.userData.name) {
      _nameController.text = widget.userData.name;
    }
    if (_taglineController.text != widget.userData.title) {
      _taglineController.text = widget.userData.title;
    }
    if (mounted) setState(() {});
  }

  Future<void> _pickBanner() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      widget.userData.updateBanner(result.files.single.path);
    }
  }

  Future<void> _pickPfp() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      widget.userData.setFinalPfp(result.files.single.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final String? bannerPath = widget.userData.bannerPath;
    final fieldStyle = TextStyle(
      color: theme.textPrimary,
      fontFamily: widget.userData.fontFamily,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                color: theme.portfolioSurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: theme.portfolioSurfaceBorder, width: 1),
                image: bannerPath != null
                    ? DecorationImage(image: FileImage(File(bannerPath)), fit: BoxFit.cover)
                    : null,
              ),
              child: Stack(
                children: [
                  Positioned(
                    bottom: 20,
                    right: 20,
                    child: bannerPath == null ? _buildAddButton(theme) : _buildEditButton(),
                  )
                ],
              ),
            ),
            Positioned(
              bottom: -50,
              left: 30,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  MouseRegion(
                    onEnter: (_) => setState(() => _isPfpHovered = true),
                    onExit: (_) => setState(() => _isPfpHovered = false),
                    child: GestureDetector(
                      onTap: _pickPfp,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color.fromARGB(255, 60, 56, 50),
                          border: Border.all(
                            color: _isPfpHovered ? theme.hoverBorder : Colors.black,
                            width: 3,
                          ),
                          image: widget.userData.finalPfpPath != null
                              ? DecorationImage(
                                  image: FileImage(File(widget.userData.finalPfpPath!)),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: widget.userData.finalPfpPath == null
                            ? const Icon(Icons.person, color: Colors.white54, size: 40)
                            : _isPfpHovered
                                ? Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.black.withValues(alpha: 0.45),
                                    ),
                                    child: const Icon(Icons.edit, color: Colors.white70, size: 22),
                                  )
                                : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: SizedBox(
                      width: 220,
                      child: TextField(
                        controller: _nameController,
                        style: fieldStyle.copyWith(fontSize: 16, fontWeight: FontWeight.w500),
                        decoration: InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          hintText: 'username',
                          hintStyle: fieldStyle.copyWith(color: theme.textMuted, fontSize: 16),
                        ),
                        onChanged: (v) => widget.userData.updatePortfolioIdentity(name: v),
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
          child: SizedBox(
            width: 400,
            child: TextField(
              controller: _taglineController,
              style: fieldStyle.copyWith(fontSize: 30, letterSpacing: 1.5),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'TAG LINE | DESIGNER',
                hintStyle: fieldStyle.copyWith(color: theme.textMuted, fontSize: 24),
              ),
              onChanged: (v) => widget.userData.updatePortfolioIdentity(title: v),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddButton(KaelTheme theme) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: _pickBanner,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: theme.bouncyButtonFill(_isHovered),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _isHovered ? theme.hoverBorder : theme.sidebarBorder.withValues(alpha: 0.4)),
          ),
          child: Text(
            "ADD BANNER",
            style: TextStyle(
              color: theme.bouncyButtonText(_isHovered),
              fontSize: 9,
              fontWeight: FontWeight.bold,
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
