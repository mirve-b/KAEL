import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:kael/SCREENS/GLOBAL%20WIDGETS/kael_theme.dart';
import 'package:kael/SCREENS/HOME/PROVIDER/project_provider.dart';
import 'package:provider/provider.dart';
import 'package:kael/SCREENS/FORMS/DATA%20MODEL/user_data_model.dart';
import 'package:kael/SCREENS/HOME/DATA%20MODEL/project_model.dart';
import 'package:kael/SCREENS/HOME/WIDGETS/casestudy/home_casestudy.dart';
import 'package:kael/SCREENS/HOME/WIDGETS/portfolio/home_portfolio.dart'; 

class HomeCanvas extends StatelessWidget {
  final ProjectProvider projects;
  final List<String> openTabIds;
  final int? editingCellIndex;
  final int? editingProjectIndex;
  final TextEditingController textController;
  final FocusNode textFocusNode;
  final VoidCallback onSaveEdit;
  final Function(int, int, String) onStartEdit;
  final Function() onAddText;
  final bool isPreviewMode;
  final Function(bool) onTogglePreview;
  final String selectedSection; 
  final UserDataModel userData; 
  final bool isPortfolioGenerated;
  final VoidCallback onGeneratePortfolio;
  
  final String? activePortfolioProjectId;
  final Function(String?) onPortfolioProjectSelected;

