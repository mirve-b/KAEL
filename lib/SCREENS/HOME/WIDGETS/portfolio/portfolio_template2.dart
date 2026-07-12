import 'dart:io';
import 'dart:math' as math;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:kael/SCREENS/FORMS/DATA%20MODEL/user_data_model.dart';
import 'package:kael/SCREENS/GLOBAL%20WIDGETS/kael_theme.dart';
import 'package:kael/SCREENS/HOME/PROVIDER/project_provider.dart';
import 'package:kael/SCREENS/HOME/WIDGETS/portfolio/portfolio_project_grid.dart';
import 'package:kael/SCREENS/HOME/WIDGETS/portfolio/portfolio_work_gallery.dart';

class PortfolioTemplate2 extends StatefulWidget {
  final UserDataModel userData;
  final ProjectProvider projectsProvider;
  final KaelTheme theme;
  final Function(String?) onProjectSelect;

  const PortfolioTemplate2({
    super.key,
    required this.userData,
    required this.projectsProvider,
    required this.theme,
    required this.onProjectSelect,
  });

  @override
  State<PortfolioTemplate2> createState() => _PortfolioTemplate2State();
}

class _PortfolioTemplate2State extends State<PortfolioTemplate2> {
  static const _scriptFont = 'CoveredByYourGrace';

