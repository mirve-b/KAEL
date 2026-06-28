import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:kael/API/api_config.dart';
import 'package:kael/API/case_study/case_study_prompt_builder.dart';
import 'package:kael/API/image_bytes_helper.dart';
import 'package:kael/SCREENS/FORMS/DATA%20MODEL/user_data_model.dart';
import 'package:kael/SCREENS/HOME/DATA%20MODEL/project_model.dart';

class GeminiService {
  static const _caseStudySections = [
    'OVERVIEW',
    'PROBLEM',
    'OBJECTIVES',
    'METHODOLOGY',
    'DESIGN DECISIONS',
    'SOLUTION',
    'RESULTS',
  ];

  static const _modelFallbackChain = [
    'gemini-2.5-flash',
    'gemini-2.0-flash',
    'gemini-1.5-flash',
  ];

  Future<String> getCaseStudy({
    required UserDataModel user,
    required String projectTitle,
    required List<ProjectCell> cells,
  }) async {
    final parts = await _buildContentParts(user: user, projectTitle: projectTitle, cells: cells);
    Object? lastError;

    for (final modelName in _modelFallbackChain) {
      for (var attempt = 0; attempt < 3; attempt++) {
        try {
          final model = GenerativeModel(
            model: modelName,
            apiKey: ApiConfig.geminiKey,
          );
          final response = await model
              .generateContent([Content.multi(parts)])
              .timeout(const Duration(seconds: 120));

          if (response.text == null || response.text!.trim().isEmpty) {
            throw Exception('API returned an empty response.');
          }

          return response.text!;
        } catch (e) {
          lastError = e;
          if (_isRetryable(e) && attempt < 2) {
            await Future.delayed(Duration(seconds: 1 << attempt));
            continue;
          }
          if (_isRetryable(e)) break;
          rethrow;
        }
      }
    }

    throw lastError ?? Exception('Case study generation failed.');
  }

  bool _isRetryable(Object error) {
    final msg = error.toString().toLowerCase();
    return msg.contains('503') ||
        msg.contains('429') ||
        msg.contains('unavailable') ||
        msg.contains('high demand') ||
        msg.contains('resource exhausted') ||
        msg.contains('overloaded');
  }

  Future<List<Part>> _buildContentParts({
    required UserDataModel user,
    required String projectTitle,
    required List<ProjectCell> cells,
  }) async {
    final imageCells = cells.where((c) => c.type == 'image' && c.imagePaths.isNotEmpty).toList();
    final totalImages = imageCells.fold<int>(0, (sum, c) => sum + c.imagePaths.length);

    final prompt = CaseStudyPromptBuilder.build(
      user: user,
      cells: cells,
      projectTitle: projectTitle,
      totalImages: totalImages,
      imageGroupCount: imageCells.length,
    );

    final parts = <Part>[TextPart(prompt)];

    for (final cell in imageCells) {
      final label = cell.title.isEmpty ? 'Visual assets' : cell.title;
      parts.add(TextPart('--- Image group: $label (${cell.imagePaths.length} image(s)) ---'));
      for (final path in cell.imagePaths) {
        final payload = await ImageBytesHelper.loadForVision(path);
        if (payload == null) continue;
        parts.add(DataPart(payload.mimeType, payload.bytes));
      }
    }

    return parts;
  }

  Map<String, String> parseCaseStudySections(String raw) {
    final normalized = raw.replaceAll('\r\n', '\n').trim();
    final result = <String, String>{};
    for (final section in _caseStudySections) {
      result[section] = _extractSection(normalized, section);
    }
    return result;
  }

  String _extractSection(String raw, String header) {
    final marker = '$header:';
    final start = _sectionMarkerIndex(raw, marker);
    if (start == null) {
      return 'Information not populated for this section.';
    }

    final contentStart = start + marker.length;
    var end = raw.length;

    for (final other in _caseStudySections) {
      if (other == header) continue;
      final otherIndex = _sectionMarkerIndex(raw, '$other:', searchFrom: contentStart);
      if (otherIndex != null && otherIndex < end) {
        end = otherIndex;
      }
    }

    final content = raw.substring(contentStart, end).trim();
    return content.isEmpty ? 'Information not populated for this section.' : content;
  }

  int? _sectionMarkerIndex(String raw, String marker, {int searchFrom = 0}) {
    final lower = raw.toLowerCase();
    final markerLower = marker.toLowerCase();
    var index = searchFrom;

    while (index < raw.length) {
      index = lower.indexOf(markerLower, index);
      if (index == -1) return null;

      final atLineStart = index == 0 || raw[index - 1] == '\n';
      if (atLineStart) return index;

      index += marker.length;
    }

    return null;
  }
}
