import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:kael/API/gemini_service.dart';
import 'package:kael/SCREENS/HOME/DATA%20MODEL/project_model.dart';

class ProjectProvider extends ChangeNotifier {
  final GeminiService _geminiService = GeminiService();
  
  // --- DATA ---
  final List<ProjectPage> _projects = [
    ProjectPage(
      id: '0',
      title: 'Guide',
      cells: [
        ProjectCell(
          id: 'g1',
          type: 'text',
          title: 'Welcome to your Project Catalog',
          content: 'your personal workspace for organizing everything you create on Kael.',
        ),
        ProjectCell(
          id: 'g2',
          type: 'text',
          title: "What's a Cell?",
          content: 'Each project is built using cells - flexible blocks where you can add text, images, videos...',
        ),
      ],
    ),
  ];

  int _currentIndex = 0;

  // --- GETTERS ---
  List<ProjectPage> get projects => _projects;
  int get currentIndex => _currentIndex;

  ProjectPage get currentProject {
    if (_projects.isEmpty || _currentIndex >= _projects.length) {
      return ProjectPage(id: 'temp', title: 'Empty', cells: []);
    }
    return _projects[_currentIndex];
  }

  // --- PROJECT ACTIONS ---
  void selectProject(int index) {
    if (index >= 0 && index < _projects.length) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  void addNewProject(String baseName) {
    int count = projects.where((p) => p.title.startsWith("NEW PROJECT")).length;
    String uniqueTitle = count == 0 ? "NEW PROJECT" : "NEW PROJECT ${count + 1}";
    
    final newProject = ProjectPage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: uniqueTitle,
      cells: [],
    );
    
    projects.add(newProject);
    notifyListeners();
  }

  void renameProject(int index, String newTitle) {
    if (index >= 0 && index < _projects.length) {
      _projects[index].title = newTitle;
      notifyListeners();
    }
  }

  void deleteProject(int index) {
    if (index < 0 || index >= _projects.length) return;

    _projects.removeAt(index);
    if (_projects.isEmpty) {
      _currentIndex = 0;
    } else if (_currentIndex >= _projects.length) {
      _currentIndex = _projects.length - 1;
    } else if (_currentIndex > index) {
      _currentIndex--;
    }
    notifyListeners();
  }

  // --- CELL ACTIONS ---
  Future<int?> addCellToCurrentProject(String type) async {
    if (_projects.isEmpty) return null;

    String content = "";
    String title = "";

    if (type == "IMAGE" || type == "PDF") {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: type == "IMAGE" ? FileType.image : FileType.custom,
        allowedExtensions: type == "PDF" ? ['pdf'] : null,
        allowMultiple: type == "IMAGE",
      );

      if (result != null && result.files.isNotEmpty) {
        if (type == "IMAGE") {
          final paths = result.files
              .where((f) => f.path != null && f.path!.isNotEmpty)
              .map((f) => f.path!)
              .toList();
          if (paths.isEmpty) return null;
          content = jsonEncode(paths);
          title = paths.length > 1 ? '${paths.length} images' : '';
        } else if (result.files.single.path != null) {
          content = result.files.single.path!;
          title = result.files.single.name;
        } else {
          return null;
        }
      } else {
        return null;
      }
    }

    // HIGH-PRECISION TIMESTAMP ID LINKED TO TYPE
    // This allows unique Key bindings for implicit list mounting animations
    final newCell = ProjectCell(
      id: '${type.toLowerCase()}_${DateTime.now().microsecondsSinceEpoch}',
      type: type.toLowerCase(),
      title: title,
      content: content,
    );

    _projects[_currentIndex].cells.add(newCell);
    notifyListeners();
    return _projects[_currentIndex].cells.length - 1;
  }

  Future<void> replaceImageCell(int projectIndex, int cellIndex) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );
    if (result != null && result.files.isNotEmpty) {
      final paths = result.files
          .where((f) => f.path != null && f.path!.isNotEmpty)
          .map((f) => f.path!)
          .toList();
      if (paths.isEmpty) return;
      _projects[projectIndex].cells[cellIndex].imagePaths = paths;
      _projects[projectIndex].cells[cellIndex].title =
          paths.length > 1 ? '${paths.length} images' : '';
      notifyListeners();
    }
  }

  Future<void> replacePdfCell(int projectIndex, int cellIndex) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.single.path != null) {
      _projects[projectIndex].cells[cellIndex].content = result.files.single.path!;
      _projects[projectIndex].cells[cellIndex].title = result.files.single.name;
      notifyListeners();
    }
  }

  void updateCellContent(int projectIndex, int cellIndex, String newTitle, String newContent) {
    _projects[projectIndex].cells[cellIndex].title = newTitle;
    _projects[projectIndex].cells[cellIndex].content = newContent;
    notifyListeners();
  }

  void deleteCell(int projectIndex, int cellIndex) {
    if (_projects[projectIndex].cells.isNotEmpty) {
      _projects[projectIndex].cells.removeAt(cellIndex);
      notifyListeners();
    }
  }

  // --- STATE MUTATION LINK NODE ---
  void finalizeCaseStudy(bool savedState) {
    currentProject.isSaved = savedState;
    notifyListeners();
  }

  // --- GENERATION ENGINE LAYER ---
  bool _isGenerating = false;
  bool get isGenerating => _isGenerating;
  Future<void> generateAIContent() async {
    _isGenerating = true;
    notifyListeners();

    try {
      // 1. DYNAMIC INDETERMINATE LOADING STATE
      currentProject.caseStudy = CaseStudyData(
        problem: "Analyzing architectural constraints...",
        objectives: "Defining project milestones...",
        methodology: "Synthesizing process cycles...",
        designDecisions: "Reviewing spatial layout configurations...",
        solution: "Curation in progress...",
        results: "Optimizing presentation blocks...",
      );
      notifyListeners();

      // 2. DISPATCH ASYMMETRIC API REQUEST
      final String aiResult = await _geminiService.getCaseStudy(currentProject.cells);

      final sections = _geminiService.parseCaseStudySections(aiResult);

      currentProject.caseStudy = CaseStudyData(
        overview: sections['OVERVIEW'] ?? '',
        problem: sections['PROBLEM'] ?? '',
        objectives: sections['OBJECTIVES'] ?? '',
        methodology: sections['METHODOLOGY'] ?? '',
        designDecisions: sections['DESIGN DECISIONS'] ?? '',
        solution: sections['SOLUTION'] ?? '',
        results: sections['RESULTS'] ?? '',
      );

    } catch (e) {
      print("DEBUG CRITICAL API ERROR: $e");
      currentProject.caseStudy = CaseStudyData(
        solution: "Failed to construct architectural payload views. Details: $e",
      );
    }

    _isGenerating = false;
    notifyListeners();
  }

bool _isLightMode = false;
  bool get isLightMode => _isLightMode;

  /// Legacy alias — polka mode is now app light mode.
  bool get isPolkaDotBackground => _isLightMode;

  void toggleLightMode() {
    _isLightMode = !_isLightMode;
    notifyListeners();
  }

  void toggleBackgroundTheme() => toggleLightMode();
}