  const HomeCanvas({
    super.key,
    required this.projects,
    required this.openTabIds,
    required this.editingCellIndex,
    required this.editingProjectIndex,
    required this.textController,
    required this.textFocusNode,
    required this.onSaveEdit,
    required this.onStartEdit,
    required this.onAddText,
    required this.isPreviewMode,
    required this.onTogglePreview,
    required this.selectedSection,
    required this.userData, 
    required this.isPortfolioGenerated,
    required this.onGeneratePortfolio,
    required this.activePortfolioProjectId,
    required this.onPortfolioProjectSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = KaelTheme.of(context.watch<ProjectProvider>().isLightMode);

    if (selectedSection == "PORTFOLIO") {
      return HomePortfolio(
        userData: userData,
        projectsProvider: projects,
        isGenerated: isPortfolioGenerated,
        onGenerateTap: onGeneratePortfolio,
        activeProjectId: activePortfolioProjectId,
        onProjectSelect: onPortfolioProjectSelected,
      );
    }

    if (selectedSection != "CATALOG") {
      return _buildUnderConstruction(theme);
    }
    
    bool isCurrentProjectOpen = openTabIds.contains(projects.currentProject.id);

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutCubic,
              decoration: BoxDecoration(
                color: theme.panelBackground,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: theme.sidebarBorder.withValues(alpha: 0.35)),
              ),
              padding: const EdgeInsets.all(40),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                switchInCurve: Curves.easeInOutCubic,
                switchOutCurve: Curves.easeInOutCubic,
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.02),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: (openTabIds.isNotEmpty && isCurrentProjectOpen)
                  ? ((isPreviewMode || projects.currentProject.isSaved) 
                      ? Expanded(
                          key: ValueKey("CaseStudyWrapper_${projects.currentProject.id}"),
                          child: CaseStudyView(
                            key: ValueKey("CaseStudy_${projects.currentProject.id}"),
                            project: projects.currentProject, 
                            onBackToEdit: () {
                              if (projects.currentProject.isSaved) {
                                projects.finalizeCaseStudy(false);
                              }
                              onTogglePreview(false);
                            },
                            onDonePressed: () {
                              projects.finalizeCaseStudy(true);
                              onTogglePreview(false);
                            },
                          ),
                        )
                      : _buildEditorContent()) 
                  : _buildEmptyState(key: const ValueKey("EmptyState")),
              ),
            ),
          ),
        ),

        AnimatedOpacity(
          opacity: projects.isGenerating ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          child: projects.isGenerating
              ? Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: Container(
                      color: const Color.fromARGB(255, 18, 18, 18), 
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                              width: 40,
                              height: 40,
                              child: CircularProgressIndicator(
                                color: Color(0xFFD4C3A3),
                                strokeWidth: 2,
                              ),
                            ),
                            const SizedBox(height: 25),
                            const Text(
                              "AI IS CURATING YOUR CASE STUDY",
                              style: TextStyle(
                                color: Color.fromARGB(204, 212, 195, 163),
                                fontSize: 10,
                                letterSpacing: 3.0,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildUnderConstruction(KaelTheme theme) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          decoration: BoxDecoration(
            color: theme.panelBackgroundAlt,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: theme.sidebarBorder.withValues(alpha: 0.35)),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.construction_rounded,
                  color: theme.textDim.withValues(alpha: 0.35),
                  size: 80,
                ),
                const SizedBox(height: 20),
                Text(
                  "$selectedSection SECTION",
                  style: TextStyle(
                    color: theme.textMuted.withValues(alpha: 0.55),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "COMING SOON IN THE NEXT PHASE", 
                  style: TextStyle(
                    color: Colors.white10, 
                    fontSize: 10, 
                    letterSpacing: 1.2
                  )
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEditorContent() {
    return Column(
      key: ValueKey("Editor_${projects.currentProject.id}"),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          projects.currentProject.title.toUpperCase(),
          style: const TextStyle(
            color: Color.fromARGB(255, 255, 249, 237), 
            fontSize: 26, 
            fontFamily: 'Avenir Next', 
            fontWeight: FontWeight.bold, 
            letterSpacing: 1.5
          ),
        ),
        const SizedBox(height: 30),
        Expanded(
          child: ListView.builder(
            itemCount: projects.currentProject.cells.length,
            itemBuilder: (context, index) {
              final cell = projects.currentProject.cells[index];
              return _AnimatedCellWrapper(
                key: ValueKey(cell.id),
                child: _buildCell(
                  projectIdx: projects.currentIndex,
                  cellIdx: index,
                  cell: cell,
                  provider: projects,
                ),
              );
            },
          ),
        ),
        Row(
          children: [
            Expanded(child: _buildAddBar(projects)),
            const SizedBox(width: 20),
            _buildNextButton(),
          ],
        ),
      ],
    );
  }

  Widget _buildNextButton() {
    return GestureDetector(
      onTap: () async {
        await projects.generateAIContent();
        onTogglePreview(true);
      },
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 40),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color.fromARGB(255, 79, 78, 78), width: 1.5),
        ),
        alignment: Alignment.center,
        child: const Text(
          "NEXT", 
          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)
        ),
      ),
    );
  }

  Widget _buildAddBar(ProjectProvider p) => Container(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Container(
      height: 50, 
      decoration: BoxDecoration(
        color: Colors.black, 
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center, 
        children: [
          const Text(
            "ADD", 
            style: TextStyle(
              color: Color.fromARGB(255, 191, 178, 160), 
              fontWeight: FontWeight.bold, 
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 30),
          _AnimatedAddButton(
            label: "TEXT", 
            onTap: onAddText,
          ),
          const SizedBox(width: 10),
          _AnimatedAddButton(
            label: "IMAGE", 
            onTap: () => p.addCellToCurrentProject("IMAGE"),
          ),
          const SizedBox(width: 10),
          _AnimatedAddButton(
            label: "PDF", 
            onTap: () => p.addCellToCurrentProject("PDF"),
          ),
        ],
      ),
    ),
  );

  Widget _hoverActionText(String label) => Text(
    label, 
    style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)
  );
  
  Widget _buildEmptyState({Key? key}) => Center(
    key: key,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: const [
        Text("KAEL", style: TextStyle(fontFamily: 'Avenir Next', color: Color.fromARGB(29, 158, 142, 103), fontSize: 100, fontWeight: FontWeight.w900, letterSpacing: 20)),
        SizedBox(height: 10),
        Text("SELECT OR CREATE A PROJECT TO START EDITING", style: TextStyle(fontFamily: 'Avenir Next', color: Color.fromARGB(71, 158, 143, 103), fontSize: 12, letterSpacing: 1.2)),
      ],
    ),
  );

  Widget _buildCell({required int projectIdx, required int cellIdx, required ProjectCell cell, required ProjectProvider provider}) {
    bool isEditing = editingCellIndex == cellIdx && editingProjectIndex == projectIdx;
    bool isHovered = false;

    return StatefulBuilder(
      builder: (context, setHover) {
        return MouseRegion(
          onEnter: (_) => isEditing ? null : setHover(() => isHovered = true),
          onExit: (_) => setHover(() => isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            width: double.infinity, 
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 33, 33, 33), 
              borderRadius: BorderRadius.circular(15), 
              border: Border.all(color: (isHovered && !isEditing) ? Colors.white24 : Colors.transparent),
              boxShadow: [
                if (isHovered && !isEditing)
                  BoxShadow(
                    color: const Color.fromARGB(113, 0, 0, 0),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
              ]
            ),
            clipBehavior: Clip.antiAlias,
            child: AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOutCubic,
              alignment: Alignment.topCenter,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ImageFiltered(
                    imageFilter: ImageFilter.blur(
                      sigmaX: (isHovered && !isEditing) ? 5.0 : 0.0, 
                      sigmaY: (isHovered && !isEditing) ? 5.0 : 0.0
                    ),
                    child: _buildCellContent(cell, cellIdx == 0 && cell.type == "text", projectIdx, cellIdx, provider),
                  ),
                  Positioned.fill(
                    child: AnimatedOpacity(
                      opacity: (isHovered && !isEditing) ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeInOut,
                      child: Container(
                        color: const Color.fromARGB(73, 0, 0, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (cell.type == "text") {
                                  onStartEdit(projectIdx, cellIdx, cell.content);
                                } else if (cell.type == "image") {
                                  provider.replaceImageCell(projectIdx, cellIdx);
                                } else {
                                  provider.replacePdfCell(projectIdx, cellIdx);
                                }
                              },
                              child: _hoverActionText(cell.type == "text" ? "EDIT" : "REPLACE"),
                            ),
                            const SizedBox(width: 40),
                            GestureDetector(
                              onTap: () => provider.deleteCell(projectIdx, cellIdx), 
                              child: _hoverActionText("DELETE")
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCellContent(ProjectCell cell, bool isHeader, int pIdx, int cIdx, ProjectProvider provider) {
    if (cell.type == "image") {
      final paths = cell.imagePaths;
      if (paths.isEmpty) {
        return const SizedBox(
          height: 200,
          child: Center(child: Icon(Icons.broken_image, color: Colors.white24)),
        );
      }
      if (paths.length == 1) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Image.file(
            File(paths.first),
            width: double.infinity,
            fit: BoxFit.fitWidth,
            errorBuilder: (context, e, s) => const SizedBox(
              height: 200,
              child: Icon(Icons.broken_image, color: Colors.white24),
            ),
          ),
        );
      }

      final crossCount = paths.length <= 4 ? 2 : 3;
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (cell.title.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 10),
                child: Text(
                  cell.title,
                  style: const TextStyle(color: Colors.white54, fontSize: 11, letterSpacing: 1.1),
                ),
              ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: paths.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossCount,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.2,
              ),
              itemBuilder: (context, idx) => ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  File(paths[idx]),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.white10,
                    child: const Icon(Icons.broken_image, color: Colors.white24),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    if (cell.type == "pdf") {
      return Container(
        width: double.infinity, padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(color: const Color(0xFF121212), borderRadius: BorderRadius.circular(15)),
        child: Row(children: [
          const Icon(Icons.picture_as_pdf, color: Color(0xFFD4C3A3), size: 30),
          const SizedBox(width: 20),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(cell.title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
            const Text("PDF Document", style: TextStyle(color: Colors.white24, fontSize: 11)),
          ])),
        ]),
      );
    }

    bool isEditing = editingCellIndex == cIdx && editingProjectIndex == pIdx;
    return Padding(
      padding: const EdgeInsets.all(30),
      child: isEditing
          ? TextField(
              controller: textController, focusNode: textFocusNode, autofocus: true, maxLines: null,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: const InputDecoration(border: InputBorder.none, hintText: "Type something...", hintStyle: TextStyle(color: Colors.white10)),
              onSubmitted: (_) => onSaveEdit(),
            )
          : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (cell.title.isNotEmpty) Text(cell.title, style: TextStyle(color: Colors.white, fontSize: isHeader ? 28 : 16, fontFamily: 'Serif')),
              if (cell.title.isNotEmpty) const SizedBox(height: 15),
              Text(cell.content.isEmpty ? "Click edit to add text..." : cell.content, style: const TextStyle(color: Colors.white38, fontSize: 13, height: 1.5)),
            ]),
    );
  }
}

