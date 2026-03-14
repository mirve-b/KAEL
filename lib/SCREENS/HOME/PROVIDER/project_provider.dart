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
    id: DateTime.now().millisecondsSinceEpoch.toString(), // Unique ID
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
      );

      if (result != null && result.files.single.path != null) {
        content = result.files.single.path!;
        title = type == "PDF" ? result.files.single.name : "";
      } else {
        return null;
      }
    }

    final newCell = ProjectCell(
      id: DateTime.now().toString(),
      type: type.toLowerCase(),
      title: title,
      content: content,
    );

    _projects[_currentIndex].cells.add(newCell);
    notifyListeners();
    return _projects[_currentIndex].cells.length - 1;
  }

  Future<void> replaceImageCell(int projectIndex, int cellIndex) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      _projects[projectIndex].cells[cellIndex].content = result.files.single.path!;
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

  bool _isGenerating = false;
bool get isGenerating => _isGenerating;

Future<void> generateAIContent() async {
  _isGenerating = true;
  notifyListeners();

  try {
    // 1. SET LOADING STATE
    currentProject.caseStudy = CaseStudyData(
      problem: "Analyzing constraints...",
      objectives: "Defining goals...",
      methodology: "Synthesizing process...",
      solution: "Curation in progress...",
    );
    notifyListeners();

    // 2. CALL API
    final String aiResult = await _geminiService.getCaseStudy(currentProject.cells);
    print("GEMINI SUCCESS: $aiResult");

    // 3. THE SLICER (Parsing logic)
    // This function looks for "HEADER: content" and stops at the next header
    String extractSection(String header) {
      final regExp = RegExp('$header\\s*(.*?)(?=(PROBLEM:|OBJECTIVES:|METHODOLOGY:|SOLUTION:|\$))', 
          dotAll: true, caseSensitive: false);
      final match = regExp.firstMatch(aiResult);
      return match?.group(1)?.trim() ?? "Information not found.";
    }

    // 4. ASSIGN INDIVIDUAL SECTIONS
    currentProject.caseStudy = CaseStudyData(
      problem: extractSection("PROBLEM:"),
      objectives: extractSection("OBJECTIVES:"),
      methodology: extractSection("METHODOLOGY:"),
      designDecisions: "Automated based on project visual hierarchy.",
      solution: extractSection("SOLUTION:"),
      results: "Optimized for professional showcase.",
    );

  } catch (e) {
    print("DEBUG API ERROR: $e");
    currentProject.caseStudy = CaseStudyData(
      solution: "Failed to parse AI response. Error: $e",
    );
  }

  _isGenerating = false;
  notifyListeners();
}
}