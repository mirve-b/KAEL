import 'package:kael/API/case_study/creative_field.dart';
import 'package:kael/API/case_study/field_detector.dart';
import 'package:kael/API/gemini_service.dart';
import 'package:kael/SCREENS/FORMS/DATA%20MODEL/user_data_model.dart';
import 'package:kael/SCREENS/HOME/DATA%20MODEL/project_model.dart';
import 'package:kael/SCREENS/PROFILE/DATA%20MODEL/cv_models.dart';

class CvProjectExtractor {
  final GeminiService _gemini;

  CvProjectExtractor({GeminiService? gemini}) : _gemini = gemini ?? GeminiService();

  Future<CvProjectEntry> extract({
    required UserDataModel user,
    required ProjectPage project,
  }) async {
    final field = FieldDetector.detect(user, project.cells, projectTitle: project.title);
    final profile = FieldProfile.forField(field);
    final caseStudy = project.caseStudy;

    final cellNotes = project.cells
        .where((c) => c.type == 'text')
        .map((c) {
          final title = c.title.trim();
          final body = c.content.trim();
          if (title.isEmpty) return body;
          if (body.isEmpty) return title;
          return '$title: $body';
        })
        .where((note) => note.isNotEmpty)
        .join('\n');

    final caseStudyBlock = caseStudy == null
        ? ''
        : '''
CASE STUDY:
Overview: ${caseStudy.overview}
Problem: ${caseStudy.problem}
Objectives: ${caseStudy.objectives}
Solution: ${caseStudy.solution}
Results: ${caseStudy.results}
''';

    final prompt = '''
You write ATS-friendly CV project entries for a ${profile.displayName}.

CREATOR PROFILE:
${user.buildCreativeContextSummary()}

CATALOG PROJECT TITLE: ${project.title}

PROJECT NOTES:
${cellNotes.isEmpty ? '(No text notes — infer from case study and title.)' : cellNotes}

$caseStudyBlock

Infer the creator's role, tools/materials, and a concise CV description from the content above.
Use ${profile.displayName}-appropriate language (${profile.vocabulary.take(6).join(', ')}).

Return ONLY these exact lines with no extra commentary:
NAME: (CV project name, max 10 words)
ROLE: (creator's role on this project)
TECHNOLOGIES: (comma-separated tools, skills, software, materials, or methods used on THIS project — pull from project notes and creator skills where relevant)
DESCRIPTION: (2-3 plain-text sentences for a CV, no markdown)
URL: (leave empty unless explicitly mentioned in notes — user can edit later)
''';

    final raw = await _gemini.generateText(prompt);
    return _parse(raw, project: project);
  }

  CvProjectEntry fallback(ProjectPage project) {
    final caseStudy = project.caseStudy;
    var description = caseStudy?.overview.trim() ?? '';
    if (description.isEmpty) {
      description = project.cells
          .where((c) => c.type == 'text')
          .map((c) => c.content.trim())
          .where((text) => text.isNotEmpty)
          .join(' ');
    }
    description = description.replaceAll(RegExp(r'\*\*'), '').replaceAll(RegExp(r'^[-•]\s*', multiLine: true), '');
    if (description.length > 420) {
      description = '${description.substring(0, 417)}...';
    }

    return CvProjectEntry(
      id: project.id,
      name: project.title,
      role: '',
      technologies: '',
      description: description,
    );
  }

  CvProjectEntry _parse(String raw, {required ProjectPage project}) {
    const fields = ['NAME', 'ROLE', 'TECHNOLOGIES', 'DESCRIPTION', 'URL'];
    final values = <String, String>{};

    for (final field in fields) {
      values[field] = _readField(raw, field, fields);
    }

    return CvProjectEntry(
      id: project.id,
      name: values['NAME']!.isNotEmpty ? values['NAME']! : project.title,
      role: values['ROLE'] ?? '',
      technologies: values['TECHNOLOGIES'] ?? '',
      description: values['DESCRIPTION'] ?? '',
      url: values['URL'] ?? '',
    );
  }

  String _readField(String raw, String field, List<String> allFields) {
    final marker = '$field:';
    final start = _markerIndex(raw, marker);
    if (start == null) return '';

    final contentStart = start + marker.length;
    var end = raw.length;
    for (final other in allFields) {
      if (other == field) continue;
      final otherIndex = _markerIndex(raw, '$other:', searchFrom: contentStart);
      if (otherIndex != null && otherIndex < end) end = otherIndex;
    }
    return raw.substring(contentStart, end).trim();
  }

  int? _markerIndex(String raw, String marker, {int searchFrom = 0}) {
    final lower = raw.toLowerCase();
    final markerLower = marker.toLowerCase();
    var index = searchFrom;

    while (index < raw.length) {
      index = lower.indexOf(markerLower, index);
      if (index == -1) return null;
      if (index == 0 || raw[index - 1] == '\n') return index;
      index += marker.length;
    }
    return null;
  }
}
