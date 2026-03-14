import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:kael/SCREENS/HOME/DATA%20MODEL/project_model.dart';
import 'package:kael/SCREENS/HOME/PROVIDER/project_provider.dart';
import 'package:kael/SCREENS/HOME/WIDGETS/home_casestudy.dart';

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
  
  // NEW PARAMETER
  final String selectedSection; 

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
    required this.selectedSection, // INITIALIZE
  });

  @override
  Widget build(BuildContext context) {
    // 1. Check if we should show the "Under Construction" state
    if (selectedSection != "CATALOG") {
      return _buildUnderConstruction();
    }
    // 2. Otherwise, continue with the standard Catalog logic
    bool isCurrentProjectOpen = openTabIds.contains(projects.currentProject.id);

    return Stack(
      children: [
        // MAIN CONTENT LAYER
        Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 18, 18, 18), 
            borderRadius: BorderRadius.circular(25), 
            border: Border.all(color: Colors.white10)
          ),
          padding: const EdgeInsets.all(40),
          child: (openTabIds.isNotEmpty && isCurrentProjectOpen)
            ? (isPreviewMode 
                ? CaseStudyView(
                    project: projects.currentProject, 
                    onBack: () => onTogglePreview(false)
                  )
                : _buildEditorContent()) 
            : _buildEmptyState(),
        ),

        // AI LOADING OVERLAY LAYER
        if (projects.isGenerating)
          Positioned.fill(
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
                      Text(
                        "AI IS CURATING YOUR CASE STUDY",
                        style: TextStyle(
                          color: const Color.fromARGB(204, 212, 195, 163),
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
          ),
      ],
    );
  }

  // ---HELPER: UNDER CONSTRUCTION ---
  Widget _buildUnderConstruction() {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 18, 18, 18), 
        borderRadius: BorderRadius.circular(25), 
        border: Border.all(color: Colors.white10)
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.construction_rounded, 
              color: const Color.fromARGB(27, 212, 195, 163), 
              size: 80
            ),
            const SizedBox(height: 20),
            Text(
              "$selectedSection SECTION", 
              style: const TextStyle(
                color: Color.fromARGB(71, 158, 143, 103), 
                fontSize: 14, 
                fontWeight: FontWeight.bold,
                letterSpacing: 4
              )
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
    );
  }

  // --- HELPER: EDITOR CONTENT ---
  Widget _buildEditorContent() {
    return Column(
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
            itemBuilder: (context, index) => _buildCell(
              projectIdx: projects.currentIndex,
              cellIdx: index,
              cell: projects.currentProject.cells[index],
              provider: projects,
            ),
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
      decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(15)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center, 
        children: [
          const Text("ADD", style: TextStyle(color: Color.fromARGB(255, 191, 178, 160), fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(width: 30),
          GestureDetector(onTap: onAddText, child: _addIconLabel("TEXT")),
          const SizedBox(width: 10),
          GestureDetector(onTap: () => p.addCellToCurrentProject("IMAGE"), child: _addIconLabel("IMAGE")),
          const SizedBox(width: 10),
          GestureDetector(onTap: () => p.addCellToCurrentProject("PDF"), child: _addIconLabel("PDF")),
        ]
      ),
    ),
  );

  Widget _addIconLabel(String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 3),
    decoration: BoxDecoration(color: const Color.fromARGB(60, 127, 98, 39), borderRadius: BorderRadius.circular(20)),
    child: Text(label, style: const TextStyle(color: Color.fromARGB(255, 191, 178, 160), fontSize: 11, letterSpacing: 1.1)),
  );

  Widget _hoverActionText(String label) => Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold));
  
  Widget _buildEmptyState() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text("KAEL", style: TextStyle(fontFamily: 'Avenir Next', color: Color.fromARGB(29, 158, 142, 103), fontSize: 100, fontWeight: FontWeight.w900, letterSpacing: 20)),
        const SizedBox(height: 10),
        const Text("SELECT OR CREATE A PROJECT TO START EDITING", style: TextStyle(fontFamily: 'Avenir Next', color: Color.fromARGB(71, 158, 143, 103), fontSize: 12, letterSpacing: 1.2)),
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
          child: Container(
            width: double.infinity, margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(15), border: Border.all(color: (isHovered && !isEditing) ? Colors.white12 : Colors.transparent)),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              alignment: Alignment.center,
              children: [
                ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: (isHovered && !isEditing) ? 4.0 : 0.0, sigmaY: (isHovered && !isEditing) ? 4.0 : 0.0),
                  child: _buildCellContent(cell, cellIdx == 0 && cell.type == "text", projectIdx, cellIdx, provider),
                ),
                if (isHovered && !isEditing)
                  Row(
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
                      GestureDetector(onTap: () => provider.deleteCell(projectIdx, cellIdx), child: _hoverActionText("DELETE")),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCellContent(ProjectCell cell, bool isHeader, int pIdx, int cIdx, ProjectProvider provider) {
    if (cell.type == "image") {
      return ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Image.file(File(cell.content), width: double.infinity, fit: BoxFit.fitWidth, errorBuilder: (context, e, s) => const SizedBox(height: 200, child: Icon(Icons.broken_image, color: Colors.white24))),
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