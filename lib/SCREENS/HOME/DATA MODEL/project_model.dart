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

  ProjectPage({required this.id, required this.title, required this.cells});

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'cells': cells.map((c) => c.toMap()).toList(),
      };

  factory ProjectPage.fromMap(Map<String, dynamic> map) {
    return ProjectPage(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      cells: (map['cells'] as List? ?? [])
          .map((c) => ProjectCell.fromMap(c))
          .toList(),
    );
  }
}


//CASE STUDY
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