  bool _bannerHovered = false;
  bool _aboutImageHovered = false;
  late TextEditingController _bioController;
  late TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    _bioController = TextEditingController(text: widget.userData.bio);
    _titleController = TextEditingController(text: widget.userData.title);
    widget.userData.addListener(_syncFromModel);
  }

  @override
  void dispose() {
    widget.userData.removeListener(_syncFromModel);
    _bioController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _syncFromModel() {
    if (_bioController.text != widget.userData.bio) {
      _bioController.text = widget.userData.bio;
    }
    if (_titleController.text != widget.userData.title) {
      _titleController.text = widget.userData.title;
    }
    if (mounted) setState(() {});
  }

  Future<void> _pickBanner() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      widget.userData.updateBanner(result.files.single.path);
    }
  }

  Future<void> _pickAboutImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      widget.userData.updateAboutImage(result.files.single.path);
    }
  }

  TextStyle _scriptStyle({
    required double size,
    required Color color,
    double letterSpacing = 3.0,
  }) {
    return TextStyle(
      fontFamily: _scriptFont,
      fontSize: size,
      color: color,
      fontWeight: FontWeight.w400,
      letterSpacing: letterSpacing,
      height: 1.05,
    );
  }

  Widget _scriptLines({
    required List<String> lines,
    required Color color,
    required double baseSize,
    List<double>? lineLetterSpacing,
    double rotation = -0.07,
  }) {
    return Transform.rotate(
      angle: rotation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(lines.length, (i) {
          return Text(
            lines[i],
            style: _scriptStyle(
              size: baseSize,
              color: color,
              letterSpacing: lineLetterSpacing != null && i < lineLetterSpacing.length
                  ? lineLetterSpacing[i]
                  : 3.0,
            ),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeText = widget.theme.textPrimary;
    final themeMuted = widget.theme.textSecondary;
    final headingColor = widget.userData.resolveHeadingColor(widget.theme);
    final surface = widget.theme.portfolioSurface;
    final opaqueSurface = widget.theme.portfolioOpaqueSurface;
    final bannerPath = widget.userData.bannerPath;
    final aboutImagePath = widget.userData.aboutImagePath;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: DefaultTextStyle(
        style: TextStyle(
          fontFamily: widget.userData.fontFamily,
          color: themeText,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: widget.theme.portfolioSurfaceBorder),
                ),
                child: Text(
                  'PORTFOLIO',
                  style: TextStyle(
                    color: themeMuted,
                    fontSize: 9,
                    letterSpacing: 2.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildHeroBanner(bannerPath, surface),
            const SizedBox(height: 20),
            _buildTitleField(themeText),
            const SizedBox(height: 48),
            _buildAboutSection(aboutImagePath, opaqueSurface, themeText, themeMuted, headingColor),
            const SizedBox(height: 48),
            PortfolioWorkGallery(userData: widget.userData, theme: widget.theme),
            const SizedBox(height: 48),
            PortfolioProjectGrid(
              projectsProvider: widget.projectsProvider,
              theme: widget.theme,
              userData: widget.userData,
              onProjectSelect: widget.onProjectSelect,
              sectionTitle: 'Case Studies',
              sectionSubtitle: 'DRAG HANDLE TO REORDER · RIGHT-CLICK THUMBNAIL TO CHANGE',
              titlePadding: EdgeInsets.zero,
              flatTitleBox: true,
              useOpaqueSurface: true,
            ),
            const SizedBox(height: 48),
            _buildConnectSection(themeText, themeMuted, headingColor),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroBanner(String? bannerPath, Color surface) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxWidth > 900
            ? 480.0
            : constraints.maxWidth > 600
                ? 380.0
                : 280.0;

        return SizedBox(
          width: double.infinity,
          height: height,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: double.infinity,
                height: height,
                decoration: BoxDecoration(
                  color: surface,
                  image: bannerPath != null
                      ? DecorationImage(image: FileImage(File(bannerPath)), fit: BoxFit.cover)
                      : null,
                ),
              ),
              Positioned(
                bottom: 16,
                right: 16,
                child: bannerPath == null ? _brandingButton() : _bannerEditButton(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTitleField(Color themeText) {
    return TextField(
      controller: _titleController,
      style: TextStyle(
        color: themeText,
        fontSize: 28,
        letterSpacing: 1.5,
        fontFamily: widget.userData.fontFamily,
      ),
      decoration: InputDecoration(
        isDense: true,
        border: InputBorder.none,
        hintText: 'TAG LINE | DESIGNER',
        hintStyle: TextStyle(
          color: widget.theme.textMuted,
          fontSize: 24,
          fontFamily: widget.userData.fontFamily,
        ),
      ),
      onChanged: (v) => widget.userData.updatePortfolioIdentity(title: v),
    );
  }

  Widget _bannerEditButton() {
    return PopupMenuButton<String>(
      color: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      onSelected: (value) {
        if (value == 'replace') _pickBanner();
        if (value == 'delete') widget.userData.updateBanner(null);
      },
      itemBuilder: (context) => const [
        PopupMenuItem(value: 'replace', child: Text('Replace', style: TextStyle(color: Colors.white70, fontSize: 11))),
        PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.redAccent, fontSize: 11))),
      ],
      child: MouseRegion(
        onEnter: (_) => setState(() => _bannerHovered = true),
        onExit: (_) => setState(() => _bannerHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _bannerHovered ? Colors.white : Colors.black54,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.edit, size: 16, color: _bannerHovered ? Colors.black : Colors.white),
        ),
      ),
    );
  }

  Widget _brandingButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _pickBanner(),
        onHover: (hovered) => setState(() => _bannerHovered = hovered),
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: widget.theme.bouncyButtonFill(_bannerHovered),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _bannerHovered ? widget.theme.hoverBorder : widget.theme.portfolioSurfaceBorder,
            ),
          ),
          child: Text(
            'ADD BRANDING',
            style: TextStyle(
              color: widget.theme.bouncyButtonText(_bannerHovered),
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAboutSection(
    String? aboutImagePath,
    Color surface,
    Color themeText,
    Color themeMuted,
    Color scriptColor,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final isSideBySide = w > 940;

        if (isSideBySide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 6,
                child: _aboutTextColumn(surface, themeText, themeMuted),
              ),
              const SizedBox(width: 20),
              Expanded(
                flex: 4,
                child: Align(
                  alignment: Alignment.topRight,
                  child: LayoutBuilder(
                    builder: (context, collageConstraints) {
                      final collageWidth = _collageWidthFor(collageConstraints.maxWidth, w);
                      return _buildAboutCollage(
                        collageWidth: collageWidth,
                        aboutImagePath: aboutImagePath,
                        surface: surface,
                        scriptColor: scriptColor,
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _aboutTextColumn(surface, themeText, themeMuted),
            const SizedBox(height: 28),
            Align(
              alignment: Alignment.centerRight,
              child: _buildAboutCollage(
                collageWidth: _collageWidthFor(w, w),
                aboutImagePath: aboutImagePath,
                surface: surface,
                scriptColor: scriptColor,
              ),
            ),
          ],
        );
      },
    );
  }

  double _collageWidthFor(double available, double sectionWidth) {
    if (sectionWidth <= 940) {
      return math.min(available * 0.92, math.max(150, sectionWidth * 0.72));
    }

    final widthRatio = sectionWidth > 1200
        ? 0.88
        : sectionWidth > 1050
            ? 0.82
            : 0.76;
    var width = available * widthRatio;

    if (sectionWidth > 1200) {
      width = math.min(width, 440);
    } else if (sectionWidth > 1050) {
      width = math.min(width, 340);
    } else {
      width = math.min(width, 280);
    }

    return math.max(150, width);
  }

  Widget _buildAboutCollage({
    required double collageWidth,
    required String? aboutImagePath,
    required Color surface,
    required Color scriptColor,
  }) {
    final starSize = collageWidth * 0.88;
    final imageWidth = collageWidth * 0.58;
    final stackHeight = collageWidth * 0.78;
    final scriptSize = (collageWidth * 0.26).clamp(52.0, 118.0);
    final imageLeft = collageWidth - imageWidth;
    final starLeft = imageLeft - (starSize * 0.42);
    final scriptLeft = imageLeft - (starSize * 0.28) - 10;

    return SizedBox(
      height: stackHeight,
      width: collageWidth,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: starLeft.clamp(-starSize * 0.12, collageWidth - starSize),
            top: stackHeight * 0.14,
            child: Image.asset(
              'assets/IMAGES/star.png',
              width: starSize,
              height: starSize,
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: SizedBox(
              width: imageWidth,
              height: stackHeight - 8,
              child: _aboutImageBox(aboutImagePath, surface),
            ),
          ),
          Positioned(
            left: scriptLeft.clamp(0.0, collageWidth - imageWidth),
            top: stackHeight * 0.1,
            child: IgnorePointer(
              child: _scriptLines(
                lines: const ['about', 'myself'],
                color: scriptColor,
                baseSize: scriptSize,
                lineLetterSpacing: const [4.0, 7.0],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _aboutTextColumn(Color surface, Color themeText, Color themeMuted) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          color: surface,
          child: Text(
            'Hello!',
            style: TextStyle(
              color: widget.userData.resolveHeadingColor(widget.theme),
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _bioController,
          maxLines: null,
          style: TextStyle(
            color: themeMuted,
            fontSize: 13,
            height: 1.7,
            fontWeight: FontWeight.w300,
            fontFamily: widget.userData.fontFamily,
          ),
          decoration: InputDecoration(
            isDense: true,
            border: InputBorder.none,
            hintText: 'Write your bio...',
            hintStyle: TextStyle(color: themeMuted.withValues(alpha: 0.45), fontSize: 13),
          ),
          onChanged: (v) => widget.userData.updatePortfolioIdentity(bio: v),
        ),
      ],
    );
  }

  Widget _aboutImageBox(String? aboutImagePath, Color surface) {
    return Container(
      decoration: BoxDecoration(
        color: surface,
        image: aboutImagePath != null
            ? DecorationImage(image: FileImage(File(aboutImagePath)), fit: BoxFit.cover)
            : null,
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: 12,
            right: 12,
            child: aboutImagePath == null ? _aboutAddButton() : _aboutImageMenu(),
          ),
        ],
      ),
    );
  }

  Widget _aboutAddButton() {
    return MouseRegion(
      onEnter: (_) => setState(() => _aboutImageHovered = true),
      onExit: (_) => setState(() => _aboutImageHovered = false),
      child: GestureDetector(
        onTap: _pickAboutImage,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: widget.theme.bouncyButtonFill(_aboutImageHovered),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: widget.theme.portfolioSurfaceBorder),
          ),
          child: Text(
            'ADD',
            style: TextStyle(
              color: widget.theme.bouncyButtonText(_aboutImageHovered),
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _aboutImageMenu() {
    return PopupMenuButton<String>(
      color: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      onSelected: (value) {
        if (value == 'replace') _pickAboutImage();
        if (value == 'delete') widget.userData.updateAboutImage(null);
      },
      itemBuilder: (context) => const [
        PopupMenuItem(value: 'replace', child: Text('Replace', style: TextStyle(color: Colors.white70, fontSize: 11))),
        PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.redAccent, fontSize: 11))),
      ],
      child: _aboutAddButton(),
    );
  }

  Widget _buildConnectSection(Color themeText, Color themeMuted, Color scriptColor) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 640;
        final scriptSize = isWide ? 72.0 : 54.0;
        final contacts = _contactRows(themeText, themeMuted);

        final connectTitle = _scriptLines(
          lines: const ["let's", 'connect'],
          color: scriptColor,
          baseSize: scriptSize,
          lineLetterSpacing: const [2.5, 6.0],
          rotation: 0,
        );

        final contactList = Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: contacts,
        );

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(child: connectTitle),
              const SizedBox(width: 24),
              Expanded(child: contactList),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            connectTitle,
            const SizedBox(height: 24),
            contactList,
          ],
        );
      },
    );
  }

  List<Widget> _contactRows(Color themeText, Color themeMuted) {
    final user = widget.userData;

    final items = <Map<String, String>>[
      if (user.linkedinUrl.isNotEmpty) {'label': 'Linkedin', 'value': user.linkedinUrl},
      if (user.phone.isNotEmpty) {'label': 'Phone', 'value': user.phone},
      if (user.email.isNotEmpty) {'label': 'Email', 'value': user.email},
      if (user.websiteUrl.isNotEmpty) {'label': 'Website', 'value': user.websiteUrl},
    ];

    if (items.isEmpty) {
      return [
        _contactRow('Linkedin', 'Add in profile', themeText, themeMuted),
        _contactRow('Phone', 'Add in profile', themeText, themeMuted),
        _contactRow('Email', 'Add in profile', themeText, themeMuted),
      ];
    }

    return items.map((e) => _contactRow(e['label']!, e['value']!, themeText, themeMuted)).toList();
  }

  Widget _contactRow(String label, String value, Color themeText, Color themeMuted) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            label,
            style: TextStyle(
              color: themeMuted,
              fontSize: 12,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 28),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: themeText,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
