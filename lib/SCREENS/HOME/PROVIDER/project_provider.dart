import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:kael/API/cv_project_extractor.dart';
import 'package:kael/API/gemini_service.dart';
import 'package:kael/SCREENS/FORMS/DATA%20MODEL/user_data_model.dart';
import 'package:kael/SCREENS/HOME/DATA%20MODEL/project_model.dart';
import 'package:kael/SCREENS/PROFILE/DATA%20MODEL/cv_models.dart';

class ProjectProvider extends ChangeNotifier {
  final GeminiService _geminiService = GeminiService();
  final CvProjectExtractor _cvProjectExtractor = CvProjectExtractor();
  
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

  bool _isSyncingProfile = false;
  bool get isSyncingProfile => _isSyncingProfile;

  /// Adds or updates the matching Profile > Projects entry using AI-extracted CV fields.
  Future<bool> syncCurrentProjectToProfile(UserDataModel user) async {
    final project = currentProject;
    if (project.id == '0' || !project.isSaved || project.caseStudy == null) {
      return false;
    }

    _isSyncingProfile = true;
    notifyListeners();

    user.upsertCvProject(CvProjectEntry(
      id: project.id,
      name: project.title,
      description: 'Generating CV project summary...',
    ));

    try {
      final entry = await _cvProjectExtractor.extract(user: user, project: project);
      user.upsertCvProject(entry);
      return true;
    } catch (_) {
      user.upsertCvProject(_cvProjectExtractor.fallback(project));
      return false;
    } finally {
      _isSyncingProfile = false;
      notifyListeners();
    }
  }

  // --- GENERATION ENGINE LAYER ---
  bool _isGenerating = false;
  bool get isGenerating => _isGenerating;
  String? lastGenerationError;

  Future<bool> generateAIContent(UserDataModel user) async {
    lastGenerationError = null;
    _isGenerating = true;
    notifyListeners();

    try {
      currentProject.caseStudy = CaseStudyData(
        problem: "Detecting creative field...",
        objectives: "Loading discipline profile...",
        methodology: "Mapping research -> ideation -> creation...",
        designDecisions: "Analyzing project visuals and notes...",
        solution: "Generating specialized sections...",
        results: "Applying Kael writing style...",
      );
      notifyListeners();

      await Future<void>.delayed(Duration.zero);

      final String aiResult = await _geminiService.getCaseStudy(
        user: user,
        projectTitle: currentProject.title,
        cells: currentProject.cells,
      );
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
      return true;
    } catch (e) {
      lastGenerationError = _friendlyGenerationError(e);
      currentProject.caseStudy = null;
      return false;
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }

  String _friendlyGenerationError(Object error) {
    final msg = error.toString().toLowerCase();
    if (msg.contains('503') || msg.contains('unavailable') || msg.contains('high demand')) {
      return '**Gemini is temporarily overloaded (503).** This is a Google server-side spike — you do **not** need a new API key. Wait a minute and click **NEXT** again. The app will auto-retry with fallback models.';
    }
    if (msg.contains('429') || msg.contains('resource exhausted')) {
      return '**Rate limit reached.** Wait a few minutes before retrying. Free-tier quotas reset over time — a new API key will not help if the quota is account-wide.';
    }
    if (msg.contains('timeout') || msg.contains('timed out')) {
      return '**Generation timed out.** Gemini took too long to respond — try again with fewer/lighter images or wait a minute.';
    }
    if (msg.contains('api key') || msg.contains('permission') || msg.contains('401')) {
      return '**API key issue.** Check that `GEMINI_API_KEY` in your `.env` file is valid and has Generative Language API access enabled.';
    }
    return '**Generation failed:** ${error.toString()}';
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

  // --- Portfolio display order ---
  final List<String> _portfolioOrder = [];

  List<ProjectPage> get savedProjectsForPortfolio {
    final saved = _projects.where((p) => p.isSaved).toList();
    if (_portfolioOrder.isEmpty) return saved;

    final byId = {for (final p in saved) p.id: p};
    final ordered = <ProjectPage>[];
    for (final id in _portfolioOrder) {
      final project = byId.remove(id);
      if (project != null) ordered.add(project);
    }
    ordered.addAll(byId.values);
    return ordered;
  }

  void reorderPortfolioProjects(int oldIndex, int newIndex) {
    final saved = savedProjectsForPortfolio;
    if (oldIndex < 0 || oldIndex >= saved.length) return;
    if (newIndex < 0 || newIndex > saved.length) return;

    if (oldIndex < newIndex) newIndex -= 1;
    final item = saved.removeAt(oldIndex);
    saved.insert(newIndex, item);

    _portfolioOrder
      ..clear()
      ..addAll(saved.map((p) => p.id));
    notifyListeners();
  }

  void setProjectPortfolioThumbnail(String projectId, String? path) {
    final idx = _projects.indexWhere((p) => p.id == projectId);
    if (idx == -1) return;
    _projects[idx].portfolioThumbnailPath = path;
    notifyListeners();
  }

  Future<void> pickProjectPortfolioThumbnail(String projectId) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      setProjectPortfolioThumbnail(projectId, result.files.single.path);
    }
  }
}