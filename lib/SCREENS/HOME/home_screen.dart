import 'package:flutter/material.dart';
import 'package:kael/SCREENS/GLOBAL%20WIDGETS/kael_tab_bar.dart';
import 'package:kael/SCREENS/GLOBAL%20WIDGETS/workspace_background.dart';
import 'package:kael/SCREENS/HOME/WIDGETS/Catalog/home_catalog_canvas.dart';
import 'package:kael/SCREENS/HOME/WIDGETS/sidebar/home_sidebar.dart';
import 'package:provider/provider.dart';
import 'package:kael/SCREENS/FORMS/DATA%20MODEL/user_data_model.dart';
import 'package:kael/SCREENS/HOME/PROVIDER/project_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  bool isPortfolioGenerated = false; 
  bool isPreviewMode = false;
  String currentNavSection = "CATALOG";
  
  // --- ANIMATION STATE ---
  late AnimationController _notificationController;
  late Animation<Offset> _notificationSlideAnimation;
  bool _showWelcomeNotification = false;

  // --- TAB STATE ENGINES ---
  List<String> openTabIds = ['0'];
  List<String> openPortfolioTabIds = [];
  String? activePortfolioProjectId;

  int? editingCellIndex;
  int? editingProjectIndex;
  late TextEditingController _textController;
  final FocusNode _textFocusNode = FocusNode();
  bool isCatalogExpanded = true;
  bool _catalogNextHovered = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _textFocusNode.addListener(() {
      if (!_textFocusNode.hasFocus && editingCellIndex != null) _saveCurrentEdit();
    });

    // --- WELCOME NOTIFICATION ANIMATION ---
    _notificationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _notificationSlideAnimation = Tween<Offset>(
      begin: const Offset(1.5, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _notificationController, curve: Curves.easeOutBack));

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _showWelcomeNotification = true);
        _notificationController.forward();
        Future.delayed(const Duration(seconds: 4), () {
          if (mounted) {
            _notificationController.reverse().then((_) {
              if (mounted) setState(() => _showWelcomeNotification = false);
            });
          }
        });
      }
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
          decoration: const InputDecoration(enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF9A9A9A))))
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL", style: TextStyle(color: Colors.white24))),
          TextButton(onPressed: () { projects.renameProject(idx, controller.text); Navigator.pop(context); }, child: const Text("SAVE", style: TextStyle(color: Color(0xFF9A9A9A)))),
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
              openPortfolioTabIds.remove(idToDelete);
              if (activePortfolioProjectId == idToDelete) {
                activePortfolioProjectId = openPortfolioTabIds.isNotEmpty ? openPortfolioTabIds.last : null;
              }
            });
            projects.deleteProject(idx); 
            Navigator.pop(context);
          }, child: const Text("DELETE PERMANENTLY", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  @override
  void dispose() { 
    _textController.dispose(); 
    _textFocusNode.dispose(); 
    _notificationController.dispose(); 
    super.dispose(); 
  }

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserDataModel>(context);
    final projectData = Provider.of<ProjectProvider>(context);

    bool isPortfolioMode = currentNavSection == "PORTFOLIO";
    
    String derivedLeadingLabel = isPortfolioMode ? "Portfolio View" : "Project Catalog";
    
    List<String> derivedTabs = isPortfolioMode
        ? openPortfolioTabIds.map((id) => projectData.projects.firstWhere((p) => p.id == id).title).toList()
        : openTabIds.map((id) => projectData.projects.firstWhere((p) => p.id == id).title).toList();

    String derivedActiveTab = "";
    if (isPortfolioMode) {
      if (activePortfolioProjectId != null) {
        derivedActiveTab = projectData.projects.firstWhere((p) => p.id == activePortfolioProjectId).title;
      }
    } else {
      derivedActiveTab = openTabIds.isEmpty ? "" : projectData.currentProject.title;
    }

    return Scaffold(
      body: Stack(
        children: [
          
          WorkspaceBackground(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
              child: Row(
                children: [
                  HomeSidebar(
                    userData: userData, 
                    projectData: projectData, 
                    isCatalogExpanded: isCatalogExpanded, 
                    openTabIds: openTabIds,
                    currentNavSection: currentNavSection, 
                    onSectionTap: (section) {             
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
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOutCubic,
                          transform: Matrix4.translationValues(0, _catalogNextHovered ? -6 : 0, 0),
                          child: KaelTabBar(
                          leadingLabel: derivedLeadingLabel,
                          tabs: derivedTabs,
                          activeTab: derivedActiveTab,
                          onTabTap: (title) {
                            int idx = projectData.projects.indexWhere((p) => p.title == title);
                            if (idx != -1) {
                              final tappedProject = projectData.projects[idx];
                              setState(() {
                                if (isPortfolioMode) {
                                  activePortfolioProjectId = tappedProject.id;
                                } else {
                                  projectData.selectProject(idx);
                                  isPreviewMode = false;
                                }
                              });
                            }
                          },
                          onTabClose: (title) {
                            setState(() {
                              final String idToClose = projectData.projects.firstWhere((p) => p.title == title).id;
                              
                              if (isPortfolioMode) {
                                int indexInOpenTabs = openPortfolioTabIds.indexOf(idToClose);
                                if (indexInOpenTabs != -1) {
                                  openPortfolioTabIds.removeAt(indexInOpenTabs);
                                  if (activePortfolioProjectId == idToClose) {
                                    if (openPortfolioTabIds.isNotEmpty) {
                                      activePortfolioProjectId = (indexInOpenTabs > 0) 
                                          ? openPortfolioTabIds[indexInOpenTabs - 1] 
                                          : openPortfolioTabIds[0];
                                    } else {
                                      activePortfolioProjectId = null;
                                    }
                                  }
                                }
                              } else {
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
                              }
                            });
                          },
                        ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOutCubic,
                          height: _catalogNextHovered ? 26 : 20,
                        ),
                        Expanded(
                          child: HomeCanvas(
                            selectedSection: currentNavSection, 
                            userData: userData, 
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
                            isPortfolioGenerated: isPortfolioGenerated,
                            onGeneratePortfolio: () {
                              setState(() {
                                isPortfolioGenerated = true;
                              });
                            },
                            activePortfolioProjectId: activePortfolioProjectId,
                            onPortfolioProjectSelected: (id) {
                              setState(() {
                                if (id != null) {
                                  if (!openPortfolioTabIds.contains(id)) {
                                    openPortfolioTabIds.add(id);
                                  }
                                  activePortfolioProjectId = id;
                                } else {
                                  activePortfolioProjectId = null;
                                }
                              });
                            },
                            onCatalogNextHover: (hovered) {
                              if (_catalogNextHovered != hovered) {
                                setState(() => _catalogNextHovered = hovered);
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
          ),
          
          // --- WELCOME NOTIFICATION OVERLAY ---
          if (_showWelcomeNotification)
            Positioned(
              top: 50,
              right: 30,
              child: SlideTransition(
                position: _notificationSlideAnimation,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF9A9A9A)),
                    boxShadow: [const BoxShadow(color: Colors.black45, blurRadius: 10)],
                  ),
                  child: Text(
                    "WELCOME ${userData.fullName.toUpperCase()}",
                    style: const TextStyle(color: Colors.white, letterSpacing: 1.5, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}