class _AnimatedCellWrapper extends StatefulWidget {
  final Widget child;
  const _AnimatedCellWrapper({required this.child, super.key});

  @override
  State<_AnimatedCellWrapper> createState() => _AnimatedCellWrapperState();
}

class _AnimatedCellWrapperState extends State<_AnimatedCellWrapper> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.94, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        alignment: Alignment.bottomCenter,
        child: widget.child,
      ),
    );
  }
}

class _AnimatedAddButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _AnimatedAddButton({
    required this.label,
    required this.onTap,
  });

  @override
  State<_AnimatedAddButton> createState() => _AnimatedAddButtonState();
}

class _AnimatedAddButtonState extends State<_AnimatedAddButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutBack, 
          padding: EdgeInsets.symmetric(
            horizontal: _isHovered ? 26 : 20, 
            vertical: _isHovered ? 5 : 3,
          ),
          decoration: BoxDecoration(
            color: _isHovered 
                ? const Color.fromARGB(100, 127, 98, 39) 
                : const Color.fromARGB(60, 127, 98, 39), 
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isHovered ? const Color.fromARGB(83, 212, 195, 163): Colors.transparent,
              width: 1,
            ),
          ),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            style: TextStyle(
              color: _isHovered ? const Color(0xFFD4C3A3) : const Color.fromARGB(255, 191, 178, 160), 
              fontSize: _isHovered ? 11.5 : 11, 
              letterSpacing: 1.1,
              fontWeight: _isHovered ? FontWeight.bold : FontWeight.normal,
            ),
            child: Text(widget.label),
          ),
        ),
      ),
    );
  }
}