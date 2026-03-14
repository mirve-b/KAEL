import 'package:flutter/material.dart';
import 'package:kael/SCREENS/GLOBAL%20WIDGETS/kael_tab_bar.dart';
import 'package:kael/SCREENS/HOME/WIDGETS/home_canvas.dart';
import 'package:kael/SCREENS/HOME/WIDGETS/home_sidebar.dart';
import 'package:provider/provider.dart';
import 'package:kael/SCREENS/FORMS/DATA%20MODEL/user_data_model.dart';
import 'package:kael/SCREENS/HOME/PROVIDER/project_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isPreviewMode = false;
  String currentNavSection = "CATALOG";
  List<String> openTabIds = ['0']; 
  int? editingCellIndex;
  int? editingProjectIndex;
  late TextEditingController _textController;
  final FocusNode _textFocusNode = FocusNode();
  bool isCatalogExpanded = true;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _textFocusNode.addListener(() {
      if (!_textFocusNode.hasFocus && editingCellIndex != null) _saveCurrentEdit();
    });
  }

  void _saveCurrentEdit() {
    if (editingCellIndex != null && editingProjectIndex != null) {
      final p = Provider.of<ProjectProvider>(context, listen: false);
      p.updateCellContent(editingProjectIndex!, editingCellIndex!, "", _textController.text);
      setState(() { editingCellIndex = null; editingProjectIndex = null; });
    }
  }

  void _showRenameDialog(int idx, String currentTitle, ProjectProvider projects) {
    final controller = TextEditingController(text: currentTitle);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text("Rename Project", style: TextStyle(color: Colors.white, fontSize: 14)),
        content: TextField(
          controller: controller, 
          autofocus: true, 
          style: const TextStyle(color: Colors.white), 
          decoration: const InputDecoration(enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFD4C3A3))))
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL", style: TextStyle(color: Colors.white24))),
          TextButton(onPressed: () { projects.renameProject(idx, controller.text); Navigator.pop(context); }, child: const Text("SAVE", style: TextStyle(color: Color(0xFFD4C3A3)))),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(int idx, String title, ProjectProvider projects) {
    final String idToDelete = projects.projects[idx].id;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text("Delete '$title'?", style: const TextStyle(color: Colors.white, fontSize: 16)),
        content: const Text("This action cannot be undone. All cells and content in this project will be permanently removed.", style: TextStyle(color: Colors.white38, fontSize: 13)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL", style: TextStyle(color: Colors.white24))),
          TextButton(onPressed: () {
            setState(() {
              openTabIds.remove(idToDelete);
            });
            projects.deleteProject(idx); 
            Navigator.pop(context);
          }, child: const Text("DELETE PERMANENTLY", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  @override
  void dispose() { _textController.dispose(); _textFocusNode.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserDataModel>(context);
    final projectData = Provider.of<ProjectProvider>(context);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 22, 22, 22),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
        child: Row(
          children: [
            HomeSidebar(
              userData: userData, 
              projectData: projectData, 
              isCatalogExpanded: isCatalogExpanded, 
              openTabIds: openTabIds,
              currentNavSection: currentNavSection, // NEW
              onSectionTap: (section) {             // NEW
                setState(() {
                  currentNavSection = section;
                  if (section == "CATALOG") isCatalogExpanded = true;
                });
              },
              onToggleCatalog: () {
                setState(() {
                  currentNavSection = "CATALOG";
                  isCatalogExpanded = !isCatalogExpanded;
                });
              },
              onProjectTap: (idx) {
                final project = projectData.projects[idx];
                projectData.selectProject(idx);
                setState(() {
                  currentNavSection = "CATALOG";
                  isPreviewMode = false;
                  if (!openTabIds.contains(project.id)) {
                    openTabIds.add(project.id);
                  }
                });
              },
              onRenameRequest: (idx, title) => _showRenameDialog(idx, title, projectData),
              onDeleteRequest: (idx, title) => _showDeleteConfirmation(idx, title, projectData),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                children: [
                  KaelTabBar(
  leadingLabel: "Project Catalog",
  tabs: openTabIds.map((id) => projectData.projects.firstWhere((p) => p.id == id).title).toList(),
  activeTab: openTabIds.isEmpty ? "" : projectData.currentProject.title,
  
  onTabTap: (title) {
    int idx = projectData.projects.indexWhere((p) => p.title == title);
    if (idx != -1) {
      projectData.selectProject(idx);
      setState(() {
        currentNavSection = "CATALOG";
        isPreviewMode = false;
      });
    }
  },
  
  onTabClose: (title) {
    setState(() {
      final String idToClose = projectData.projects.firstWhere((p) => 
        p.title == title && openTabIds.contains(p.id)
      ).id;
      
      int indexInOpenTabs = openTabIds.indexOf(idToClose);

      if (indexInOpenTabs != -1) {
        openTabIds.removeAt(indexInOpenTabs);

        if (projectData.currentProject.id == idToClose) {
          if (openTabIds.isNotEmpty) {
            String nextId = (indexInOpenTabs > 0) ? openTabIds[indexInOpenTabs - 1] : openTabIds[0];
            int nextIdx = projectData.projects.indexWhere((p) => p.id == nextId);
            projectData.selectProject(nextIdx);
          }
        }
      }
    });
  },
),
                  const SizedBox(height: 20),
                  Expanded(
                    child: HomeCanvas(
                      selectedSection: currentNavSection, // NEW
                      projects: projectData, 
                      openTabIds: openTabIds, 
                      editingCellIndex: editingCellIndex, 
                      editingProjectIndex: editingProjectIndex,
                      textController: _textController, 
                      textFocusNode: _textFocusNode,
                      onSaveEdit: _saveCurrentEdit,
                      isPreviewMode: isPreviewMode, 
                      onTogglePreview: (val) {
                        setState(() {
                          isPreviewMode = val;
                        });
                      },
                      onStartEdit: (pIdx, cIdx, content) {
                        setState(() { 
                          editingCellIndex = cIdx; 
                          editingProjectIndex = pIdx; 
                          _textController.text = content; 
                        });
                      },
                      onAddText: () async {
                        int? newIdx = await projectData.addCellToCurrentProject("TEXT");
                        if (newIdx != null) {
                          setState(() { 
                            editingCellIndex = newIdx; 
                            editingProjectIndex = projectData.currentIndex; 
                            _textController.clear(); 
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}