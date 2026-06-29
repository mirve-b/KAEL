import 'dart:convert';

import 'package:kael/SCREENS/FORMS/DATA%20MODEL/user_data_model.dart';
import 'package:kael/SCREENS/PROFILE/DATA%20MODEL/cv_models.dart';

class JobMatchResult {
  final int compatibilityPercent;
  final String tailoredSummary;
  final List<String> matchNotes;
  final List<String> skills;
  final List<ExperienceEntry> experiences;
  final List<CvProjectEntry> projects;
  final List<CertificationEntry> certifications;
  final List<EducationEntry> educationEntries;
  final List<String> languages;

  const JobMatchResult({
    required this.compatibilityPercent,
    required this.tailoredSummary,
    required this.matchNotes,
    required this.skills,
    required this.experiences,
    required this.projects,
    required this.certifications,
    required this.educationEntries,
    required this.languages,
  });

  factory JobMatchResult.fromJson(Map<String, dynamic> json, UserDataModel user) {
    final percent = (json['compatibilityPercent'] as num?)?.round().clamp(0, 100) ?? 0;
    final summary = (json['tailoredSummary'] as String?)?.trim() ?? user.bio;
    final notes = (json['matchNotes'] as List?)
            ?.map((e) => e.toString().trim())
            .where((e) => e.isNotEmpty)
            .toList() ??
        [];

    List<T> pickByIndex<T>(List<T> source, dynamic indices) {
      if (indices is! List) return [];
      final picked = <T>[];
      for (final raw in indices) {
        final index = raw is num ? raw.toInt() : int.tryParse(raw.toString());
        if (index == null || index < 0 || index >= source.length) continue;
        picked.add(source[index]);
      }
      return picked;
    }

    List<String> pickSkills(Map<String, dynamic> json) {
      final indices = json['skillIndices'];
      if (indices is List && indices.isNotEmpty) {
        return pickByIndex(user.skills, indices);
      }
      final names = json['skills'];
      if (names is List) {
        return names.map((e) => e.toString().trim()).where((s) => s.isNotEmpty).toList();
      }
      return [];
    }

    return JobMatchResult(
      compatibilityPercent: percent,
      tailoredSummary: summary.isEmpty ? user.bio : summary,
      matchNotes: notes,
      skills: pickSkills(json),
      experiences: pickByIndex(user.experiences, json['experienceIndices']),
      projects: pickByIndex(user.cvProjects, json['projectIndices']),
      certifications: pickByIndex(user.certifications, json['certificationIndices']),
      educationEntries: pickByIndex(user.educationEntries, json['educationIndices']),
      languages: pickByIndex(user.languages, json['languageIndices']),
    );
  }

  static JobMatchResult? tryParse(String raw, UserDataModel user) {
    try {
      final cleaned = raw
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();
      final start = cleaned.indexOf('{');
      final end = cleaned.lastIndexOf('}');
      if (start == -1 || end == -1) return null;
      final map = jsonDecode(cleaned.substring(start, end + 1)) as Map<String, dynamic>;
      return JobMatchResult.fromJson(map, user);
    } catch (_) {
      return null;
    }
  }
}
