import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;
import 'package:kael/API/api_config.dart';
import 'package:kael/SCREENS/HOME/DATA%20MODEL/project_model.dart';
import 'package:path_provider/path_provider.dart';

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

  final GenerativeModel _model = GenerativeModel(
    model: 'gemini-2.5-flash',
    apiKey: ApiConfig.geminiKey,
  );

  Future<String> getCaseStudy(List<ProjectCell> cells) async {
    try {
      final textAssets = cells
          .where((c) => c.type == 'text')
          .map((c) => 'Title: ${c.title}\nContent: ${c.content}')
          .join('\n\n');

      final imageCells = cells.where((c) => c.type == 'image' && c.imagePaths.isNotEmpty).toList();
      final totalImages = imageCells.fold<int>(0, (sum, c) => sum + c.imagePaths.length);

      final prompt = """
You are a senior UX/product case study writer. Write a highly structured, portfolio-grade case study.

PROJECT TEXT NOTES:
$textAssets

${totalImages > 0 ? 'You have been given $totalImages project image(s) across ${imageCells.length} visual group(s). Study typography, layout, color, hierarchy, UX flows, and interface patterns. Reference specific visual observations in DESIGN DECISIONS and SOLUTION.' : 'No project images were supplied. Infer reasonable design decisions from the text notes.'}

FORMATTING RULES (inside each section body):
- Use rich Markdown: **bold** for key terms, metrics, and emphasis
- Use bullet lists with "-" for objectives and feature lists
- Write clear paragraphs separated by blank lines
- Do NOT use # headings inside section bodies
- Be specific, analytical, and professional — not generic filler

OUTPUT FORMAT — use these exact section headers for parsing (one header per line, colon required):

OVERVIEW:
(2-3 paragraph executive summary with **bold** key outcomes)

PROBLEM:
(Problem framing with context, constraints, and user pain points)

OBJECTIVES:
(Bulleted goals with measurable intent where possible)

METHODOLOGY:
(Process, research, architecture, and iteration approach)

DESIGN DECISIONS:
(Visual/UX decisions informed by the provided images and notes)

SOLUTION:
(Implementation details, features, and how the design solves the problem)

RESULTS:
(Impact, learnings, and outcomes — use **bold** for standout metrics)
""";

      final parts = <Part>[TextPart(prompt)];

      for (final cell in imageCells) {
        final label = cell.title.isEmpty ? 'Visual assets' : cell.title;
        parts.add(TextPart('--- Image group: $label (${cell.imagePaths.length} image(s)) ---'));
        for (final path in cell.imagePaths) {
          final file = File(path);
          if (!await file.exists()) continue;
          final bytes = await file.readAsBytes();
          parts.add(DataPart(_mimeForPath(path), bytes));
        }
      }

      final response = await _model.generateContent([Content.multi(parts)]);

      if (response.text == null || response.text!.trim().isEmpty) {
        throw Exception('API returned an empty response.');
      }

      return response.text!;
    } catch (e) {
      rethrow;
    }
  }

  Map<String, String> parseCaseStudySections(String raw) {
    final result = <String, String>{};
    for (final section in _caseStudySections) {
      result[section] = _extractSection(raw, section);
    }
    return result;
  }

  String _extractSection(String raw, String header) {
    final others = _caseStudySections
        .where((h) => h != header)
        .map((h) => RegExp.escape('$h:'))
        .join('|');

    final regExp = RegExp(
      '${RegExp.escape('$header:')}\\s*(.*?)(?=($others)|\$)',
      dotAll: true,
      caseSensitive: false,
    );
    final match = regExp.firstMatch(raw);
    return match?.group(1)?.trim() ??
        'Information not populated for this section.';
  }

  Future<String> generateProfessionalHeadshot(String sourceImagePath) async {
    return _generateStyledPortrait(
      sourceImagePath: sourceImagePath,
      prompt: '''
Transform this person into a polished **professional corporate headshot** for a portfolio/CV.
Requirements:
- Neutral studio background (soft grey or off-white)
- Professional attire appearance
- Natural flattering lighting
- Shoulders-up framing, facing camera
- Photorealistic, high quality
- Preserve the person's recognizable identity and features
Output a single portrait image only.
''',
      filePrefix: 'headshot',
    );
  }

  Future<String> generateCharacterAvatar(String sourceImagePath) async {
    return _generateStyledPortrait(
      sourceImagePath: sourceImagePath,
      prompt: '''
Create a **stylized character avatar** inspired by this person's likeness for a creative portfolio.
Requirements:
- Illustrated/digital-art character style (not photorealistic)
- Distinct personality and expressive but professional vibe
- Clean background
- Recognizable likeness to the reference person
- Suitable as a profile avatar
Output a single character portrait image only.
''',
      filePrefix: 'character',
    );
  }

  Future<String> _generateStyledPortrait({
    required String sourceImagePath,
    required String prompt,
    required String filePrefix,
  }) async {
    final file = File(sourceImagePath);
    if (!await file.exists()) {
      throw Exception('Source image not found.');
    }

    final bytes = await file.readAsBytes();
    final mime = _mimeForPath(sourceImagePath);
    final b64 = base64Encode(bytes);

    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-preview-image-generation:generateContent?key=${ApiConfig.geminiKey}',
    );

    final body = {
      'contents': [
        {
          'parts': [
            {'text': prompt},
            {
              'inline_data': {'mime_type': mime, 'data': b64},
            },
          ],
        },
      ],
      'generationConfig': {
        'responseModalities': ['TEXT', 'IMAGE'],
      },
    };

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception('Image generation failed (${response.statusCode}): ${response.body}');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final imageBytes = _extractInlineImageBytes(decoded);
    if (imageBytes == null) {
      throw Exception('No image returned from the generation model.');
    }

    return _saveGeneratedImage(imageBytes, filePrefix);
  }

  Uint8List? _extractInlineImageBytes(Map<String, dynamic> json) {
    final candidates = json['candidates'] as List?;
    if (candidates == null || candidates.isEmpty) return null;

    final content = candidates.first['content'] as Map<String, dynamic>?;
    final parts = content?['parts'] as List?;
    if (parts == null) return null;

    for (final part in parts) {
      if (part is! Map<String, dynamic>) continue;
      final inline = part['inlineData'] ?? part['inline_data'];
      if (inline is Map<String, dynamic>) {
        final data = inline['data'] as String?;
        if (data != null) return base64Decode(data);
      }
    }
    return null;
  }

  Future<String> _saveGeneratedImage(Uint8List bytes, String prefix) async {
    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/kael_${prefix}_${DateTime.now().millisecondsSinceEpoch}.png';
    await File(path).writeAsBytes(bytes);
    return path;
  }

  static String _mimeForPath(String path) {
    switch (path.split('.').last.toLowerCase()) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      default:
        return 'image/jpeg';
    }
  }
}
