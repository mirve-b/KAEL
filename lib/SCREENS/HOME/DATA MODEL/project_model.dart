import 'dart:convert';

class ProjectCell {
  String id;
  String type;
  String title;
  String content;

  ProjectCell({
    required this.id,
    required this.type,
    required this.title,
    required this.content,
  });

  /// Image cells store a JSON array of local file paths.
  List<String> get imagePaths {
    if (type != 'image') return [];
    if (content.isEmpty) return [];
    try {
      final decoded = jsonDecode(content);
      if (decoded is List) {
        return decoded.map((e) => e.toString()).where((p) => p.isNotEmpty).toList();
      }
    } catch (_) {}
    return [content];
  }

  set imagePaths(List<String> paths) {
    content = jsonEncode(paths);
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'type': type,
        'title': title,
        'content': content,
      };

  factory ProjectCell.fromMap(Map<String, dynamic> map) {
    return ProjectCell(
      id: map['id'] ?? '',
      type: map['type'] ?? 'text',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
    );
  }
}

class ProjectPage {
  String id;
  String title;
  List<ProjectCell> cells;
  CaseStudyData? caseStudy;
  bool isSaved;

  ProjectPage({
    required this.id,
    required this.title,
    required this.cells,
    this.caseStudy,
    this.isSaved = false,
  });

  List<String> get allImagePaths {
    return cells
        .where((c) => c.type == 'image')
        .expand((c) => c.imagePaths)
        .where((p) => p.isNotEmpty)
        .toList();
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'cells': cells.map((c) => c.toMap()).toList(),
        'isSaved': isSaved,
        'caseStudy': caseStudy?.toMap(),
      };

  factory ProjectPage.fromMap(Map<String, dynamic> map) {
    return ProjectPage(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      cells: (map['cells'] as List? ?? [])
          .map((c) => ProjectCell.fromMap(c))
          .toList(),
      isSaved: map['isSaved'] ?? false,
      caseStudy: map['caseStudy'] != null ? CaseStudyData.fromMap(map['caseStudy']) : null,
    );
  }
}

class CaseStudyData {
  String overview;
  String problem;
  String objectives;
  String methodology;
  String designDecisions;
  String solution;
  String results;

  CaseStudyData({
    this.overview = "",
    this.problem = "",
    this.objectives = "",
    this.methodology = "",
    this.designDecisions = "",
    this.solution = "",
    this.results = "",
  });

  Map<String, dynamic> toMap() => {
        'overview': overview,
        'problem': problem,
        'objectives': objectives,
        'methodology': methodology,
        'designDecisions': designDecisions,
        'solution': solution,
        'results': results,
      };

  factory CaseStudyData.fromMap(Map<String, dynamic> map) {
    return CaseStudyData(
      overview: map['overview'] ?? "",
      problem: map['problem'] ?? "",
      objectives: map['objectives'] ?? "",
      methodology: map['methodology'] ?? "",
      designDecisions: map['designDecisions'] ?? "",
      solution: map['solution'] ?? "",
      results: map['results'] ?? "",
    );
  }
}
